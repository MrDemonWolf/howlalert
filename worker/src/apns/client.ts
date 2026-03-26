import * as jose from "jose";
import type { Env } from "../types";

/**
 * APNs client stub.
 *
 * Signs a JWT with ES256 using the team's .p8 key, then sends
 * a push notification via APNs HTTP/2 endpoint.
 *
 * TODO: Fully implement when we have the .p8 key and HTTP/2 support.
 * Cloudflare Workers support HTTP/2 to origin via fetch(), so the
 * actual implementation will use fetch() with the APNs endpoint.
 */
export async function sendPushNotification(
	deviceToken: string,
	payload: Record<string, unknown>,
	env: Env
): Promise<{ success: boolean; error?: string }> {
	try {
		// Generate APNs JWT token
		const privateKey = await jose.importPKCS8(env.APNS_PRIVATE_KEY, "ES256");
		const jwt = await new jose.SignJWT({})
			.setProtectedHeader({ alg: "ES256", kid: env.APNS_KEY_ID })
			.setIssuedAt()
			.setIssuer(env.APNS_TEAM_ID)
			.sign(privateKey);

		const apnsHost =
			env.ENVIRONMENT === "production"
				? "https://api.push.apple.com"
				: "https://api.sandbox.push.apple.com";

		// TODO: Send actual push notification
		// The implementation will use fetch() to POST to:
		// `${apnsHost}/3/device/${deviceToken}`
		// with headers:
		//   authorization: bearer ${jwt}
		//   apns-topic: com.mrdemonwolf.howlalert
		//   apns-push-type: alert
		// and JSON body: payload

		console.log(`[APNs STUB] Would send push to ${deviceToken.slice(0, 8)}...`, {
			host: apnsHost,
			payloadKeys: Object.keys(payload),
			jwtGenerated: !!jwt,
		});

		// Stub: return success for now
		return { success: true };
	} catch (error) {
		const message = error instanceof Error ? error.message : "Unknown APNs error";
		console.error(`[APNs ERROR] Failed to send push: ${message}`);
		return { success: false, error: message };
	}
}
