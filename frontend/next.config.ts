import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactCompiler: true,
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "http://localhost:4000/api/:path*",
      },
      {
        source: "/streams/:path*",
        destination: "http://localhost:4000/streams/:path*",
      },
      {
        source: "/admin/:path*",
        destination: "http://localhost:4000/admin/:path*",
      },
    ];
  },
};

export default nextConfig;
