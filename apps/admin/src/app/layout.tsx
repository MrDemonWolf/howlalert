import type { Metadata } from 'next';

import '@/styles/globals.css';

export const metadata: Metadata = {
  title: 'HowlAlert Admin',
  description: 'HowlAlert push notification admin dashboard',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen" style={{ backgroundColor: 'var(--color-bg)' }}>
        {children}
      </body>
    </html>
  );
}
