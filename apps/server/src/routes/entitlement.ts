import { Hono } from "hono";
import { eq } from "drizzle-orm";
import { createDb, schema } from "@howlalert/db";
import type { Bindings } from "../lib/bindings";
import { entitlementSyncSchema } from "../lib/schemas";

const app = new Hono<{ Bindings: Bindings }>();

// RevenueCat webhook → D1 upsert
app.post("/entitlement/sync", async (c) => {
  // Verify webhook secret
  const authHeader = c.req.header("Authorization");
  if (authHeader !== `Bearer ${c.env.REVENUECAT_WEBHOOK_SECRET}`) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const body = await c.req.json();
  const parsed = entitlementSyncSchema.safeParse(body);

  if (!parsed.success) {
    return c.json({ error: "Invalid payload", details: parsed.error.flatten() }, 400);
  }

  const { event } = parsed.data;
  const isActive =
    event.type === "INITIAL_PURCHASE" ||
    event.type === "RENEWAL" ||
    event.type === "UNCANCELLATION" ||
    event.type === "PRODUCT_CHANGE";

  const expiresAt = event.expiration_at_ms
    ? new Date(event.expiration_at_ms)
    : null;

  const db = createDb(c.env.DB);

  await db
    .insert(schema.users)
    .values({
      cloudkitUserId: event.app_user_id,
      rcAppUserId: event.app_user_id,
      entitlementActive: isActive,
      expiresAt,
      updatedAt: new Date(),
    })
    .onConflictDoUpdate({
      target: schema.users.cloudkitUserId,
      set: {
        entitlementActive: isActive,
        expiresAt,
        updatedAt: new Date(),
      },
    });

  return c.json({ ok: true, userId: event.app_user_id, active: isActive });
});

export default app;
