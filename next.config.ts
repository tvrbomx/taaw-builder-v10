import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Fija la raíz del workspace: el directorio padre tiene otro package-lock.json
  // ajeno a este repo y Next lo detecta como raíz por error sin esto.
  outputFileTracingRoot: __dirname,
};

export default nextConfig;
