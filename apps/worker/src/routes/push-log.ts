import { Hono } from 'hono';

import type { Env } from '../types';
import { adminAuth } from '../middleware/admin-auth';

export const pushLogRoutes = new Hono<{ Bindings: Env }>()
  .use('*', adminAuth)
  .get('/', async (c) => {
    // TODO HAA-24: paginated push log listing
    const list = await c.env.PUSH_LOG_KV.list({ limit: 100 });
    return c.json({ entries: list.keys, cursor: list.cursor ?? null });
  })
  .get('/stats', async (c) => {
    // TODO HAA-24: aggregate push stats
    return c.json({ total: 0, last24h: 0, last7d: 0 });
  });
