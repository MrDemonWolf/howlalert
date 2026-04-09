import type { RemoteConfig } from './config';
import type { PushPayload, PushLogEntry } from './push';
import type { DeviceInfo } from './device';

// ── Auth ─────────────────────────────────────────────────────────────────────

export interface VerifyRequest {
  secret: string;
}

export interface VerifyResponse {
  valid: boolean;
}

// ── Push ─────────────────────────────────────────────────────────────────────

export type PushRequest = PushPayload;

export interface PushResponse {
  ok: boolean;
  queued: boolean;
}

// ── Config ───────────────────────────────────────────────────────────────────

export type GetConfigResponse = RemoteConfig | Record<string, never>;

export type UpdateConfigRequest = Partial<RemoteConfig>;

export interface UpdateConfigResponse {
  ok: boolean;
}

// ── Push Log ─────────────────────────────────────────────────────────────────

export interface GetPushLogResponse {
  entries: PushLogEntry[];
  cursor: string | null;
}

export interface PushLogStats {
  total: number;
  last24h: number;
  last7d: number;
}

// ── Devices ──────────────────────────────────────────────────────────────────

export interface GetDevicesResponse {
  devices: DeviceInfo[];
}
