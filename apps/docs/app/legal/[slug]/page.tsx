import { legal } from '@/lib/source'
import { notFound } from 'next/navigation'
import type { FC } from 'react'

export default async function LegalPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const page = legal.getPage([slug])
  if (!page) notFound()
  const MDX = (page.data as unknown as { body: FC }).body

  return (
    <div style={{ minHeight: '100vh', background: '#091533', color: '#e8edf5', fontFamily: 'system-ui, sans-serif' }}>
      <div style={{ maxWidth: 760, margin: '0 auto', padding: '4rem 2rem' }}>
        <a href="/" style={{ color: '#0FACED', textDecoration: 'none', fontSize: '0.9rem' }}>← Back to HowlAlert</a>
        <article style={{ marginTop: '2rem', lineHeight: 1.7 }}>
          <MDX />
        </article>
      </div>
    </div>
  )
}

export async function generateStaticParams() {
  return legal.generateParams().map((p) => ({ slug: p.slug?.[0] ?? '' }))
}
