import type { Context } from "hono";
import type { Env } from "./types";

/**
 * Verify Apple identity token from request Authorization header.
 * Returns the user ID if valid, throws otherwise.
 */
export async function verifyAppleToken(c: Context<{ Bindings: Env }>): Promise<string> {
	const authorization = c.req.header("Authorization");
	if (!authorization?.startsWith("Bearer ")) {
		throw new Error("Missing or invalid Authorization header");
	}

	const token = authorization.slice(7);

	// In development, accept a simple token format for testing
	if (c.env.ENVIRONMENT === "development") {
		return `dev_user_${token.slice(0, 8)}`;
	}

	// Production: verify Apple identity token
	// Apple's public keys endpoint: https://appleid.apple.com/auth/keys
	const [, payloadB64] = token.split(".");
	if (!payloadB64) throw new Error("Invalid token format");

	const payload = JSON.parse(atob(payloadB64)) as Record<string, unknown>;
	const sub = payload["sub"];
	if (typeof sub !== "string") throw new Error("Invalid token: missing sub claim");

	// TODO: Implement full JWT verification with Apple's public keys
	return sub;
}

export function unauthorizedResponse(message: string): Response {
	return new Response(JSON.stringify({ error: message }), {
		status: 401,
		headers: { "Content-Type": "application/json" },
	});
}
