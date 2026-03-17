import type { Env, NotificationPayload } from "./types";

/**
 * Send a push notification via Apple Push Notification service (APNs).
 * Uses HTTP/2 JWT-authenticated requests.
 */
export async function sendAPNsNotification(
	env: Env,
	deviceToken: string,
	payload: NotificationPayload,
	sandbox = false,
): Promise<void> {
	const { APNS_KEY_ID, APNS_TEAM_ID, APNS_PRIVATE_KEY, APNS_BUNDLE_ID } = env;

	if (!APNS_KEY_ID || !APNS_TEAM_ID || !APNS_PRIVATE_KEY || !APNS_BUNDLE_ID) {
		console.warn("APNs credentials not configured — skipping push notification");
		return;
	}

	const host = sandbox
		? "https://api.sandbox.push.apple.com"
		: "https://api.push.apple.com";

	const token = await generateAPNsJWT(APNS_TEAM_ID, APNS_KEY_ID, APNS_PRIVATE_KEY);
	const url = `${host}/3/device/${deviceToken}`;

	const response = await fetch(url, {
		method: "POST",
		headers: {
			authorization: `bearer ${token}`,
			"apns-topic": APNS_BUNDLE_ID,
			"apns-push-type": "alert",
			"content-type": "application/json",
		},
		body: JSON.stringify(payload),
	});

	if (!response.ok) {
		const reason = await response.text();
		throw new Error(`APNs error ${response.status}: ${reason}`);
	}
}

async function generateAPNsJWT(teamId: string, keyId: string, privateKeyPEM: string): Promise<string> {
	const header = { alg: "ES256", kid: keyId };
	const payload = { iss: teamId, iat: Math.floor(Date.now() / 1000) };

	const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
	const payloadB64 = btoa(JSON.stringify(payload)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
	const signingInput = `${headerB64}.${payloadB64}`;

	const key = await importPrivateKey(privateKeyPEM);
	const signature = await crypto.subtle.sign({ name: "ECDSA", hash: "SHA-256" }, key, new TextEncoder().encode(signingInput));
	const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature))).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

	return `${signingInput}.${sigB64}`;
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
	const pemBody = pem.replace(/-----.*?-----/g, "").replace(/\s/g, "");
	const der = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

	return crypto.subtle.importKey("pkcs8", der, { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"]);
}
