import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import type { Env, DeviceRegistration } from "./types";
import { verifyAppleToken, unauthorizedResponse } from "./auth";
import { sendAPNsNotification } from "./apns";
import { insertEvent, getHistory, getDailySummary, deleteAllUserEvents } from "./history";

const app = new Hono<{ Bindings: Env }>();

app.use("*", logger());
app.use("*", cors({ origin: "*", allowMethods: ["GET", "POST", "DELETE"] }));

// Health check
app.get("/status", (c) => {
	return c.json({ status: "ok", version: "0.1.0", environment: c.env.ENVIRONMENT });
});

// Register a device for push notifications
app.post("/register", async (c) => {
	let userId: string;
	try {
		userId = await verifyAppleToken(c);
	} catch {
		return unauthorizedResponse("Invalid authorization token");
	}

	const body = await c.req.json<{ device_token: string; platform: string }>();
	if (!body.device_token || !body.platform) {
		return c.json({ error: "Missing device_token or platform" }, 400);
	}

	const registration: DeviceRegistration = {
		deviceToken: body.device_token,
		platform: body.platform as "ios" | "watchos",
		userId,
		registeredAt: new Date().toISOString(),
	};

	await c.env.HOWLALERT_DEVICES.put(`device:${userId}:${body.device_token}`, JSON.stringify(registration));

	return c.json({ success: true, message: "Device registered" });
});

// Receive a usage event and optionally trigger push
app.post("/event", async (c) => {
	let userId: string;
	try {
		userId = await verifyAppleToken(c);
	} catch {
		return unauthorizedResponse("Invalid authorization token");
	}

	const event = await c.req.json();

	await insertEvent(c.env.DB, userId, event);

	// Check if any threshold alerts should fire (placeholder logic)
	const today = new Date().toISOString().split("T")[0] ?? new Date().toISOString();
	const summary = await getDailySummary(c.env.DB, userId, today);

	if (summary.totalCost >= 5.0) {
		// Get all registered devices for this user
		const keys = await c.env.HOWLALERT_DEVICES.list({ prefix: `device:${userId}:` });
		for (const key of keys.keys) {
			const deviceData = await c.env.HOWLALERT_DEVICES.get(key.name);
			if (!deviceData) continue;
			const device = JSON.parse(deviceData) as DeviceRegistration;

			await sendAPNsNotification(c.env, device.deviceToken, {
				aps: {
					alert: {
						title: "HowlAlert",
						body: `Daily cost reached $${summary.totalCost.toFixed(2)}`,
					},
					sound: "default",
				},
				costUSD: summary.totalCost,
			});
		}
	}

	return c.json({ success: true, summary });
});

// Get usage history
app.get("/history", async (c) => {
	let userId: string;
	try {
		userId = await verifyAppleToken(c);
	} catch {
		return unauthorizedResponse("Invalid authorization token");
	}

	const limit = parseInt(c.req.query("limit") ?? "50");
	const offset = parseInt(c.req.query("offset") ?? "0");
	const events = await getHistory(c.env.DB, userId, limit, offset);

	return c.json({ events, limit, offset });
});

// Get device list for user
app.get("/device", async (c) => {
	let userId: string;
	try {
		userId = await verifyAppleToken(c);
	} catch {
		return unauthorizedResponse("Invalid authorization token");
	}

	const keys = await c.env.HOWLALERT_DEVICES.list({ prefix: `device:${userId}:` });
	const devices: DeviceRegistration[] = [];

	for (const key of keys.keys) {
		const data = await c.env.HOWLALERT_DEVICES.get(key.name);
		if (data) devices.push(JSON.parse(data) as DeviceRegistration);
	}

	return c.json({ devices });
});

// Delete account — removes all devices and usage history
app.delete("/account", async (c) => {
	let userId: string;
	try {
		userId = await verifyAppleToken(c);
	} catch {
		return unauthorizedResponse("Invalid authorization token");
	}

	const keys = await c.env.HOWLALERT_DEVICES.list({ prefix: `device:${userId}:` });
	for (const key of keys.keys) {
		await c.env.HOWLALERT_DEVICES.delete(key.name);
	}

	const eventsRemoved = await deleteAllUserEvents(c.env.DB, userId);

	return c.json({ success: true, devicesRemoved: keys.keys.length, eventsRemoved });
});

// Unregister a device
app.delete("/device/:token", async (c) => {
	let userId: string;
	try {
		userId = await verifyAppleToken(c);
	} catch {
		return unauthorizedResponse("Invalid authorization token");
	}

	const token = c.req.param("token");
	await c.env.HOWLALERT_DEVICES.delete(`device:${userId}:${token}`);

	return c.json({ success: true });
});

export default app;
