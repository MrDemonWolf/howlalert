import Link from 'next/link'

export default function HomePage() {
  return (
    <main style={{ minHeight: '100vh', background: '#091533', color: '#e8edf5', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
      <div style={{ maxWidth: 600, textAlign: 'center' }}>
        <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🐺</div>
        <h1 style={{ fontSize: '2.5rem', fontWeight: 700, marginBottom: '0.5rem', color: '#0FACED' }}>HowlAlert</h1>
        <p style={{ fontSize: '1.25rem', color: '#a0b4cc', marginBottom: '2rem' }}>
          Claude Code usage monitor for macOS, iOS, and watchOS.
          Get push notifications before you hit your token limits.
        </p>
        <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
          <Link href="/docs" style={{ background: '#0FACED', color: '#091533', padding: '0.75rem 1.5rem', borderRadius: 8, fontWeight: 600, textDecoration: 'none' }}>Documentation</Link>
          <Link href="/legal/privacy-policy" style={{ border: '1px solid #0FACED', color: '#0FACED', padding: '0.75rem 1.5rem', borderRadius: 8, fontWeight: 600, textDecoration: 'none' }}>Privacy Policy</Link>
          <Link href="/legal/terms-of-service" style={{ border: '1px solid #0FACED', color: '#0FACED', padding: '0.75rem 1.5rem', borderRadius: 8, fontWeight: 600, textDecoration: 'none' }}>Terms of Service</Link>
        </div>
      </div>
    </main>
  )
}
