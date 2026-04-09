import React from 'react';

type Variant = 'success' | 'error' | 'warning' | 'neutral';

interface BadgeProps {
  variant?: Variant;
  children: React.ReactNode;
}

const dotColor: Record<Variant, string> = {
  success: 'var(--color-green)',
  error: 'var(--color-red)',
  warning: 'var(--color-amber)',
  neutral: 'var(--color-muted)',
};

const bgColor: Record<Variant, string> = {
  success: 'rgba(52,199,89,0.12)',
  error: 'rgba(255,59,48,0.12)',
  warning: 'rgba(245,166,35,0.12)',
  neutral: 'rgba(122,139,168,0.12)',
};

const textColor: Record<Variant, string> = {
  success: 'var(--color-green)',
  error: 'var(--color-red)',
  warning: 'var(--color-amber)',
  neutral: 'var(--color-muted)',
};

export function Badge({ variant = 'neutral', children }: BadgeProps) {
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '0.375rem',
        padding: '0.2rem 0.6rem',
        borderRadius: '9999px',
        fontSize: '0.75rem',
        fontWeight: 600,
        background: bgColor[variant],
        color: textColor[variant],
      }}
    >
      <span
        style={{
          width: '0.4375rem',
          height: '0.4375rem',
          borderRadius: '50%',
          background: dotColor[variant],
          flexShrink: 0,
        }}
      />
      {children}
    </span>
  );
}
