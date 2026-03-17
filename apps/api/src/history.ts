import type { D1Database } from "@cloudflare/workers-types";
import type { HistoryEntry, UsageEventPayload } from "./types";

export async function initSchema(db: D1Database): Promise<void> {
	await db.exec(`
		CREATE TABLE IF NOT EXISTS usage_events (
			id TEXT PRIMARY KEY,
			user_id TEXT NOT NULL,
			session_id TEXT NOT NULL,
			timestamp TEXT NOT NULL,
			model TEXT NOT NULL,
			input_tokens INTEGER NOT NULL DEFAULT 0,
			output_tokens INTEGER NOT NULL DEFAULT 0,
			cache_read_tokens INTEGER NOT NULL DEFAULT 0,
			cache_write_tokens INTEGER NOT NULL DEFAULT 0,
			cost_usd REAL NOT NULL DEFAULT 0,
			created_at TEXT NOT NULL DEFAULT (datetime('now'))
		);

		CREATE INDEX IF NOT EXISTS idx_usage_events_user_id ON usage_events(user_id);
		CREATE INDEX IF NOT EXISTS idx_usage_events_timestamp ON usage_events(timestamp);
	`);
}

export async function insertEvent(
	db: D1Database,
	userId: string,
	event: UsageEventPayload,
): Promise<void> {
	const id = crypto.randomUUID();
	await db
		.prepare(`
			INSERT INTO usage_events
				(id, user_id, session_id, timestamp, model, input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, cost_usd)
			VALUES
				(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		`)
		.bind(
			id,
			userId,
			event.sessionId,
			event.timestamp,
			event.model,
			event.inputTokens,
			event.outputTokens,
			event.cacheReadTokens,
			event.cacheWriteTokens,
			event.costUSD,
		)
		.run();
}

export async function getHistory(
	db: D1Database,
	userId: string,
	limit = 50,
	offset = 0,
): Promise<HistoryEntry[]> {
	const result = await db
		.prepare(`
			SELECT
				id, user_id as userId, session_id as sessionId, timestamp, model,
				input_tokens as inputTokens, output_tokens as outputTokens,
				cache_read_tokens as cacheReadTokens, cache_write_tokens as cacheWriteTokens,
				cost_usd as costUSD, created_at as createdAt
			FROM usage_events
			WHERE user_id = ?
			ORDER BY timestamp DESC
			LIMIT ? OFFSET ?
		`)
		.bind(userId, limit, offset)
		.all<HistoryEntry>();

	return result.results;
}

export async function deleteAllUserEvents(db: D1Database, userId: string): Promise<number> {
	const result = await db
		.prepare("DELETE FROM usage_events WHERE user_id = ?")
		.bind(userId)
		.run();
	return result.meta.changes ?? 0;
}

export async function getDailySummary(
	db: D1Database,
	userId: string,
	date: string,
): Promise<{ totalCost: number; totalInputTokens: number; totalOutputTokens: number; eventCount: number }> {
	const result = await db
		.prepare(`
			SELECT
				COALESCE(SUM(cost_usd), 0) as totalCost,
				COALESCE(SUM(input_tokens), 0) as totalInputTokens,
				COALESCE(SUM(output_tokens), 0) as totalOutputTokens,
				COUNT(*) as eventCount
			FROM usage_events
			WHERE user_id = ? AND DATE(timestamp) = DATE(?)
		`)
		.bind(userId, date)
		.first<{ totalCost: number; totalInputTokens: number; totalOutputTokens: number; eventCount: number }>();

	return result ?? { totalCost: 0, totalInputTokens: 0, totalOutputTokens: 0, eventCount: 0 };
}
