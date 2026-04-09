import type { ReactNode } from 'react'
import { RootProvider } from 'fumadocs-ui/provider'
// @ts-expect-error — fumadocs-ui CSS import has no type declarations
import 'fumadocs-ui/style.css'

export const metadata = {
  title: { default: 'HowlAlert', template: '%s — HowlAlert' },
  description: 'Claude Code usage monitor for macOS, iOS, and watchOS',
}

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  )
}
