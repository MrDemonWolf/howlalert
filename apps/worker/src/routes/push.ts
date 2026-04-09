import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { importPKCS8, SignJWT } from 'jose'

import type { Env } from '../types'

const APNS_BUNDLE_ID = 'com.mrdemonwolf.howlalert'

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

export const pushRoutes = new Hono<{ Bindings: Env }>().post(
  '/',
  zValidator('json', pushSchema),
  async (c) => {
    const body = c.req.valid('json')

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
      },
    }

    const apnsJwt = await signApnsJwt(
      c.env.APNS_AUTH_KEY,
      c.env.APNS_KEY_ID,
      c.env.APNS_TEAM_ID
    )

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

    if (!apnsResp.ok) {
      return c.json({ error: 'APNs delivery failed', apnsStatus: apnsResp.status }, 502)
    }

    return c.json({ ok: true })
  }
)
