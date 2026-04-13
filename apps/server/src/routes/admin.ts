import { Hono } from "hono";
import { sql } from "drizzle-orm";
import { createDb, schema } from "@howlalert/db";
import type { Bindings } from "../lib/bindings";

const app = new Hono<{ Bindings: Bindings }>();

// Protected admin endpoint for monitoring free-tier usage
app.get("/admin/usage", async (c) => {
  const secret = c.req.header("X-Admin-Secret");
  if (secret !== c.env.ADMIN_SECRET) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const db = createDb(c.env.DB);

  const [userCount] = await db
    .select({ count: sql<number>`count(*)` })
    .from(schema.users);

  const [activeCount] = await db
    .select({ count: sql<number>`count(*)` })
    .from(schema.users)
    .where(sql`${schema.users.entitlementActive} = 1`);

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const [pushesToday] = await db
    .select({ count: sql<number>`count(*)` })
    .from(schema.pushLog)
    .where(sql`${schema.pushLog.createdAt} >= ${today}`);

  return c.json({
    users: { total: userCount.count, active: activeCount.count },
    pushesToday: pushesToday.count,
    timestamp: new Date().toISOString(),
  });
});

export default app;
