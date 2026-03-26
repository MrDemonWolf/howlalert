import { Hono } from "hono";
import type { Env, LimitConfig } from "../types";
import { adminAuth, createSessionJWT } from "../middleware/admin-auth";
import { getConfig, setConfig } from "../kv/config";

export const configRoutes = new Hono<{ Bindings: Env }>();

// Public: read current limit config
configRoutes.get("/config", async (c) => {
	const config = await getConfig(c.env.HOWLALERT_CONFIG);
	return c.json(config);
});

// Admin-only: update limit config
configRoutes.post("/config", adminAuth, async (c) => {
	const body = await c.req.json<Partial<LimitConfig>>();

	const existing = await getConfig(c.env.HOWLALERT_CONFIG);
	const updated: LimitConfig = {
		...existing,
		...body,
		updatedAt: new Date().toISOString(),
	};

	await setConfig(c.env.HOWLALERT_CONFIG, updated);
	return c.json({ success: true, config: updated });
});

// Auth: verify token and set session cookie
configRoutes.post("/auth/verify", async (c) => {
	const body = await c.req.json<{ token: string }>();

	if (!body.token || body.token !== c.env.CONFIG_AUTH_TOKEN) {
		return c.json({ error: "Invalid token" }, 401);
	}

	const jwt = await createSessionJWT(c.env.CONFIG_AUTH_TOKEN);

	c.header(
		"Set-Cookie",
		`howlalert-admin-session=${jwt}; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=${7 * 24 * 60 * 60}`
	);

	return c.json({ success: true });
});
