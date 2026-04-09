import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

import type { Env } from '../types';
import { adminAuth } from '../middleware/admin-auth';

const CONFIG_KEY = 'remote-config';

const configSchema = z.object({
  warningThreshold: z.number().min(0).max(1).default(0.8),
  criticalThreshold: z.number().min(0).max(1).default(0.95),
  promoMultiplier: z.number().min(1).optional(),
  planLimitOverride: z.number().int().positive().optional(),
});

export const configRoutes = new Hono<{ Bindings: Env }>()
  .get('/', async (c) => {
    const raw = await c.env.CONFIG_KV.get(CONFIG_KEY, 'json');
    return c.json(raw ?? {});
  })
  .post('/', adminAuth, zValidator('json', configSchema), async (c) => {
    const body = c.req.valid('json');
    await c.env.CONFIG_KV.put(CONFIG_KEY, JSON.stringify(body));
    return c.json({ ok: true });
  });
