import { Hono } from "hono";
import type { Env, PushPayload, PushLogEntry } from "../types";
import { getConfig } from "../kv/config";
import { appendPushLog } from "../kv/push-log";
import { sendPushNotification } from "../apns/client";

export const pushRoutes = new Hono<{ Bindings: Env }>();

pushRoutes.post("/push", async (c) => {
	const body = await c.req.json<PushPayload>();

	// Validate required fields
	if (!body.secret || !body.deviceToken || body.consumed == null || body.limit == null) {
		return c.json({ error: "Missing required fields: secret, deviceToken, consumed, limit" }, 400);
	}

	// Validate secret matches
	if (body.secret !== c.env.CONFIG_AUTH_TOKEN) {
		return c.json({ error: "Invalid secret" }, 401);
	}

	// Fetch current config for multiplier
	const config = await getConfig(c.env.HOWLALERT_CONFIG);

	const effectiveLimit = body.limit * config.multiplier;
	const usagePercent = effectiveLimit > 0 ? (body.consumed / effectiveLimit) * 100 : 0;

	// Build APNs payload
	const apnsPayload = {
		aps: {
			alert: {
				title: "HowlAlert",
				subtitle: `${body.model} Usage`,
				body: `${Math.round(usagePercent)}% consumed (${body.consumed}/${effectiveLimit})`,
			},
			sound: "default",
			"thread-id": `howlalert-${body.model}`,
		},
		consumed: body.consumed,
		limit: effectiveLimit,
		multiplier: config.multiplier,
		model: body.model,
		paceStatus: body.paceStatus,
		pacePercent: body.pacePercent,
		windowStart: body.windowStart,
		windowEnd: body.windowEnd,
	};

	// Send push notification (stub for now)
	const result = await sendPushNotification(body.deviceToken, apnsPayload, c.env);

	// Log the push attempt
	const logEntry: PushLogEntry = {
		id: crypto.randomUUID(),
		timestamp: new Date().toISOString(),
		deviceToken: body.deviceToken.slice(0, 8) + "...",
		model: body.model,
		usagePercent: Math.round(usagePercent * 100) / 100,
		paceStatus: body.paceStatus,
		apnsSuccess: result.success,
		error: result.error,
	};

	await appendPushLog(c.env.HOWLALERT_PUSH_LOG, logEntry);

	return c.json({
		success: result.success,
		effectiveLimit,
		multiplier: config.multiplier,
		usagePercent: Math.round(usagePercent * 100) / 100,
		logId: logEntry.id,
		error: result.error,
	});
});
