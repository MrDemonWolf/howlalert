export type PushTrigger = 'warning' | 'critical' | 'test' | 'manual';

export interface PushPayload {
  deviceToken: string;
  title: string;
  body: string;
  trigger: PushTrigger;
  data?: Record<string, unknown>;
}

export type PushStatus = 'sent' | 'failed' | 'skipped';

export interface PushLogEntry {
  id: string;
  deviceToken: string;
  title: string;
  body: string;
  trigger: PushTrigger;
  status: PushStatus;
  errorMessage?: string;
  sentAt: string;
}
