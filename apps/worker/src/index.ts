import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'

import type { Env } from './types'
import { authRoutes } from './routes/auth'
import { configRoutes } from './routes/config'
import { pushLogRoutes } from './routes/push-log'
import { pushRoutes } from './routes/push'

const app = new Hono<{ Bindings: Env }>()

// Middleware
app.use('*', logger())
app.use(
  '/api/*',
  cors({
    origin: ['https://admin.howlalert.mrdemonwolf.com', 'http://localhost:3001'],
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
)

// Health check
app.get('/', (c) => c.json({ ok: true, service: 'howlalert-worker' }))

// Routes
// POST /api/push    — public (authenticated by pairingSecret in body + APNs device token)
// GET/POST /api/config  — GET public, POST protected by adminAuth
// GET /api/push-log + /stats — protected by adminAuth
// POST /api/auth/verify — public (returns session cookie)
app.route('/api/push', pushRoutes)
app.route('/api/config', configRoutes)
app.route('/api/push-log', pushLogRoutes)
app.route('/api/auth', authRoutes)

export default app
