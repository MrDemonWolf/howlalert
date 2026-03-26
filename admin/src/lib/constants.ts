export const WORKER_URL =
	process.env.NEXT_PUBLIC_WORKER_URL || "http://localhost:8787";

export const BRAND_COLORS = {
	navy: "#091533",
	navyLight: "#0d1f45",
	navyLighter: "#132a57",
	cyan: "#0FACED",
	amber: "#F5A623",
	red: "#FF3B30",
	green: "#34C759",
} as const;

export const PLAN_TIER_DEFAULTS = {
	free: {
		dailyCostThreshold: 5.0,
		tokenCountThreshold: 100_000,
		sessionCountThreshold: 50,
	},
	pro: {
		dailyCostThreshold: 25.0,
		tokenCountThreshold: 500_000,
		sessionCountThreshold: 250,
	},
	enterprise: {
		dailyCostThreshold: 100.0,
		tokenCountThreshold: 2_000_000,
		sessionCountThreshold: 1000,
	},
} as const;
