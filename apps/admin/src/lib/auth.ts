const SESSION_KEY = 'howlalert_admin_token';

export function getSession(): string | null {
  if (typeof window === 'undefined') return null;
  return sessionStorage.getItem(SESSION_KEY);
}

export function setSession(token: string): void {
  sessionStorage.setItem(SESSION_KEY, token);
}

export function clearSession(): void {
  sessionStorage.removeItem(SESSION_KEY);
}

export function isAuthenticated(): boolean {
  return getSession() !== null;
}

export async function logout(): Promise<void> {
  clearSession();
  try {
    await fetch('/api/auth/session', { method: 'DELETE' });
  } catch {
    // best-effort
  }
  window.location.href = '/login';
}
