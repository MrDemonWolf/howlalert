export interface DeviceInfo {
  /** APNs device token (hex string) */
  deviceToken: string;
  /** Human-readable device name */
  name: string;
  /** Platform the device is running */
  platform: 'ios' | 'watchos';
  /** App version */
  appVersion: string;
  /** ISO 8601 registration timestamp */
  registeredAt: string;
  /** ISO 8601 last seen timestamp */
  lastSeenAt: string;
}
