export interface Env {
	HOWLALERT_DEVICES: KVNamespace;
	DB: D1Database;
	ENVIRONMENT: string;
	APNS_KEY_ID?: string;
	APNS_TEAM_ID?: string;
	APNS_PRIVATE_KEY?: string;
	APNS_BUNDLE_ID?: string;
}

export interface DeviceRegistration {
	deviceToken: string;
	platform: "ios" | "watchos";
	userId: string;
	registeredAt: string;
}

export interface UsageEventPayload {
	sessionId: string;
	timestamp: string;
	model: string;
	inputTokens: number;
	outputTokens: number;
	cacheReadTokens: number;
	cacheWriteTokens: number;
	costUSD: number;
}

export interface NotificationPayload {
	aps: {
		alert: {
			title: string;
			body: string;
		};
		badge?: number;
		sound?: string;
		"content-available"?: number;
	};
	[key: string]: unknown;
}

export interface HistoryEntry {
	id: string;
	userId: string;
	sessionId: string;
	timestamp: string;
	model: string;
	inputTokens: number;
	outputTokens: number;
	cacheReadTokens: number;
	cacheWriteTokens: number;
	costUSD: number;
	createdAt: string;
}
