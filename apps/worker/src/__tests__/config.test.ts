import { describe, it, expect, beforeEach } from 'vitest'
import { Hono } from 'hono'

import { DEFAULT_CONFIG } from '../types'
import type { Env, RemoteConfig } from '../types'

// --- Minimal KV mock ---
function makeKV(): KVNamespace {
  const store = new Map<string, string>()
  return {
    get: async (key: string) => store.get(key) ?? null,
    put: async (key: string, value: string) => { store.set(key, value) },
    delete: async (key: string) => { store.delete(key) },
    list: async () => ({ keys: [], list_complete: true, caret: undefined }),
    getWithMetadata: async (key: string) => ({ value: store.get(key) ?? null, metadata: null }),
  } as unknown as KVNamespace
}

function makeEnv(kvConfig: KVNamespace, kvLog: KVNamespace, token = 'test-token'): Env {
  return {
    HOWLALERT_CONFIG: kvConfig,
    HOWLALERT_PUSH_LOG: kvLog,
    ADMIN_AUTH_TOKEN: token,
    APNS_AUTH_KEY: '',
    APNS_KEY_ID: '',
    APNS_TEAM_ID: '',
    WORKER_ENV: 'test',
  }
}

// Build isolated app per test to inject env
async function buildApp(_env: Env) {
  // Dynamically import so mock env can be injected via Hono bindings
  const { configRoutes } = await import('../routes/config')
  const app = new Hono<{ Bindings: Env }>()
  app.route('/api/config', configRoutes)
  return app
}

describe('GET /api/config', () => {
  it('returns default config when KV is empty', async () => {
    const env = makeEnv(makeKV(), makeKV())
    const app = await buildApp(env)

    const res = await app.request('/api/config', {}, env)
    expect(res.status).toBe(200)
    const body = await res.json() as RemoteConfig
    expect(body.multiplier).toBe(1.0)
    expect(body.activePromo).toBeNull()
    expect(body.planLimits['pro']).toBe(DEFAULT_CONFIG.planLimits['pro'])
  })

  it('returns saved config from KV', async () => {
    const kv = makeKV()
    await kv.put('config', JSON.stringify({ ...DEFAULT_CONFIG, multiplier: 2.5, updatedAt: '2026-01-01T00:00:00.000Z' }))
    const env = makeEnv(kv, makeKV())
    const app = await buildApp(env)

    const res = await app.request('/api/config', {}, env)
    expect(res.status).toBe(200)
    const body = await res.json() as RemoteConfig
    expect(body.multiplier).toBe(2.5)
  })
})

describe('POST /api/config', () => {
  let env: Env
  let app: Hono<{ Bindings: Env }>

  beforeEach(async () => {
    env = makeEnv(makeKV(), makeKV())
    app = await buildApp(env)
  })

  it('saves config and returns it when authorized', async () => {
    const res = await app.request(
      '/api/config',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer test-token',
        },
        body: JSON.stringify({ multiplier: 3.0 }),
      },
      env
    )
    expect(res.status).toBe(200)
    const body = await res.json() as { ok: boolean; config: RemoteConfig }
    expect(body.ok).toBe(true)
    expect(body.config.multiplier).toBe(3.0)
    expect(body.config.updatedAt).toBeTruthy()
  })

  it('returns 401 without auth', async () => {
    const res = await app.request(
      '/api/config',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ multiplier: 3.0 }),
      },
      env
    )
    expect(res.status).toBe(401)
    const body = await res.json() as { error: string }
    expect(body.error).toBe('Unauthorized')
  })

  it('returns 401 with wrong token', async () => {
    const res = await app.request(
      '/api/config',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer wrong-token',
        },
        body: JSON.stringify({ multiplier: 3.0 }),
      },
      env
    )
    expect(res.status).toBe(401)
  })
})
