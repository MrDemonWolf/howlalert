import { Hono } from 'hono'

import type { Env, PushLogEntry } from '../types'
import { adminAuth } from '../middleware/admin-auth'

const PUSH_LOG_KEY = 'push-log'

export const pushLogRoutes = new Hono<{ Bindings: Env }>()
  .use('*', adminAuth)
  .get('/', async (c) => {
    const raw = await c.env.HOWLALERT_PUSH_LOG.get(PUSH_LOG_KEY)
    const entries: PushLogEntry[] = raw ? JSON.parse(raw) : []
    return c.json({ entries })
  })
  .get('/stats', async (c) => {
    const raw = await c.env.HOWLALERT_PUSH_LOG.get(PUSH_LOG_KEY)
    const entries: PushLogEntry[] = raw ? JSON.parse(raw) : []
    const total = entries.length
    const successful = entries.filter((e) => e.apnsResult === 'delivered').length
    const failed = entries.filter((e) => e.apnsResult === 'failed').length
    const successRate = total === 0 ? 0 : successful / total
    return c.json({ total, successful, failed, successRate })
  })
