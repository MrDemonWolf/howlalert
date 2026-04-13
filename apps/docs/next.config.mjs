import { createMDX } from "fumadocs-mdx/next";

const withMDX = createMDX();

const isProd = process.env.NODE_ENV === "production";

/** @type {import('next').NextConfig} */
const config = {
  reactStrictMode: true,
  output: "export",
  trailingSlash: true,
  images: { unoptimized: true },
  basePath: isProd ? "/howlalert" : "",
};

export default withMDX(config);
