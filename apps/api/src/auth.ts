import type { Context } from "hono";
import type { Env } from "./types";

interface AppleJWK {
	kty: string;
	kid: string;
	use: string;
	alg: string;
	n: string;
	e: string;
}

interface AppleJWKS {
	keys: AppleJWK[];
}

async function getApplePublicKeys(env: Env): Promise<AppleJWK[]> {
	const cacheKey = "apple_public_keys";
	const cached = await env.HOWLALERT_DEVICES.get(cacheKey);
	if (cached) {
		return (JSON.parse(cached) as AppleJWKS).keys;
	}

	const response = await fetch("https://appleid.apple.com/auth/keys");
	if (!response.ok) throw new Error("Failed to fetch Apple public keys");
	const jwks = (await response.json()) as AppleJWKS;

	await env.HOWLALERT_DEVICES.put(cacheKey, JSON.stringify(jwks), {
		expirationTtl: 86400, // 24 hours
	});

	return jwks.keys;
}

function base64urlToArrayBuffer(base64url: string): ArrayBuffer {
	const base64 = base64url.replace(/-/g, "+").replace(/_/g, "/");
	const binary = atob(base64);
	const bytes = new Uint8Array(binary.length);
	for (let i = 0; i < binary.length; i++) {
		bytes[i] = binary.charCodeAt(i);
	}
	return bytes.buffer;
}

async function importRSAPublicKey(jwk: AppleJWK): Promise<CryptoKey> {
	return crypto.subtle.importKey(
		"jwk",
		jwk,
		{ name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
		false,
		["verify"],
	);
}

async function verifyJWTSignature(
	token: string,
	keys: AppleJWK[],
): Promise<Record<string, unknown>> {
	const parts = token.split(".");
	if (parts.length !== 3) throw new Error("Invalid JWT format");

	const [headerB64, payloadB64, signatureB64] = parts as [string, string, string];

	const headerJson = atob(headerB64.replace(/-/g, "+").replace(/_/g, "/"));
	const header = JSON.parse(headerJson) as { kid: string; alg: string };

	const matchingKey = keys.find((k) => k.kid === header.kid);
	if (!matchingKey) throw new Error(`No matching key found for kid: ${header.kid}`);

	const cryptoKey = await importRSAPublicKey(matchingKey);
	const signingInput = new TextEncoder().encode(`${headerB64}.${payloadB64}`);
	const signature = base64urlToArrayBuffer(signatureB64);

	const valid = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", cryptoKey, signature, signingInput);
	if (!valid) throw new Error("JWT signature verification failed");

	const payloadJson = atob(payloadB64.replace(/-/g, "+").replace(/_/g, "/"));
	return JSON.parse(payloadJson) as Record<string, unknown>;
}

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

	const keys = await getApplePublicKeys(c.env);
	const payload = await verifyJWTSignature(token, keys);

	const sub = payload["sub"];
	if (typeof sub !== "string") throw new Error("Invalid token: missing sub claim");

	const iss = payload["iss"];
	if (iss !== "https://appleid.apple.com") throw new Error("Invalid token: wrong issuer");

	const exp = payload["exp"];
	if (typeof exp !== "number" || exp < Date.now() / 1000) throw new Error("Token expired");

	const aud = payload["aud"];
	if (aud !== "com.mrdemonwolf.howlalert") throw new Error("Invalid token: wrong audience");

	return sub;
}

export function unauthorizedResponse(message: string): Response {
	return new Response(JSON.stringify({ error: message }), {
		status: 401,
		headers: { "Content-Type": "application/json" },
	});
}
