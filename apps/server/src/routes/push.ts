import { Hono } from "hono";
import { eq } from "drizzle-orm";
import { createDb, schema } from "@howlalert/db";
import type { Bindings } from "../lib/bindings";
import { pushSchema } from "../lib/schemas";

const COOLDOWN_SECONDS = 30 * 60; // 30 min

const app = new Hono<{ Bindings: Bindings }>();

app.post("/push", async (c) => {
  const body = await c.req.json();
  const parsed = pushSchema.safeParse(body);

  if (!parsed.success) {
    return c.json({ error: "Invalid request", details: parsed.error.flatten() }, 400);
  }

  const { deviceToken, cloudkitUserId, sourceDeviceName, usage, pace, windowEnd, kind } =
    parsed.data;

  // Validate entitlement in D1
  const db = createDb(c.env.DB);
  const [user] = await db
    .select()
    .from(schema.users)
    .where(eq(schema.users.cloudkitUserId, cloudkitUserId))
    .limit(1);

  if (!user?.entitlementActive) {
    return c.json({ error: "No active entitlement" }, 403);
  }

  if (user.expiresAt && user.expiresAt < new Date()) {
    return c.json({ error: "Entitlement expired" }, 403);
  }

  // Check cooldown (per user per kind)
  const cooldownKey = `cooldown:${cloudkitUserId}:${kind}`;
  const lastPush = await c.env.HOWLALERT_PUSH_LOG.get(cooldownKey);
  if (lastPush) {
    return c.json({ ok: true, throttled: true });
  }

  // Set cooldown
  await c.env.HOWLALERT_PUSH_LOG.put(cooldownKey, new Date().toISOString(), {
    expirationTtl: COOLDOWN_SECONDS,
  });

  // Log push to D1
  await db.insert(schema.pushLog).values({
    cloudkitUserId,
    kind,
    sourceDeviceName,
  });

  // Build notification payload
  const usagePercent = Math.round(usage * 100);
  let alertBody: string;

  if (kind === "done") {
    alertBody = "Claude finished";
  } else if (kind === "reset") {
    alertBody = "Usage window reset — fresh start";
  } else {
    const paceText =
      pace > 0 ? ` — runs out in ~${Math.round(pace)}h` : "";
    alertBody = `${usagePercent}% used${paceText}`;
  }

  // TODO: Send via APNs using @fivesheepco/cloudflare-apns2
  // For now, return the payload that would be sent
  const apnsPayload = {
    aps: {
      alert: {
        title: sourceDeviceName ? `${sourceDeviceName}` : "HowlAlert",
        body: alertBody,
      },
      sound: kind === "done" ? "default" : undefined,
      "thread-id": "howlalert",
    },
  };

  return c.json({ ok: true, throttled: false, payload: apnsPayload });
});

export default app;
