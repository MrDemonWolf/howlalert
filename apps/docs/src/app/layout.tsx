import { RootProvider } from "fumadocs-ui/provider/next";
import type { Metadata } from "next";
import { Bricolage_Grotesque, Geist, Geist_Mono } from "next/font/google";

import "./global.css";
import { asset, homepageSeo, repo, siteUrl } from "@/lib/site";

// Display = Bricolage Grotesque. Characterful, tight display grotesque.
const bricolage = Bricolage_Grotesque({
  subsets: ["latin"],
  variable: "--font-display",
  display: "swap",
});

// Body = Geist. Clean modern sans with a sharper personality than Inter.
const geist = Geist({
  subsets: ["latin"],
  variable: "--font-body",
  display: "swap",
});

const geistMono = Geist_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: homepageSeo.title,
    template: "%s | HowlAlert",
  },
  description: homepageSeo.description,
  keywords: [...homepageSeo.keywords],
  authors: [{ name: "MrDemonWolf, Inc." }],
  creator: "MrDemonWolf, Inc.",
  icons: {
    icon: [{ url: asset("/howlalert-wolf-brand.svg"), type: "image/svg+xml" }],
  },
  alternates: { canonical: siteUrl },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: siteUrl,
    siteName: "HowlAlert",
    title: homepageSeo.title,
    description: homepageSeo.socialDescription,
  },
  twitter: {
    card: "summary_large_image",
    site: "@mrdemonwolf",
    creator: "@mrdemonwolf",
    title: homepageSeo.title,
    description: homepageSeo.socialDescription,
  },
  metadataBase: new URL(siteUrl),
};

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "HowlAlert",
  description: homepageSeo.description,
  operatingSystem: "macOS 26.0",
  applicationCategory: "DeveloperApplication",
  processorRequirements: "Apple Silicon",
  offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
  author: {
    "@type": "Organization",
    name: "MrDemonWolf, Inc.",
    url: "https://github.com/mrdemonwolf",
  },
  url: siteUrl,
  downloadUrl: repo.releases,
  installUrl: `${siteUrl}/download/`,
  featureList: [
    "Watches the Claude Code 5-hour usage window from the menu bar",
    "Auto-detects your limit from history (P90) — no hard-coded plan numbers",
    "Local and push notifications before you hit the limit",
    "Reads ~/.claude locally; your prompts and code never leave your Mac",
  ],
  license: "https://github.com/mrdemonwolf/howlalert/blob/main/LICENSE",
};

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en"
      className={`${bricolage.variable} ${geist.variable} ${geistMono.variable}`}
      suppressHydrationWarning
    >
      <body className="flex flex-col min-h-screen">
        <a href="#nd-page" className="skip-nav">
          Skip to content
        </a>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        <RootProvider search={{ options: { type: "static" } }}>
          {children}
        </RootProvider>
      </body>
    </html>
  );
}
