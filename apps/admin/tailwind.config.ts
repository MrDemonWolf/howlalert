import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          bg: 'var(--color-bg)',
          accent: 'var(--color-accent)',
          amber: 'var(--color-amber)',
          red: 'var(--color-red)',
          green: 'var(--color-green)',
        },
      },
    },
  },
};

export default config;
