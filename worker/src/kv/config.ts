import type { LimitConfig } from "../types";

const CONFIG_KEY = "limit-config";

const DEFAULT_CONFIG: LimitConfig = {
	multiplier: 1,
	activeFrom: null,
	activeUntil: null,
	offPeakOnly: false,
	offPeakWindows: {
		weekday: [],
		weekend: "all",
	},
	reason: "Default configuration",
	updatedAt: new Date().toISOString(),
	plans: {},
};

export async function getConfig(kv: KVNamespace): Promise<LimitConfig> {
	const raw = await kv.get(CONFIG_KEY);
	if (!raw) return { ...DEFAULT_CONFIG };
	return JSON.parse(raw) as LimitConfig;
}

export async function setConfig(kv: KVNamespace, config: LimitConfig): Promise<void> {
	await kv.put(CONFIG_KEY, JSON.stringify(config));
}
