import { Hono } from "hono";
import type { Bindings } from "../lib/bindings";
import { registerSchema } from "../lib/schemas";

const app = new Hono<{ Bindings: Bindings }>();

app.post("/register", async (c) => {
  const body = await c.req.json();
  const parsed = registerSchema.safeParse(body);

  if (!parsed.success) {
    return c.json({ error: "Invalid request", details: parsed.error.flatten() }, 400);
  }

  const { deviceToken, cloudkitUserId, deviceName, platform } = parsed.data;

  const key = `${cloudkitUserId}:${platform}`;
  await c.env.HOWLALERT_DEVICES.put(
    key,
    JSON.stringify({ deviceToken, deviceName, registeredAt: new Date().toISOString() }),
    { expirationTtl: 30 * 24 * 3600 } // 30 days
  );

  return c.json({ ok: true, key });
});

export default app;
