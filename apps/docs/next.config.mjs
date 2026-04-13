import { createMDX } from "fumadocs-mdx/next";

const withMDX = createMDX();

/** @type {import('next').NextConfig} */
const config = {
  output: "export",
  trailingSlash: true,
  images: { unoptimized: true },
  basePath: process.env.NODE_ENV === "production" ? "/howlalert" : "",
};

export default withMDX(config);
