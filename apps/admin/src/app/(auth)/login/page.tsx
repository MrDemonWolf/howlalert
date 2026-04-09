'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const router = useRouter();
  const [token, setToken] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);

    const workerUrl =
      process.env['NEXT_PUBLIC_WORKER_URL'] ??
      'https://howlalert-worker.mrdemonwolf.workers.dev';

    try {
      const res = await fetch(`${workerUrl}/auth/verify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token }),
      });

      if (!res.ok) {
        setError('Invalid admin token.');
        return;
      }

      // Store token in sessionStorage for API calls
      sessionStorage.setItem('howlalert_admin_token', token);

      // Set the session cookie via the API route
      await fetch('/api/auth/session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token }),
      });

      router.push('/dashboard');
    } catch {
      setError('Could not reach the worker. Check your connection.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'var(--color-bg)',
        padding: '1rem',
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: '24rem',
          background: 'var(--color-surface)',
          border: '1px solid var(--color-border)',
          borderRadius: '1rem',
          padding: '2rem',
        }}
      >
        <div style={{ textAlign: 'center', marginBottom: '1.75rem' }}>
          <div style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>🐺</div>
          <h1 style={{ fontSize: '1.5rem', fontWeight: 700, color: 'var(--color-cyan)', margin: 0 }}>
            HowlAlert
          </h1>
          <p style={{ color: 'var(--color-muted)', fontSize: '0.875rem', marginTop: '0.25rem' }}>
            Admin Access
          </p>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.375rem' }}>
            <label
              htmlFor="token"
              style={{ fontSize: '0.8125rem', color: 'var(--color-muted)', fontWeight: 500 }}
            >
              Admin Token
            </label>
            <input
              id="token"
              type="password"
              value={token}
              onChange={(e) => setToken(e.target.value)}
              placeholder="Enter your admin token"
              autoComplete="current-password"
              style={{
                background: 'var(--color-bg)',
                border: '1px solid var(--color-border)',
                borderRadius: '0.5rem',
                padding: '0.625rem 0.75rem',
                color: 'var(--color-text)',
                fontSize: '0.875rem',
                outline: 'none',
                width: '100%',
              }}
            />
          </div>

          {error && (
            <p style={{ color: 'var(--color-red)', fontSize: '0.8125rem', margin: 0 }}>
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={loading || !token}
            style={{
              background: 'var(--color-cyan)',
              color: 'var(--color-bg)',
              border: 'none',
              borderRadius: '0.5rem',
              padding: '0.625rem',
              fontWeight: 700,
              fontSize: '0.9375rem',
              cursor: loading || !token ? 'not-allowed' : 'pointer',
              opacity: loading || !token ? 0.6 : 1,
              width: '100%',
              transition: 'opacity 0.15s',
            }}
          >
            {loading ? 'Signing in…' : 'Sign In'}
          </button>
        </form>

        <p style={{ color: 'var(--color-muted)', fontSize: '0.75rem', textAlign: 'center', marginTop: '1.5rem' }}>
          Use the ADMIN_SECRET from your worker environment.
        </p>
      </div>
    </main>
  );
}
