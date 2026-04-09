import type { RemoteConfig, PushLogEntry } from '@howlalert/shared-types';

const API_BASE =
  process.env['NEXT_PUBLIC_WORKER_URL'] ?? 'https://howlalert-worker.mrdemonwolf.workers.dev';

export interface PushLogStats {
  total: number;
  successful: number;
  failed: number;
  successRate: number;
}

class ApiError extends Error {
  constructor(
    public readonly status: number,
    message: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return sessionStorage.getItem('howlalert_admin_token');
}

async function apiFetch<T>(
  path: string,
  options: RequestInit & { token?: string } = {}
): Promise<T> {
  const { token: explicitToken, ...fetchOptions } = options;
  const token = explicitToken ?? getToken() ?? '';
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(fetchOptions.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const res = await fetch(`${API_BASE}${path}`, { ...fetchOptions, headers });

  if (!res.ok) {
    throw new ApiError(res.status, `API error ${res.status}: ${path}`);
  }

  return res.json() as Promise<T>;
}

export const api = {
  get: <T>(path: string, token?: string) =>
    apiFetch<T>(path, token !== undefined ? { method: 'GET', token } : { method: 'GET' }),
  post: <T>(path: string, body: unknown, token?: string) =>
    apiFetch<T>(
      path,
      token !== undefined
        ? { method: 'POST', body: JSON.stringify(body), token }
        : { method: 'POST', body: JSON.stringify(body) }
    ),
};

export async function getConfig(): Promise<RemoteConfig> {
  return api.get<RemoteConfig>('/config');
}

export async function updateConfig(config: RemoteConfig): Promise<{ ok: boolean }> {
  return api.post<{ ok: boolean }>('/config', config);
}

export async function getPushLog(): Promise<PushLogEntry[]> {
  return api.get<PushLogEntry[]>('/push-log');
}

export async function getPushLogStats(): Promise<PushLogStats> {
  const entries = await getPushLog();
  const total = entries.length;
  const successful = entries.filter((e) => e.status === 'sent').length;
  const failed = entries.filter((e) => e.status === 'failed').length;
  const successRate = total > 0 ? Math.round((successful / total) * 100) : 0;
  return { total, successful, failed, successRate };
}

export { ApiError };
