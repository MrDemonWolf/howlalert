import { createMiddleware } from "hono/factory";
import * as jose from "jose";
import type { Env } from "../types";

const COOKIE_NAME = "howlalert-admin-session";
const JWT_ISSUER = "howlalert-worker";
const JWT_AUDIENCE = "howlalert-admin";

export const adminAuth = createMiddleware<{ Bindings: Env }>(async (c, next) => {
	const authToken = c.env.CONFIG_AUTH_TOKEN;
	if (!authToken) {
		return c.json({ error: "Server misconfigured: no auth token set" }, 500);
	}

	// Check Authorization: Bearer <token> header
	const authHeader = c.req.header("Authorization");
	if (authHeader) {
		const parts = authHeader.split(" ");
		if (parts.length === 2 && parts[0] === "Bearer" && parts[1] === authToken) {
			await next();
			return;
		}
	}

	// Check session cookie with signed JWT
	const cookie = getCookie(c.req.raw, COOKIE_NAME);
	if (cookie) {
		try {
			const secret = new TextEncoder().encode(authToken);
			await jose.jwtVerify(cookie, secret, {
				issuer: JWT_ISSUER,
				audience: JWT_AUDIENCE,
			});
			await next();
			return;
		} catch {
			// Invalid or expired JWT — fall through to 401
		}
	}

	return c.json({ error: "Unauthorized" }, 401);
});

export async function createSessionJWT(authToken: string): Promise<string> {
	const secret = new TextEncoder().encode(authToken);
	return new jose.SignJWT({ role: "admin" })
		.setProtectedHeader({ alg: "HS256" })
		.setIssuedAt()
		.setIssuer(JWT_ISSUER)
		.setAudience(JWT_AUDIENCE)
		.setExpirationTime("7d")
		.sign(secret);
}

function getCookie(request: Request, name: string): string | undefined {
	const cookieHeader = request.headers.get("Cookie");
	if (!cookieHeader) return undefined;

	const cookies = cookieHeader.split(";").map((c) => c.trim());
	for (const cookie of cookies) {
		const [key, ...rest] = cookie.split("=");
		if (key === name) {
			return rest.join("=");
		}
	}
	return undefined;
}
