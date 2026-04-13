import { describe, it, expect } from "vitest";
import app from "./index";

// Minimal mock bindings for testing route logic
function createMockEnv() {
  const kvStore = new Map<string, string>();

  return {
    DB: {} as D1Database,
    HOWLALERT_DEVICES: {
      put: async (key: string, value: string) => {
        kvStore.set(key, value);
      },
      get: async (key: string) => kvStore.get(key) ?? null,
    } as unknown as KVNamespace,
    HOWLALERT_PUSH_LOG: {
      put: async (key: string, value: string) => {
        kvStore.set(key, value);
      },
      get: async (key: string) => kvStore.get(key) ?? null,
    } as unknown as KVNamespace,
    APNS_TEAM_ID: "TEST_TEAM",
    APNS_KEY_ID: "TEST_KEY",
    APNS_SIGNING_KEY: "TEST_SIGN",
    REVENUECAT_WEBHOOK_SECRET: "test-secret",
    ADMIN_SECRET: "admin-secret",
    ENVIRONMENT: "test",
  };
}

describe("GET /health", () => {
  it("returns ok and version", async () => {
    const res = await app.request("/health", {}, createMockEnv());
    expect(res.status).toBe(200);

    const body = await res.json();
    expect(body.ok).toBe(true);
    expect(body.version).toBe("2.0.0");
  });
});

describe("POST /register", () => {
  it("rejects invalid body", async () => {
    const res = await app.request(
      "/register",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ bad: "data" }),
      },
      createMockEnv()
    );
    expect(res.status).toBe(400);
  });

  it("stores device token in KV", async () => {
    const env = createMockEnv();
    const res = await app.request(
      "/register",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          deviceToken: "abc123",
          cloudkitUserId: "user1",
          deviceName: "iPhone",
          platform: "ios",
        }),
      },
      env
    );
    expect(res.status).toBe(200);

    const body = await res.json();
    expect(body.ok).toBe(true);
    expect(body.key).toBe("user1:ios");
  });
});

describe("POST /entitlement/sync", () => {
  it("rejects without auth header", async () => {
    const res = await app.request(
      "/entitlement/sync",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ event: { type: "INITIAL_PURCHASE", app_user_id: "u1" } }),
      },
      createMockEnv()
    );
    expect(res.status).toBe(401);
  });
});

describe("GET /admin/usage", () => {
  it("rejects without admin secret", async () => {
    const res = await app.request("/admin/usage", {}, createMockEnv());
    expect(res.status).toBe(401);
  });
});
