import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

import type { Env } from '../types';

const verifySchema = z.object({
  secret: z.string().min(1),
});

export const authRoutes = new Hono<{ Bindings: Env }>().post(
  '/verify',
  zValidator('json', verifySchema),
  async (c) => {
    const { secret } = c.req.valid('json');
    const valid = secret === c.env.ADMIN_SECRET;
    return c.json({ valid }, valid ? 200 : 401);
  }
);
