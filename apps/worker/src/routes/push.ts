import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { importPKCS8, SignJWT } from 'jose'

import type { Env, PushLogEntry, RemoteConfig } from '../types'
import { DEFAULT_CONFIG } from '../types'

const APNS_BUNDLE_ID = 'com.mrdemonwolf.howlalert'
const PUSH_LOG_KEY = 'push-log'
const CONFIG_KEY = 'config'

const pushSchema = z.object({
  pairingSecret: z.string().min(1),
  deviceToken: z.string().min(1),
  usagePercent: z.number().min(0).max(200),
  model: z.string().optional().default('unknown'),
  paceStatus: z.enum(['onTrack', 'inDebt', 'inReserve']),
  pacePercent: z.number().min(0),
  runsOutInSeconds: z.number().nullable().optional(),
  sessionTokens: z.number().int().min(0).optional().default(0),
  plan: z.string().optional().default('pro'),
})

function isOffPeak(schedule: RemoteConfig['offPeakSchedule']): boolean {
  if (!schedule) return false
  const hour = new Date().getUTCHours()
  const { startHour, endHour } = schedule
  if (startHour <= endHour) return hour >= startHour && hour < endHour
  return hour >= startHour || hour < endHour
}

function buildAlertBody(
  paceStatus: string,
  usagePercent: number,
  pacePercent: number,
  runsOutInSeconds: number | null | undefined
): string {
  const usage = Math.round(usagePercent)
  const pace = Math.round(pacePercent)

  if (paceStatus === 'inDebt') {
    if (runsOutInSeconds != null) {
      const mins = Math.round(runsOutInSeconds / 60)
      const timeStr = mins >= 60 ? `${Math.round(mins / 60)}h` : `${mins}min`
      return `${usage}% used — ${pace}% in debt, runs out in ${timeStr}`
    }
    return `${usage}% used — ${pace}% in debt`
  }

  if (paceStatus === 'inReserve') {
    return `${usage}% used — ${pace}% in reserve`
  }

  return `${usage}% used — on track (${pace}% pace)`
}

async function signApnsJwt(authKey: string, keyId: string, teamId: string): Promise<string> {
  const privateKey = await importPKCS8(authKey, 'ES256')
  return new SignJWT({})
    .setProtectedHeader({ alg: 'ES256', kid: keyId })
    .setIssuer(teamId)
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(privateKey)
}

async function appendPushLog(env: Env, entry: PushLogEntry): Promise<void> {
  const raw = await env.HOWLALERT_PUSH_LOG.get(PUSH_LOG_KEY)
  const existing: PushLogEntry[] = raw ? JSON.parse(raw) : []
  const updated = [...existing, entry].slice(-100)
  await env.HOWLALERT_PUSH_LOG.put(PUSH_LOG_KEY, JSON.stringify(updated))
}

export const pushRoutes = new Hono<{ Bindings: Env }>().post(
  '/',
  zValidator('json', pushSchema),
  async (c) => {
    const body = c.req.valid('json')

    // Load config
    const rawConfig = await c.env.HOWLALERT_CONFIG.get(CONFIG_KEY)
    const config: RemoteConfig = rawConfig ? JSON.parse(rawConfig) : { ...DEFAULT_CONFIG }

    // Calculate effective limit
    const offPeak = isOffPeak(config.offPeakSchedule)
    const multiplier = config.multiplier
    const baseLimit = config.planLimits[body.plan] ?? config.planLimits['pro'] ?? 200000
    const effectiveLimit = Math.round(baseLimit * multiplier)

    // Build APNs payload
    const alertBody = buildAlertBody(
      body.paceStatus,
      body.usagePercent,
      body.pacePercent,
      body.runsOutInSeconds
    )

    const apnsPayload = {
      aps: {
        alert: { title: 'HowlAlert', body: alertBody },
        sound: 'default',
        badge: 1,
      },
      howlalert: {
        usagePercent: body.usagePercent,
        paceStatus: body.paceStatus,
        pacePercent: body.pacePercent,
        runsOutInSeconds: body.runsOutInSeconds ?? null,
        effectiveLimit,
        isOffPeak: offPeak,
        multiplier,
      },
    }

    // Sign APNs JWT
    const apnsJwt = await signApnsJwt(
      c.env.APNS_AUTH_KEY,
      c.env.APNS_KEY_ID,
      c.env.APNS_TEAM_ID
    )

    // Send to APNs
    const apnsUrl = `https://api.push.apple.com/3/device/${body.deviceToken}`
    const apnsResp = await fetch(apnsUrl, {
      method: 'POST',
      headers: {
        authorization: `bearer ${apnsJwt}`,
        'apns-push-type': 'alert',
        'apns-topic': APNS_BUNDLE_ID,
        'apns-priority': '10',
        'content-type': 'application/json',
      },
      body: JSON.stringify(apnsPayload),
    })

    const apnsStatus = apnsResp.status
    const apnsResult: PushLogEntry['apnsResult'] = apnsStatus === 200 ? 'delivered' : 'failed'

    // Append to ring buffer log
    const logEntry: PushLogEntry = {
      id: crypto.randomUUID(),
      deviceToken: body.deviceToken,
      plan: body.plan,
      usagePercent: body.usagePercent,
      paceStatus: body.paceStatus,
      apnsStatus,
      apnsResult,
      sentAt: new Date().toISOString(),
    }
    await appendPushLog(c.env, logEntry)

    if (apnsResult === 'failed') {
      return c.json({ error: 'APNs delivery failed', apnsStatus }, 502)
    }

    return c.json({ ok: true })
  }
)
