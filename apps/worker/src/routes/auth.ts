import { Hono } from 'hono'
import { setCookie } from 'hono/cookie'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { SignJWT } from 'jose'

import type { Env } from '../types'

const verifySchema = z.object({
  token: z.string().min(1),
})

const SESSION_MAX_AGE = 60 * 60 * 24 // 24 hours

export const authRoutes = new Hono<{ Bindings: Env }>().post(
  '/verify',
  zValidator('json', verifySchema),
  async (c) => {
    const { token } = c.req.valid('json')

    if (token !== c.env.ADMIN_AUTH_TOKEN) {
      return c.json({ error: 'Invalid token' }, 401)
    }

    const secret = new TextEncoder().encode(c.env.ADMIN_AUTH_TOKEN)
    const jwt = await new SignJWT({ sub: 'admin' })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setExpirationTime('24h')
      .sign(secret)

    setCookie(c, 'howlalert-session', jwt, {
      httpOnly: true,
      sameSite: 'Strict',
      maxAge: SESSION_MAX_AGE,
      path: '/',
      secure: c.env.WORKER_ENV !== 'development',
    })

    return c.json({ ok: true })
  }
)
