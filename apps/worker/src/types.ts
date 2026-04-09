export interface Env {
	// KV Namespaces
	CONFIG_KV: KVNamespace;
	PUSH_LOG_KV: KVNamespace;

	// Secrets
	ADMIN_SECRET: string;
	APNS_KEY_ID: string;
	APNS_TEAM_ID: string;
	APNS_PRIVATE_KEY: string;
	APNS_BUNDLE_ID: string;
}
