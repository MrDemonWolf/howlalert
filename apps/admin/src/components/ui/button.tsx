'use client';

import React from 'react';

type Variant = 'primary' | 'secondary' | 'destructive';

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  className?: string;
  type?: 'button' | 'submit' | 'reset';
  variant?: Variant;
}

const variantStyles: Record<Variant, React.CSSProperties> = {
  primary: {
    background: 'var(--color-cyan)',
    color: 'var(--color-bg)',
    border: 'none',
  },
  secondary: {
    background: 'var(--color-surface)',
    color: 'var(--color-text)',
    border: '1px solid var(--color-border)',
  },
  destructive: {
    background: 'var(--color-red)',
    color: '#fff',
    border: 'none',
  },
};

export function Button({
  children,
  onClick,
  disabled,
  className = '',
  type = 'button',
  variant = 'primary',
}: ButtonProps) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={className}
      style={{
        ...variantStyles[variant],
        padding: '0.5rem 1rem',
        borderRadius: '0.5rem',
        fontWeight: 600,
        fontSize: '0.875rem',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.5 : 1,
        transition: 'opacity 0.15s',
      }}
    >
      {children}
    </button>
  );
}
