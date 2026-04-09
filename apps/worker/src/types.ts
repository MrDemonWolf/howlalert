export interface Env {
  HOWLALERT_CONFIG: KVNamespace
  HOWLALERT_PUSH_LOG: KVNamespace
  ADMIN_AUTH_TOKEN: string
  APNS_AUTH_KEY: string
  APNS_KEY_ID: string
  APNS_TEAM_ID: string
  WORKER_ENV: string
}

export interface RemoteConfig {
  multiplier: number
  activePromo: string | null
  planLimits: Record<string, number>
  offPeakSchedule: { startHour: number; endHour: number } | null
  updatedAt: string | null
}

export interface PushLogEntry {
  id: string
  deviceToken: string
  plan: string
  usagePercent: number
  paceStatus: string
  apnsStatus: number
  apnsResult: 'delivered' | 'failed'
  sentAt: string
}

export const DEFAULT_CONFIG: RemoteConfig = {
  multiplier: 1.0,
  activePromo: null,
  planLimits: {
    free: 40000,
    pro: 200000,
    max5: 1000000,
    max20: 4000000,
  },
  offPeakSchedule: null,
  updatedAt: null,
}
