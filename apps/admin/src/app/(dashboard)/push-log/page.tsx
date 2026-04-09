'use client';

import React, { useCallback, useEffect, useRef, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { getPushLog } from '@/lib/api';
import type { PushLogEntry } from '@howlalert/shared-types';

function statusVariant(status: PushLogEntry['status']): 'success' | 'error' | 'neutral' {
  if (status === 'sent') return 'success';
  if (status === 'failed') return 'error';
  return 'neutral';
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleString(undefined, {
    month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  });
}

function truncateToken(token: string) {
  return token.length > 12 ? `${token.slice(0, 6)}…${token.slice(-4)}` : token;
}

export default function PushLogPage() {
  const [entries, setEntries] = useState<PushLogEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [live, setLive] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const fetchLog = useCallback(async () => {
    try {
      const data = await getPushLog();
      setEntries(data);
    } catch {
      // keep previous data
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchLog(); }, [fetchLog]);

  useEffect(() => {
    if (intervalRef.current) clearInterval(intervalRef.current);
    if (live) intervalRef.current = setInterval(fetchLog, 5_000);
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [live, fetchLog]);

  const thStyle: React.CSSProperties = {
    padding: '0.625rem 0.75rem',
    textAlign: 'left',
    fontSize: '0.75rem',
    fontWeight: 600,
    color: 'var(--color-muted)',
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    borderBottom: '1px solid var(--color-border)',
    whiteSpace: 'nowrap',
  };

  const tdStyle: React.CSSProperties = {
    padding: '0.625rem 0.75rem',
    fontSize: '0.8125rem',
    color: 'var(--color-text)',
    borderBottom: '1px solid var(--color-border)',
    verticalAlign: 'middle',
  };

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '0.75rem' }}>
        <h1 style={{ fontSize: '1.5rem', fontWeight: 700, color: 'var(--color-text)', margin: 0 }}>
          Push Log
        </h1>
        <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.875rem', color: 'var(--color-muted)' }}>
          <input
            type="checkbox"
            checked={live}
            onChange={(e) => setLive(e.target.checked)}
            style={{ accentColor: 'var(--color-cyan)', width: '1rem', height: '1rem' }}
          />
          Live (refresh every 5s)
        </label>
      </div>

      <div style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: '0.75rem', overflow: 'hidden' }}>
        {loading ? (
          <p style={{ padding: '2rem', color: 'var(--color-muted)', textAlign: 'center', fontSize: '0.875rem' }}>Loading…</p>
        ) : entries.length === 0 ? (
          <p style={{ padding: '2rem', color: 'var(--color-muted)', textAlign: 'center', fontSize: '0.875rem' }}>No pushes yet.</p>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr>
                  <th style={thStyle}>Timestamp</th>
                  <th style={thStyle}>Device</th>
                  <th style={thStyle}>Trigger</th>
                  <th style={thStyle}>Title</th>
                  <th style={thStyle}>Result</th>
                </tr>
              </thead>
              <tbody>
                {entries.map((entry) => (
                  <tr key={entry.id}>
                    <td style={{ ...tdStyle, color: 'var(--color-muted)', whiteSpace: 'nowrap' }}>{formatDate(entry.sentAt)}</td>
                    <td style={{ ...tdStyle, fontFamily: 'monospace', fontSize: '0.75rem' }}>{truncateToken(entry.deviceToken)}</td>
                    <td style={tdStyle}>
                      <Badge variant={entry.trigger === 'critical' ? 'error' : entry.trigger === 'warning' ? 'warning' : 'neutral'}>
                        {entry.trigger}
                      </Badge>
                    </td>
                    <td style={{ ...tdStyle, maxWidth: '200px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{entry.title}</td>
                    <td style={tdStyle}>
                      <Badge variant={statusVariant(entry.status)}>{entry.status}</Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
