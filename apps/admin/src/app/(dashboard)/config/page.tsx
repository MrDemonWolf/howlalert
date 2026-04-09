'use client';

import React, { useEffect, useState } from 'react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useToast } from '@/components/ui/toast';
import { getConfig, updateConfig } from '@/lib/api';
import type { RemoteConfig } from '@howlalert/shared-types';

const defaultConfig: RemoteConfig = {
  limits: { planLimit: 1000000, warningThreshold: 0.8, criticalThreshold: 0.9 },
  updatedAt: new Date().toISOString(),
};

export default function ConfigPage() {
  const { showToast } = useToast();
  const [config, setConfig] = useState<RemoteConfig>(defaultConfig);
  const [saving, setSaving] = useState(false);
  const [showRaw, setShowRaw] = useState(false);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    getConfig()
      .then((cfg) => { setConfig(cfg); setLoaded(true); })
      .catch(() => { setLoaded(true); });
  }, []);

  function setMultiplier(m: number) {
    setConfig((c) => ({ ...c, promo: c.promo ? { ...c.promo, multiplier: m } : { multiplier: m, expiresAt: '' } }));
  }

  function applyPreset(name: string, multiplier: number, months: number) {
    const expires = new Date();
    expires.setMonth(expires.getMonth() + months);
    setConfig((c) => ({ ...c, promo: { multiplier, expiresAt: expires.toISOString().split('T')[0]! } }));
    showToast(`Applied preset: ${name}`, 'info');
  }

  function clearPromo() {
    setConfig((c) => { const { promo: _, ...rest } = c; return rest as RemoteConfig; });
  }

  async function handleSave() {
    setSaving(true);
    try {
      const payload: RemoteConfig = { ...config, updatedAt: new Date().toISOString() };
      await updateConfig(payload);
      setConfig(payload);
      showToast('Config saved successfully.', 'success');
    } catch {
      showToast('Failed to save config.', 'error');
    } finally {
      setSaving(false);
    }
  }

  const currentMultiplier = config.promo?.multiplier ?? 1;
  const promoExpiry = config.promo?.expiresAt ?? '';

  return (
    <div style={{ maxWidth: '640px' }}>
      <h1 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '1.5rem', color: 'var(--color-text)' }}>
        Limit Config
      </h1>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
        <Card title="Multiplier">
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div>
              <p style={{ fontSize: '0.8125rem', color: 'var(--color-muted)', marginBottom: '0.5rem' }}>
                Quick select
              </p>
              <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', alignItems: 'center' }}>
                {[1, 2, 3, 5].map((m) => (
                  <button
                    key={m}
                    onClick={() => setMultiplier(m)}
                    style={{
                      padding: '0.375rem 0.875rem',
                      borderRadius: '0.5rem',
                      border: `1px solid ${currentMultiplier === m ? 'var(--color-cyan)' : 'var(--color-border)'}`,
                      background: currentMultiplier === m ? 'rgba(15,172,237,0.12)' : 'var(--color-bg)',
                      color: currentMultiplier === m ? 'var(--color-cyan)' : 'var(--color-muted)',
                      fontWeight: 600,
                      cursor: 'pointer',
                      fontSize: '0.875rem',
                    }}
                  >
                    {m}x
                  </button>
                ))}
                <Input
                  type="number"
                  value={currentMultiplier}
                  onChange={(e) => setMultiplier(Number(e.target.value))}
                  placeholder="Custom"
                />
              </div>
            </div>

            <div>
              <p style={{ fontSize: '0.8125rem', color: 'var(--color-muted)', marginBottom: '0.5rem' }}>
                Promo presets
              </p>
              <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                <Button variant="secondary" onClick={() => applyPreset('Spring Break 2x', 2, 1)}>
                  Spring Break 2x
                </Button>
                <Button variant="secondary" onClick={() => applyPreset('Holiday 2x', 2, 2)}>
                  Holiday 2x
                </Button>
                <Button variant="destructive" onClick={clearPromo}>
                  Clear
                </Button>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
              <Input
                label="Active until"
                type="date"
                value={promoExpiry}
                onChange={(e) =>
                  setConfig((c) => ({
                    ...c,
                    promo: c.promo
                      ? { ...c.promo, expiresAt: e.target.value }
                      : { multiplier: 1, expiresAt: e.target.value },
                  }))
                }
              />
              <Input
                label="Plan limit override"
                type="number"
                value={config.planLimitOverride ?? config.limits.planLimit}
                onChange={(e) =>
                  setConfig((c) => ({ ...c, planLimitOverride: Number(e.target.value) }))
                }
              />
            </div>

            <div>
              <Button
                variant="primary"
                onClick={handleSave}
                disabled={saving || !loaded}
              >
                {saving ? 'Saving…' : 'Save Config'}
              </Button>
            </div>
          </div>
        </Card>

        <Card>
          <button
            onClick={() => setShowRaw((v) => !v)}
            style={{
              background: 'transparent',
              border: 'none',
              color: 'var(--color-muted)',
              cursor: 'pointer',
              fontSize: '0.8125rem',
              padding: 0,
              display: 'flex',
              alignItems: 'center',
              gap: '0.375rem',
            }}
          >
            <span style={{ fontSize: '0.625rem' }}>{showRaw ? '▼' : '▶'}</span>
            Raw JSON
          </button>
          {showRaw && (
            <pre
              style={{
                marginTop: '0.75rem',
                fontSize: '0.75rem',
                color: 'var(--color-muted)',
                background: 'var(--color-bg)',
                border: '1px solid var(--color-border)',
                borderRadius: '0.5rem',
                padding: '0.75rem',
                overflowX: 'auto',
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-all',
              }}
            >
              {JSON.stringify(config, null, 2)}
            </pre>
          )}
        </Card>
      </div>
    </div>
  );
}
