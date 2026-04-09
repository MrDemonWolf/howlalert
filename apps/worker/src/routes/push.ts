import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

import type { Env } from '../types';
import { adminAuth } from '../middleware/admin-auth';

const pushSchema = z.object({
  deviceToken: z.string().min(1),
  title: z.string().min(1),
  body: z.string().min(1),
  data: z.record(z.unknown()).optional(),
});

export const pushRoutes = new Hono<{ Bindings: Env }>()
  .use('*', adminAuth)
  .post('/', zValidator('json', pushSchema), async (c) => {
    // TODO HAA-23: implement APNs push via jose JWT
    const _payload = c.req.valid('json');
    return c.json({ ok: true, queued: true }, 200);
  });
