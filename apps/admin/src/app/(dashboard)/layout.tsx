'use client';

import React, { useEffect, useState } from 'react';
import { usePathname } from 'next/navigation';
import { ToastProvider } from '@/components/ui/toast';
import { logout } from '@/lib/auth';

const navItems = [
  { label: 'Overview', href: '/dashboard' },
  { label: 'Config', href: '/dashboard/config' },
  { label: 'Push Log', href: '/dashboard/push-log' },
];

function Sidebar({ open, onClose }: { open: boolean; onClose: () => void }) {
  const pathname = usePathname();
  const [connected, setConnected] = useState<boolean | null>(null);

  useEffect(() => {
    const workerUrl =
      process.env['NEXT_PUBLIC_WORKER_URL'] ??
      'https://howlalert-worker.mrdemonwolf.workers.dev';

    async function checkConnection() {
      try {
        const token = sessionStorage.getItem('howlalert_admin_token') ?? '';
        const res = await fetch(`${workerUrl}/config`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setConnected(res.ok);
      } catch {
        setConnected(false);
      }
    }

    checkConnection();
    const interval = setInterval(checkConnection, 30_000);
    return () => clearInterval(interval);
  }, []);

  const sidebarContent = (
    <aside
      style={{
        width: '260px',
        minHeight: '100vh',
        background: 'var(--color-surface)',
        borderRight: '1px solid var(--color-border)',
        display: 'flex',
        flexDirection: 'column',
        padding: '1.25rem',
        flexShrink: 0,
      }}
    >
      <div style={{ marginBottom: '2rem' }}>
        <span style={{ fontSize: '1.25rem', fontWeight: 700, color: 'var(--color-cyan)' }}>
          HowlAlert
        </span>
        <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)', marginLeft: '0.5rem' }}>
          Admin
        </span>
      </div>

      <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.25rem', flex: 1 }}>
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <a
              key={item.href}
              href={item.href}
              onClick={onClose}
              style={{
                display: 'block',
                padding: '0.625rem 0.75rem',
                borderRadius: '0.5rem',
                fontSize: '0.875rem',
                fontWeight: isActive ? 600 : 400,
                color: isActive ? 'var(--color-cyan)' : 'var(--color-muted)',
                background: isActive ? 'rgba(15,172,237,0.08)' : 'transparent',
                borderLeft: isActive ? '3px solid var(--color-cyan)' : '3px solid transparent',
                textDecoration: 'none',
                transition: 'all 0.15s',
                paddingLeft: isActive ? 'calc(0.75rem - 3px)' : '0.75rem',
              }}
            >
              {item.label}
            </a>
          );
        })}
      </nav>

      <div
        style={{
          borderTop: '1px solid var(--color-border)',
          paddingTop: '1rem',
          display: 'flex',
          flexDirection: 'column',
          gap: '0.75rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <span
            style={{
              width: '0.5rem',
              height: '0.5rem',
              borderRadius: '50%',
              background:
                connected === null
                  ? 'var(--color-muted)'
                  : connected
                  ? 'var(--color-green)'
                  : 'var(--color-red)',
              flexShrink: 0,
            }}
          />
          <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)' }}>
            {connected === null ? 'Checking…' : connected ? 'Worker connected' : 'Worker offline'}
          </span>
        </div>
        <button
          onClick={() => logout()}
          style={{
            background: 'transparent',
            border: '1px solid var(--color-border)',
            borderRadius: '0.5rem',
            padding: '0.5rem',
            color: 'var(--color-muted)',
            fontSize: '0.8125rem',
            cursor: 'pointer',
            width: '100%',
          }}
        >
          Logout
        </button>
      </div>
    </aside>
  );

  return (
    <>
      {/* Desktop */}
      <div className="hidden md:flex">{sidebarContent}</div>
      {/* Mobile drawer */}
      {open && (
        <div
          style={{ position: 'fixed', inset: 0, zIndex: 50, display: 'flex' }}
          onClick={onClose}
        >
          <div onClick={(e) => e.stopPropagation()}>{sidebarContent}</div>
          <div style={{ flex: 1, background: 'rgba(0,0,0,0.5)' }} />
        </div>
      )}
    </>
  );
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <ToastProvider>
      <div style={{ display: 'flex', minHeight: '100vh' }}>
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
          {/* Mobile top bar */}
          <div
            className="flex md:hidden"
            style={{
              padding: '1rem',
              borderBottom: '1px solid var(--color-border)',
              alignItems: 'center',
              gap: '1rem',
            }}
          >
            <button
              onClick={() => setSidebarOpen(true)}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'var(--color-text)',
                fontSize: '1.25rem',
                cursor: 'pointer',
                padding: '0.25rem',
              }}
              aria-label="Open menu"
            >
              ☰
            </button>
            <span style={{ fontWeight: 700, color: 'var(--color-cyan)' }}>HowlAlert Admin</span>
          </div>
          <main style={{ flex: 1, overflowY: 'auto', padding: '1.5rem' }}>{children}</main>
        </div>
      </div>
    </ToastProvider>
  );
}
