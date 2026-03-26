export interface LimitConfig {
	multiplier: number;
	dailyCostThreshold: number;
	tokenCountThreshold: number;
	sessionCountThreshold: number;
	type: "daily_cost" | "token_count" | "session_count";
	enabled: boolean;
}

export interface PushLogEntry {
	id: string;
	userId: string;
	deviceToken: string;
	payload: PushPayload;
	status: "delivered" | "failed" | "pending";
	sentAt: string;
	error?: string;
}

export interface PushPayload {
	title: string;
	body: string;
	badge?: number;
	sound?: string;
	data?: Record<string, unknown>;
}

export interface DeviceInfo {
	deviceToken: string;
	userId: string;
	platform: "ios" | "macos" | "watchos";
	appVersion: string;
	registeredAt: string;
	lastSeenAt: string;
}
