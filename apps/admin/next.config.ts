import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  transpilePackages: ['@howlalert/shared-types'],
  experimental: {
    typedRoutes: true,
  },
};

export default nextConfig;
