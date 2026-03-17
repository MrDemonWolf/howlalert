import type { ReactNode } from "react";
import { RootProvider } from "fumadocs-ui/provider";
import { Inter } from "next/font/google";
import "fumadocs-ui/style.css";

const inter = Inter({ subsets: ["latin"] });

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  );
}

export const metadata = {
  title: {
    template: "%s | HowlAlert",
    default: "HowlAlert",
  },
  description: "Monitor your Claude Code usage and get notified before you hit limits.",
};
