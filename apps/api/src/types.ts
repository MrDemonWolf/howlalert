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

export interface HookEventPayload {
	session_id?: string;
	tool_name?: string;
	tool_use_id?: string;
	model?: string;
	input_tokens?: number;
	output_tokens?: number;
	cache_read_tokens?: number;
	cache_write_tokens?: number;
	cost_usd?: number;
}

export interface UserPreferences {
	userId: string;
	thresholds: ThresholdConfig[];
	updatedAt: string;
}

export interface ThresholdConfig {
	id: string;
	type: "daily_cost" | "token_count" | "session_count";
	value: number;
	isEnabled: boolean;
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
