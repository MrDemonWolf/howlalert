import type { NextConfig } from 'next'
import { createMDX } from 'fumadocs-mdx/next'

const withMDX = createMDX()

const nextConfig: NextConfig = {
  reactStrictMode: true,
  redirects: async () => [
    { source: '/privacy', destination: '/legal/privacy-policy', permanent: true },
    { source: '/terms', destination: '/legal/terms-of-service', permanent: true },
  ],
}

export default withMDX(nextConfig)
