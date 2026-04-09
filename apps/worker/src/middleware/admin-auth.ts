import { createMiddleware } from 'hono/factory'
import { getCookie } from 'hono/cookie'
import { jwtVerify } from 'jose'

import type { Env } from '../types'

export const adminAuth = createMiddleware<{ Bindings: Env }>(async (c, next) => {
  const authHeader = c.req.header('Authorization')

  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.slice(7)
    if (token === c.env.ADMIN_AUTH_TOKEN) {
      return next()
    }
    return c.json({ error: 'Unauthorized' }, 401)
  }

  const cookie = getCookie(c, 'howlalert-session')
  if (cookie) {
    try {
      const secret = new TextEncoder().encode(c.env.ADMIN_AUTH_TOKEN)
      await jwtVerify(cookie, secret)
      return next()
    } catch {
      return c.json({ error: 'Unauthorized' }, 401)
    }
  }

  return c.json({ error: 'Unauthorized' }, 401)
})
