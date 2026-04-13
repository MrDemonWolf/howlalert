export type Bindings = {
  DB: D1Database;
  HOWLALERT_DEVICES: KVNamespace;
  HOWLALERT_PUSH_LOG: KVNamespace;
  APNS_TEAM_ID: string;
  APNS_KEY_ID: string;
  APNS_SIGNING_KEY: string;
  REVENUECAT_WEBHOOK_SECRET: string;
  ADMIN_SECRET: string;
  ENVIRONMENT: string;
};
