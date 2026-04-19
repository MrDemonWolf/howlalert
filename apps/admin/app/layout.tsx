import type { Metadata, Viewport } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "HowlAlert Admin",
  description: "HowlAlert admin dashboard — coming in MVP 2.",
};

export const viewport: Viewport = {
  themeColor: "#091533",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: "system-ui, sans-serif", background: "#091533", color: "#0FACED" }}>
        {children}
      </body>
    </html>
  );
}
