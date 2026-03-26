export interface Env {
	HOWLALERT_CONFIG: KVNamespace;
	HOWLALERT_PUSH_LOG: KVNamespace;
	ENVIRONMENT: string;
	CONFIG_AUTH_TOKEN: string;
	APNS_KEY_ID: string;
	APNS_TEAM_ID: string;
	APNS_PRIVATE_KEY: string;
}

export interface LimitConfig {
	multiplier: number;
	activeFrom: string | null;
	activeUntil: string | null;
	offPeakOnly: boolean;
	offPeakWindows: {
		weekday: { startUTC: number; endUTC: number }[];
		weekend: "all" | { startUTC: number; endUTC: number }[];
	};
	reason: string;
	updatedAt: string;
	plans: Record<string, { sessionLimit: number | null; weeklyLimit: number | null }>;
}

export interface PushPayload {
	secret: string;
	deviceToken: string;
	consumed: number;
	limit: number;
	model: string;
	windowStart: string;
	windowEnd: string;
	paceStatus: "inDebt" | "onTrack" | "inReserve";
	pacePercent: number;
}

export interface PushLogEntry {
	id: string;
	timestamp: string;
	deviceToken: string;
	model: string;
	usagePercent: number;
	paceStatus: string;
	apnsSuccess: boolean;
	error?: string;
}

export interface DeviceInfo {
	deviceToken: string;
	deviceName?: string;
	osVersion?: string;
	lastSeen: string;
}
