import { Hono } from 'hono'
import { logger } from 'hono/logger'

import type { Env } from './types'
import { pushRoutes } from './routes/push'

const app = new Hono<{ Bindings: Env }>()

app.use('*', logger())

app.get('/', (c) => c.json({ ok: true, service: 'howlalert-worker' }))

app.route('/api/push', pushRoutes)

export default app
