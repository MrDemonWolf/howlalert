import { Hono } from "hono";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";

// Zod schemas
const RegisterSchema = z.object({
  deviceToken: z.string().min(1),
  deviceName: z.string().min(1),
  cloudkitUserId: z.string().min(1),
});

const PushSchema = z.object({
  cloudkitUserId: z.string().min(1),
  title: z.string().min(1),
  body: z.string().min(1),
  payload: z.record(z.string(), z.unknown()).optional(),
});

const EntitlementSyncSchema = z.object({
  event: z.object({
    type: z.string(),
    app_user_id: z.string(),
    expiration_at_ms: z.number().optional(),
    entitlement_ids: z.array(z.string()).optional(),
  }),
});

type Env = {
  Bindings: {
    DB: D1Database;
    HOWLALERT_DEVICES: KVNamespace;
    HOWLALERT_PUSH_LOG: KVNamespace;
    APNS_AUTH_KEY: string;
    APNS_KEY_ID: string;
    APNS_TEAM_ID: string;
    REVENUECAT_WEBHOOK_SECRET: string;
    WORKER_VERSION: string;
  };
};

const app = new Hono<Env>();

// GET /health
app.get("/health", (c) => {
  return c.json({ ok: true, version: c.env.WORKER_VERSION ?? "2.0.0" });
});

// POST /register — store device token in KV
app.post("/register", zValidator("json", RegisterSchema), async (c) => {
  const { deviceToken, deviceName, cloudkitUserId } = c.req.valid("json");
  await c.env.HOWLALERT_DEVICES.put(
    `device:${cloudkitUserId}`,
    JSON.stringify({ deviceToken, deviceName, registeredAt: Date.now() }),
    { expirationTtl: 60 * 60 * 24 * 365 } // 1 year
  );
  return c.json({ ok: true });
});

// POST /push — validate D1 entitlement, send APNs
app.post("/push", zValidator("json", PushSchema), async (c) => {
  const { cloudkitUserId, title, body, payload } = c.req.valid("json");

  // Check entitlement
  const row = await c.env.DB.prepare(
    "SELECT entitlement_active, expires_at FROM users WHERE cloudkit_user_id = ?"
  ).bind(cloudkitUserId).first<{ entitlement_active: number; expires_at: number | null }>();

  if (!row || !row.entitlement_active) {
    return c.json({ ok: false, error: "no_entitlement" }, 403);
  }

  // Fetch device token
  const deviceData = await c.env.HOWLALERT_DEVICES.get(`device:${cloudkitUserId}`, "json") as { deviceToken: string } | null;
  if (!deviceData) {
    return c.json({ ok: false, error: "device_not_found" }, 404);
  }

  // Send APNs push
  const { ApnsClient, Notification, Host } = await import("@fivesheepco/cloudflare-apns2");
  const client = new ApnsClient({
    team: c.env.APNS_TEAM_ID,
    signingKey: c.env.APNS_AUTH_KEY,
    keyId: c.env.APNS_KEY_ID,
    defaultTopic: "com.mrdemonwolf.howlalert",
    host: Host.production,
  });
  const notification = new Notification(deviceData.deviceToken, {
    alert: { title, body },
    sound: "default",
    contentAvailable: true,
    data: payload,
  });
  await client.send(notification);

  // Log push
  const logKey = `pushlog:${cloudkitUserId}:${Date.now()}`;
  await c.env.HOWLALERT_PUSH_LOG.put(logKey, JSON.stringify({ title, body, sentAt: Date.now() }), { expirationTtl: 60 * 60 * 24 * 30 });

  return c.json({ ok: true });
});

// POST /entitlement/sync — RevenueCat webhook → update D1
app.post("/entitlement/sync", zValidator("json", EntitlementSyncSchema), async (c) => {
  // Verify RC webhook secret
  const secret = c.req.header("Authorization")?.replace("Bearer ", "");
  if (secret !== c.env.REVENUECAT_WEBHOOK_SECRET) {
    return c.json({ ok: false, error: "unauthorized" }, 401);
  }

  const { event } = c.req.valid("json");
  const rcAppUserId = event.app_user_id;
  const activeEvents = ["INITIAL_PURCHASE", "RENEWAL", "PRODUCT_CHANGE", "UNCANCELLATION"];

  const entitlementActive = activeEvents.includes(event.type) ? 1 : 0;
  const expiresAt = event.expiration_at_ms ? Math.floor(event.expiration_at_ms / 1000) : null;

  await c.env.DB.prepare(`
    INSERT INTO users (cloudkit_user_id, rc_app_user_id, entitlement_active, expires_at, updated_at)
    VALUES (?, ?, ?, ?, unixepoch())
    ON CONFLICT(cloudkit_user_id) DO UPDATE SET
      rc_app_user_id = excluded.rc_app_user_id,
      entitlement_active = excluded.entitlement_active,
      expires_at = excluded.expires_at,
      updated_at = unixepoch()
  `).bind(rcAppUserId, rcAppUserId, entitlementActive, expiresAt).run();

  return c.json({ ok: true });
});

export default app;
