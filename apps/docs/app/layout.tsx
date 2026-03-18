import type { ReactNode } from "react";
import type { Metadata } from "next";
import { RootProvider } from "fumadocs-ui/provider";
import { Inter } from "next/font/google";
import "./global.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  metadataBase: new URL("https://mrdemonwolf.github.io/howlalert"),
  title: {
    template: "%s | HowlAlert",
    default: "HowlAlert — Claude Code Usage Monitor",
  },
  description:
    "Monitor your Claude Code usage in real time. Get push notifications before you hit spending limits — across macOS, iOS, and watchOS.",
  keywords: [
    "Claude Code",
    "usage monitor",
    "cost tracking",
    "push notifications",
    "macOS",
    "iOS",
    "watchOS",
    "HowlAlert",
  ],
  openGraph: {
    title: "HowlAlert — Claude Code Usage Monitor",
    description:
      "Real-time cost tracking and push notifications for Claude Code. Stay on budget across all your Apple devices.",
    siteName: "HowlAlert",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "HowlAlert — Claude Code Usage Monitor",
    description:
      "Real-time cost tracking and push notifications for Claude Code.",
  },
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.className} flex flex-col min-h-screen`}>
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  );
}
