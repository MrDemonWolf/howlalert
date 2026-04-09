import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

import type { Env, RemoteConfig } from '../types'
import { DEFAULT_CONFIG } from '../types'
import { adminAuth } from '../middleware/admin-auth'

const CONFIG_KEY = 'config'

const configSchema = z.object({
  multiplier: z.number().min(0.1).max(100),
  activePromo: z.string().nullable().optional(),
  planLimits: z.record(z.number().int().positive()).optional(),
  offPeakSchedule: z
    .object({ startHour: z.number().int().min(0).max(23), endHour: z.number().int().min(0).max(23) })
    .nullable()
    .optional(),
})

export const configRoutes = new Hono<{ Bindings: Env }>()
  .get('/', async (c) => {
    const raw = await c.env.HOWLALERT_CONFIG.get(CONFIG_KEY)
    if (!raw) return c.json(DEFAULT_CONFIG)
    return c.json(JSON.parse(raw) as RemoteConfig)
  })
  .post('/', adminAuth, zValidator('json', configSchema), async (c) => {
    const body = c.req.valid('json')
    const existing = await c.env.HOWLALERT_CONFIG.get(CONFIG_KEY)
    const current: RemoteConfig = existing ? JSON.parse(existing) : { ...DEFAULT_CONFIG }
    const updated: RemoteConfig = {
      ...current,
      multiplier: body.multiplier,
      activePromo: body.activePromo ?? current.activePromo,
      planLimits: body.planLimits ?? current.planLimits,
      offPeakSchedule: body.offPeakSchedule ?? current.offPeakSchedule,
      updatedAt: new Date().toISOString(),
    }
    await c.env.HOWLALERT_CONFIG.put(CONFIG_KEY, JSON.stringify(updated))
    return c.json({ ok: true, config: updated })
  })
