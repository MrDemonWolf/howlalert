import { RootProvider } from "fumadocs-ui/provider/next";
import "./global.css";
import { Inter } from "next/font/google";
import type { Metadata } from "next";

const inter = Inter({
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: {
    default: "HowlAlert — Know your Claude Code limits. Everywhere.",
    template: "%s | HowlAlert",
  },
  description:
    "Real-time Claude Code usage monitor for Mac, iPhone, and Apple Watch. Push alerts before you hit the wall.",
  metadataBase: new URL("https://mrdemonwolf.github.io/howlalert"),
};

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={inter.className} suppressHydrationWarning>
      <body className="flex flex-col min-h-screen">
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  );
}
