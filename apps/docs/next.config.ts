import type { NextConfig } from "next";
import { createMDX } from "fumadocs-mdx/next";

const withMDX = createMDX();

const config: NextConfig = {
  output: "export",
  reactStrictMode: true,
};

export default withMDX(config);
