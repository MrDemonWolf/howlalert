const TOKEN_COOKIE = "admin_token";

export function login(token: string): void {
	document.cookie = `${TOKEN_COOKIE}=${token}; path=/; max-age=${60 * 60 * 24 * 7}; SameSite=Strict`;
}

export function logout(): void {
	document.cookie = `${TOKEN_COOKIE}=; path=/; max-age=0`;
}

export function getSession(): string | null {
	if (typeof document === "undefined") return null;
	const match = document.cookie
		.split("; ")
		.find((c) => c.startsWith(`${TOKEN_COOKIE}=`));
	return match ? match.split("=")[1] || null : null;
}
