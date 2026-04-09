'use client';

import React, { useEffect, useState } from 'react';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { getConfig, getPushLogStats, type PushLogStats } from '@/lib/api';
import type { RemoteConfig } from '@howlalert/shared-types';

const critBarStates = [
  { label: 'Normal', color: 'var(--color-green)', pct: '< 80%' },
  { label: 'Approaching', color: 'var(--color-amber)', pct: '80–90%' },
  { label: 'Critical', color: 'var(--color-red)', pct: '> 90%' },
  { label: 'Reset', color: 'var(--color-cyan)', pct: '0%' },
];

export default function DashboardPage() {
  const [config, setConfig] = useState<RemoteConfig | null>(null);
  const [stats, setStats] = useState<PushLogStats | null>(null);
  const [configError, setConfigError] = useState(false);

  async function fetchData() {
    try {
      const cfg = await getConfig();
      setConfig(cfg);
      setConfigError(false);
    } catch {
      setConfigError(true);
    }
    try {
      const s = await getPushLogStats();
      setStats(s);
    } catch {
      // non-fatal
    }
  }

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 30_000);
    return () => clearInterval(interval);
  }, []);

  const multiplier = config?.promo?.multiplier ?? 1;
  const hasPromo = Boolean(config?.promo);
  const promoExpiry = config?.promo?.expiresAt
    ? new Date(config.promo.expiresAt).toLocaleDateString()
    : null;

  return (
    <div>
      <h1 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '1.5rem', color: 'var(--color-text)' }}>
        Overview
      </h1>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
          gap: '1rem',
        }}
      >
        {/* Card 1: Active Multiplier */}
        <Card title="Active Multiplier">
          {configError ? (
            <p style={{ color: 'var(--color-muted)', fontSize: '0.875rem' }}>Could not load config.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              <span style={{ fontSize: '3rem', fontWeight: 800, color: 'var(--color-text)', lineHeight: 1 }}>
                {config ? `${multiplier}x` : '—'}
              </span>
              {hasPromo && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.25rem' }}>
                  <Badge variant="warning">PROMO ACTIVE</Badge>
                  {promoExpiry && (
                    <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)' }}>
                      Expires {promoExpiry}
                    </span>
                  )}
                </div>
              )}
              {!hasPromo && config && (
                <Badge variant="neutral">Standard</Badge>
              )}
            </div>
          )}
        </Card>

        {/* Card 2: Crit Bar States */}
        <Card title="Crit Bar States">
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.625rem' }}>
            {critBarStates.map((state) => (
              <div key={state.label} style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <div
                  style={{
                    height: '0.375rem',
                    width: '4rem',
                    borderRadius: '9999px',
                    background: state.color,
                    flexShrink: 0,
                  }}
                />
                <span style={{ fontSize: '0.8125rem', color: 'var(--color-text)', flex: 1 }}>
                  {state.label}
                </span>
                <span style={{ fontSize: '0.75rem', color: 'var(--color-muted)' }}>
                  {state.pct}
                </span>
              </div>
            ))}
          </div>
        </Card>

        {/* Card 3: Push Stats */}
        <Card title="Push Stats">
          {stats ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '0.8125rem', color: 'var(--color-muted)' }}>Total</span>
                <span style={{ fontWeight: 700, color: 'var(--color-text)' }}>{stats.total}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '0.8125rem', color: 'var(--color-muted)' }}>Successful</span>
                <span style={{ fontWeight: 700, color: 'var(--color-green)' }}>{stats.successful}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '0.8125rem', color: 'var(--color-muted)' }}>Failed</span>
                <span style={{ fontWeight: 700, color: 'var(--color-red)' }}>{stats.failed}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '0.8125rem', color: 'var(--color-muted)' }}>Success Rate</span>
                <Badge variant={stats.successRate >= 90 ? 'success' : stats.successRate >= 50 ? 'warning' : 'error'}>
                  {stats.successRate}%
                </Badge>
              </div>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {['Total', 'Successful', 'Failed', 'Success Rate'].map((label) => (
                <div key={label} style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ fontSize: '0.8125rem', color: 'var(--color-muted)' }}>{label}</span>
                  <span style={{ color: 'var(--color-muted)' }}>—</span>
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}
