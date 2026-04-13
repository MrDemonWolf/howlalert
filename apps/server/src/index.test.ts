import { describe, it, expect } from "vitest";
import app from "./index";

// Minimal mock env
const makeEnv = (overrides: Record<string, unknown> = {}) => ({
  WORKER_VERSION: "2.0.0",
  APNS_AUTH_KEY: "fake-key",
  APNS_KEY_ID: "FAKEKEYID1",
  APNS_TEAM_ID: "FAKETEAMID",
  REVENUECAT_WEBHOOK_SECRET: "rc-secret",
  HOWLALERT_DEVICES: {
    put: async () => {},
    get: async () => null,
  } as unknown as KVNamespace,
  HOWLALERT_PUSH_LOG: {
    put: async () => {},
  } as unknown as KVNamespace,
  DB: {
    prepare: () => ({
      bind: () => ({
        first: async () => null,
        run: async () => {},
      }),
    }),
  } as unknown as D1Database,
  ...overrides,
});

describe("GET /health", () => {
  it("returns ok with version", async () => {
    const res = await app.request("/health", {}, makeEnv());
    expect(res.status).toBe(200);
    const json = await res.json();
    expect(json).toMatchObject({ ok: true, version: "2.0.0" });
  });
});

describe("POST /register", () => {
  it("stores device token and returns ok", async () => {
    let stored: unknown;
    const env = makeEnv({
      HOWLALERT_DEVICES: {
        put: async (_key: string, value: string) => {
          stored = JSON.parse(value);
        },
        get: async () => null,
      } as unknown as KVNamespace,
    });

    const res = await app.request(
      "/register",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          deviceToken: "abc123",
          deviceName: "My iPhone",
          cloudkitUserId: "ck-user-001",
        }),
      },
      env
    );
    expect(res.status).toBe(200);
    const json = await res.json();
    expect(json).toMatchObject({ ok: true });
    expect(stored).toMatchObject({ deviceToken: "abc123", deviceName: "My iPhone" });
  });

  it("returns 400 on missing fields", async () => {
    const res = await app.request(
      "/register",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ deviceToken: "tok" }), // missing deviceName, cloudkitUserId
      },
      makeEnv()
    );
    expect(res.status).toBe(400);
  });
});

describe("POST /push", () => {
  it("returns 403 when no entitlement row exists", async () => {
    const res = await app.request(
      "/push",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          cloudkitUserId: "ck-no-entitlement",
          title: "Test",
          body: "Hello",
        }),
      },
      makeEnv() // DB.prepare returns null for first()
    );
    expect(res.status).toBe(403);
    const json = await res.json();
    expect(json).toMatchObject({ ok: false, error: "no_entitlement" });
  });

  it("returns 403 when entitlement_active is 0", async () => {
    const env = makeEnv({
      DB: {
        prepare: () => ({
          bind: () => ({
            first: async () => ({ entitlement_active: 0, expires_at: null }),
            run: async () => {},
          }),
        }),
      } as unknown as D1Database,
    });

    const res = await app.request(
      "/push",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          cloudkitUserId: "ck-inactive",
          title: "Test",
          body: "Hello",
        }),
      },
      env
    );
    expect(res.status).toBe(403);
  });
});

describe("POST /entitlement/sync", () => {
  it("returns 401 with wrong secret", async () => {
    const res = await app.request(
      "/entitlement/sync",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: "Bearer wrong-secret",
        },
        body: JSON.stringify({
          event: {
            type: "INITIAL_PURCHASE",
            app_user_id: "rc-user-123",
          },
        }),
      },
      makeEnv()
    );
    expect(res.status).toBe(401);
    const json = await res.json();
    expect(json).toMatchObject({ ok: false, error: "unauthorized" });
  });

  it("returns ok with correct secret and updates DB", async () => {
    let ranQuery = false;
    const env = makeEnv({
      DB: {
        prepare: () => ({
          bind: () => ({
            first: async () => null,
            run: async () => {
              ranQuery = true;
            },
          }),
        }),
      } as unknown as D1Database,
    });

    const res = await app.request(
      "/entitlement/sync",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: "Bearer rc-secret",
        },
        body: JSON.stringify({
          event: {
            type: "INITIAL_PURCHASE",
            app_user_id: "rc-user-123",
            expiration_at_ms: 1800000000000,
          },
        }),
      },
      env
    );
    expect(res.status).toBe(200);
    const json = await res.json();
    expect(json).toMatchObject({ ok: true });
    expect(ranQuery).toBe(true);
  });
});
