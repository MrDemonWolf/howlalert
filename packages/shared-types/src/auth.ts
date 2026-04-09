export interface AdminSession {
  /** Admin secret token (stored in sessionStorage, never persisted) */
  token: string;
  /** ISO 8601 timestamp when the session was created */
  createdAt: string;
}
