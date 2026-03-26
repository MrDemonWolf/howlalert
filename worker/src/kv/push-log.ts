import type { PushLogEntry } from "../types";

const LOG_PREFIX = "push-log:";
const MAX_LOG_ENTRIES = 500;

export async function appendPushLog(kv: KVNamespace, entry: PushLogEntry): Promise<void> {
	const key = `${LOG_PREFIX}${entry.timestamp}:${entry.id}`;
	// Store individual entries with a 30-day TTL
	await kv.put(key, JSON.stringify(entry), { expirationTtl: 30 * 24 * 60 * 60 });
}

export async function getPushLog(kv: KVNamespace, limit = 100): Promise<PushLogEntry[]> {
	const entries: PushLogEntry[] = [];
	let cursor: string | undefined;
	let totalFetched = 0;

	// List keys in reverse chronological order (KV lists alphabetically,
	// and our timestamp prefix ensures chronological ordering)
	while (totalFetched < MAX_LOG_ENTRIES) {
		const listResult = await kv.list({
			prefix: LOG_PREFIX,
			limit: Math.min(limit, 1000),
			cursor,
		});

		for (const key of listResult.keys) {
			const raw = await kv.get(key.name);
			if (raw) {
				entries.push(JSON.parse(raw) as PushLogEntry);
				totalFetched++;
				if (totalFetched >= limit) break;
			}
		}

		if (listResult.list_complete || totalFetched >= limit) break;
		cursor = listResult.cursor;
	}

	// Sort newest first
	entries.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
	return entries.slice(0, limit);
}

export async function getPushLogStats(kv: KVNamespace): Promise<{
	totalToday: number;
	successToday: number;
	failureToday: number;
	successRate: number;
}> {
	const today = new Date().toISOString().split("T")[0];
	const todayPrefix = `${LOG_PREFIX}${today}`;

	const entries: PushLogEntry[] = [];
	let cursor: string | undefined;

	while (true) {
		const listResult = await kv.list({
			prefix: todayPrefix,
			limit: 1000,
			cursor,
		});

		for (const key of listResult.keys) {
			const raw = await kv.get(key.name);
			if (raw) {
				entries.push(JSON.parse(raw) as PushLogEntry);
			}
		}

		if (listResult.list_complete) break;
		cursor = listResult.cursor;
	}

	const totalToday = entries.length;
	const successToday = entries.filter((e) => e.apnsSuccess).length;
	const failureToday = totalToday - successToday;
	const successRate = totalToday > 0 ? (successToday / totalToday) * 100 : 0;

	return { totalToday, successToday, failureToday, successRate };
}
