import type { LimitConfig, PushLogEntry } from "@/types";

const WORKER_URL =
	process.env.NEXT_PUBLIC_WORKER_URL || "http://localhost:8787";

function getAuthHeaders(): HeadersInit {
	const token =
		typeof document !== "undefined"
			? document.cookie
					.split("; ")
					.find((c) => c.startsWith("admin_token="))
					?.split("=")[1]
			: undefined;
	return {
		"Content-Type": "application/json",
		...(token ? { Authorization: `Bearer ${token}` } : {}),
	};
}

export async function getConfig(): Promise<LimitConfig> {
	const res = await fetch(`${WORKER_URL}/admin/config`, {
		headers: getAuthHeaders(),
	});
	if (!res.ok) throw new Error(`Failed to fetch config: ${res.status}`);
	return res.json();
}

export async function updateConfig(
	config: Partial<LimitConfig>,
): Promise<void> {
	const res = await fetch(`${WORKER_URL}/admin/config`, {
		method: "PUT",
		headers: getAuthHeaders(),
		body: JSON.stringify(config),
	});
	if (!res.ok) throw new Error(`Failed to update config: ${res.status}`);
}

export async function getPushLog(): Promise<PushLogEntry[]> {
	const res = await fetch(`${WORKER_URL}/admin/push-log`, {
		headers: getAuthHeaders(),
	});
	if (!res.ok) throw new Error(`Failed to fetch push log: ${res.status}`);
	return res.json();
}

export async function verifyAuth(token: string): Promise<boolean> {
	const res = await fetch(`${WORKER_URL}/admin/auth/verify`, {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ token }),
	});
	if (!res.ok) return false;
	const data = await res.json();
	return data.valid === true;
}
