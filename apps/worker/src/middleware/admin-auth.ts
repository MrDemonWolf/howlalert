import { createMiddleware } from 'hono/factory';

import type { Env } from '../types';

export const adminAuth = createMiddleware<{ Bindings: Env }>(async (c, next) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const token = authHeader.slice(7);
  if (token !== c.env.ADMIN_SECRET) {
    return c.json({ error: 'Forbidden' }, 403);
  }

  await next();
});
