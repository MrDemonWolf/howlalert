import { Hono } from "hono";
import type { Env } from "../types";
import { adminAuth } from "../middleware/admin-auth";
import { getPushLog, getPushLogStats } from "../kv/push-log";

export const pushLogRoutes = new Hono<{ Bindings: Env }>();

// Admin-only: get recent push log entries
pushLogRoutes.get("/push-log", adminAuth, async (c) => {
	const limitParam = c.req.query("limit");
	const limit = limitParam ? Math.min(parseInt(limitParam, 10), 500) : 100;

	const entries = await getPushLog(c.env.HOWLALERT_PUSH_LOG, limit);
	return c.json({ entries, count: entries.length });
});

// Admin-only: get push log stats for today
pushLogRoutes.get("/push-log/stats", adminAuth, async (c) => {
	const stats = await getPushLogStats(c.env.HOWLALERT_PUSH_LOG);
	return c.json(stats);
});
