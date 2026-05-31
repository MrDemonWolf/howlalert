import type { Metadata } from "next";
import Link from "next/link";
import { Activity, ArrowRight, Download, Terminal } from "lucide-react";

import { repo } from "@/lib/site";
import { CopyButton } from "./copy-button";
import { GithubMark } from "../_widgets/icons";

const BREW_CMD = "brew tap mrdemonwolf/den\nbrew install --cask howlalert";

export const metadata: Metadata = {
  title: "Download HowlAlert — Free for macOS 26+ (DMG or Homebrew)",
  description:
    "Download HowlAlert free for macOS 26+ on Apple Silicon. Install the signed .dmg or run `brew install --cask howlalert`. Watches your Claude Code usage from the menu bar. Open source.",
  keywords: [
    "download howlalert",
    "howlalert dmg",
    "brew install howlalert",
    "claude code usage monitor download",
    "free macos claude usage app",
  ],
  alternates: { canonical: "/download" },
  openGraph: {
    title: "Download HowlAlert — Free for macOS 26+",
    description:
      "Free macOS menu bar app that watches your Claude Code 5-hour window. DMG or Homebrew. Apple Silicon.",
  },
};

export default function DownloadPage() {
  return (
    <main className="ha-font ha-bg-base">
      {/* ═══════════════ HERO ═══════════════ */}
      <section className="relative overflow-hidden">
        <div className="ha-hero-glow" aria-hidden="true" />
        <div className="relative z-10 px-6 pt-20 pb-12 sm:pt-28">
          <div className="mx-auto max-w-3xl text-center">
            <span
              className="ha-reveal ha-reveal-1 ha-pill"
              style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-600)" }}
            >
              macOS 26+ · Apple Silicon · For Claude Code
            </span>
            <h1 className="ha-reveal ha-reveal-1 ha-display ha-text-1 text-5xl sm:text-7xl mt-5">
              Download HowlAlert
            </h1>
            <p className="ha-reveal ha-reveal-2 ha-text-2 text-lg sm:text-xl mt-5 max-w-md mx-auto leading-relaxed">
              Tiny menu bar app. Install in under a minute. Free and open source.
            </p>

            <div className="ha-reveal ha-reveal-3 mt-8 flex flex-col sm:flex-row items-center justify-center gap-3">
              <a
                href={repo.releases}
                target="_blank"
                rel="noopener noreferrer"
                className="ha-btn ha-btn-primary"
                style={{ padding: "1rem 1.75rem", fontSize: "1rem" }}
              >
                <Download className="w-4 h-4" />
                Download .dmg
              </a>
              <a
                href={repo.url}
                target="_blank"
                rel="noopener noreferrer"
                className="ha-btn ha-btn-ghost"
              >
                <GithubMark className="w-4 h-4" />
                View on GitHub
              </a>
            </div>

            <div
              className="ha-reveal ha-reveal-3 mt-10 inline-flex items-center gap-3 ha-pulse-ring"
              style={{
                padding: "0.6rem 1.1rem",
                borderRadius: "980px",
                backgroundColor: "var(--bg-surface)",
                border: "1px solid var(--hairline)",
              }}
            >
              <span
                className="inline-flex items-center justify-center"
                style={{
                  width: "1.6rem",
                  height: "1.6rem",
                  borderRadius: "999px",
                  backgroundColor: "var(--brand-50)",
                  color: "var(--brand-500)",
                }}
              >
                <Activity className="w-3.5 h-3.5" aria-hidden />
              </span>
              <span className="ha-text-2 text-sm">
                <span className="ha-text-1 font-medium">Watching</span> · runs out
                in 47m
              </span>
            </div>

            <p className="mt-6 text-sm ha-text-2">
              Free · Open source · Signed and notarized by Apple
            </p>
          </div>
        </div>
      </section>

      {/* ═══════════════ INSTALL METHODS ═══════════════ */}
      <section className="ha-bg-base px-6 pb-16">
        <div className="mx-auto max-w-5xl">
          <div className="grid md:grid-cols-2 gap-5 items-stretch">
            {/* DMG */}
            <div
              className="ha-card ha-bg-surface flex flex-col h-full"
              style={{ border: "1px solid var(--hairline)" }}
            >
              <div className="flex items-center justify-between gap-3 mb-5">
                <div
                  className="w-11 h-11 rounded-xl inline-flex items-center justify-center"
                  style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-500)" }}
                >
                  <Download className="w-5 h-5" />
                </div>
                <span
                  className="ha-pill"
                  style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-600)" }}
                >
                  Recommended
                </span>
              </div>
              <h2 className="ha-display ha-text-1 text-xl mb-2">DMG installer</h2>
              <p className="ha-text-2 text-base leading-relaxed flex-1">
                Drag to Applications. Auto-updates via Sparkle.
              </p>
              <a
                href={repo.releases}
                target="_blank"
                rel="noopener noreferrer"
                className="ha-btn ha-btn-primary mt-6"
              >
                <Download className="w-4 h-4" />
                Download .dmg
              </a>
            </div>

            {/* Homebrew */}
            <div
              className="ha-card ha-bg-surface flex flex-col h-full"
              style={{ border: "1px solid var(--hairline)" }}
            >
              <div className="flex items-center justify-between gap-3 mb-5">
                <div
                  className="w-11 h-11 rounded-xl inline-flex items-center justify-center"
                  style={{
                    backgroundColor: "var(--bg-base)",
                    color: "var(--txt-1)",
                    border: "1px solid var(--hairline)",
                  }}
                >
                  <Terminal className="w-5 h-5" />
                </div>
                <span className="ha-pill">Homebrew</span>
              </div>
              <h2 className="ha-display ha-text-1 text-xl mb-2">Command line</h2>
              <p className="ha-text-2 text-base leading-relaxed mb-4">
                Auto-updates via{" "}
                <code className="ha-mono ha-text-1">brew upgrade --cask</code>.
              </p>
              <pre className="ha-code flex-1" style={{ margin: 0 }}>{BREW_CMD}</pre>
              <div className="mt-4 flex justify-end">
                <CopyButton value={BREW_CMD} label="Copy command" />
              </div>
            </div>
          </div>

          {/* ═══════════════ TRUST + REQUIREMENTS ═══════════════ */}
          <div className="mt-12 flex flex-wrap items-center justify-center gap-2">
            {["Notarized", "Local-only", "No telemetry", "No account", "GPLv3"].map(
              (label) => (
                <span key={label} className="ha-pill">
                  {label}
                </span>
              ),
            )}
          </div>
          <p className="ha-text-2 text-sm text-center mt-4 max-w-xl mx-auto">
            Requires macOS 26 Tahoe, Apple Silicon, and Claude Code installed
            locally. HowlAlert reads your <code className="ha-mono ha-text-1">~/.claude</code>{" "}
            usage files — it never connects to Anthropic&rsquo;s services.
          </p>

          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <Link href="/docs/installation" className="ha-btn ha-btn-ghost">
              Installation guide
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
            <Link href="/docs/how-it-works" className="ha-btn ha-btn-ghost">
              How it works
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>
      </section>
    </main>
  );
}
