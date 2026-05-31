import type { Metadata } from "next";
import Link from "next/link";
import {
  Activity,
  ArrowRight,
  Bell,
  BookOpen,
  Check,
  Clock,
  Download,
  Gauge,
  Layers,
  Lock,
  Minus,
  Shield,
  Smartphone,
  Watch,
  X as XIcon,
} from "lucide-react";

import { absoluteUrl, homepageSeo, repo } from "@/lib/site";
import { UsageGauge } from "./_widgets/UsageGauge";
import { GithubMark } from "./_widgets/icons";

export const metadata: Metadata = {
  title: homepageSeo.title,
  description: homepageSeo.description,
  keywords: [...homepageSeo.keywords],
  alternates: { canonical: absoluteUrl("/") },
  openGraph: {
    type: "website",
    url: absoluteUrl("/"),
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
};

// ── Section heading helper ───────────────────────────────────
function SectionHead({
  eyebrow,
  title,
  sub,
  align = "center",
}: {
  eyebrow?: string;
  title: React.ReactNode;
  sub?: React.ReactNode;
  align?: "center" | "left";
}) {
  return (
    <div className={`max-w-3xl ${align === "center" ? "mx-auto text-center" : ""}`}>
      {eyebrow ? (
        <p className="ha-text-brand text-sm font-semibold mb-3">{eyebrow}</p>
      ) : null}
      <h2 className="ha-display ha-text-1 text-4xl sm:text-5xl">{title}</h2>
      {sub ? (
        <p className="ha-text-2 text-lg sm:text-xl mt-5 leading-relaxed">{sub}</p>
      ) : null}
    </div>
  );
}

// ── Comparison cell ──────────────────────────────────────────
type CellState = "yes" | "no" | "partial";

function CompareCell({ state }: { state: CellState }) {
  const tone =
    state === "yes"
      ? { bg: "var(--brand-50)", color: "var(--brand-600)" }
      : { bg: "var(--bg-surface)", color: "var(--txt-2)" };
  const Icon = state === "yes" ? Check : state === "partial" ? Minus : XIcon;
  return (
    <div className="flex items-center justify-center">
      <span
        className="inline-flex items-center justify-center w-7 h-7 rounded-full"
        style={{ backgroundColor: tone.bg, color: tone.color }}
        aria-label={state === "yes" ? "Yes" : state === "no" ? "No" : "Partial"}
      >
        <Icon className="w-3.5 h-3.5" aria-hidden="true" />
      </span>
    </div>
  );
}

// ── FAQ row ──────────────────────────────────────────────────
function FaqRow({ q, a }: { q: string; a: React.ReactNode }) {
  return (
    <details
      className="group ha-card ha-bg-elev"
      style={{ border: "1px solid var(--hairline)", padding: "1.25rem 1.5rem" }}
    >
      <summary
        className="cursor-pointer list-none flex items-center justify-between gap-4"
        style={{ fontWeight: 600 }}
      >
        <span className="ha-text-1 text-base sm:text-lg">{q}</span>
        <span
          className="ha-text-2 text-2xl leading-none transition-transform group-open:rotate-45"
          aria-hidden="true"
        >
          +
        </span>
      </summary>
      <div className="mt-4 ha-text-2 text-base leading-relaxed">{a}</div>
    </details>
  );
}

export default function HomePage() {
  return (
    <main className="ha-font ha-bg-base">
      {/* ═══════════════ HERO ═══════════════ */}
      <section className="relative overflow-hidden">
        <div className="ha-hero-glow" aria-hidden="true" />
        <div className="relative z-10 px-6 pt-12 pb-16 sm:pt-20 sm:pb-24">
          <div className="mx-auto max-w-6xl grid lg:grid-cols-[1.05fr_0.95fr] gap-12 lg:gap-16 items-center">
            <div className="text-center lg:text-left">
              <p className="ha-reveal ha-reveal-1 ha-text-brand text-sm font-semibold mb-5">
                For Claude Code · macOS 26+
              </p>
              <h1 className="ha-reveal ha-reveal-1 ha-hero-headline ha-text-1">
                Know when Claude Code runs out.{" "}
                <span className="ha-text-brand">Before it does.</span>
              </h1>
              <p className="ha-reveal ha-reveal-2 ha-text-2 text-lg sm:text-xl mt-6 max-w-xl mx-auto lg:mx-0 leading-relaxed">
                HowlAlert is a tiny Mac menu bar app that watches your Claude
                Code usage. It learns your real limit, shows the time left at a
                glance, and warns you before the 5-hour window runs out.
              </p>
              <div className="ha-reveal ha-reveal-3 mt-8 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3">
                <Link href="/download" className="ha-btn ha-btn-primary">
                  <Download className="w-4 h-4" />
                  Download for Mac
                </Link>
                <Link href="/docs" className="ha-btn ha-btn-secondary">
                  See how it works
                  <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
              <p className="mt-5 text-sm ha-text-2">
                Free · Open source · Reads your Mac locally · macOS 26+ · Apple
                Silicon
              </p>

              <div className="ha-reveal ha-reveal-3 mt-7 flex flex-wrap items-center justify-center lg:justify-start gap-2">
                <a
                  href={repo.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="ha-pill"
                  aria-label="View HowlAlert on GitHub"
                >
                  <GithubMark className="w-3 h-3" /> Open source · GPLv3
                </a>
                <span className="ha-pill">
                  <Shield className="w-3 h-3" /> Signed &amp; notarized by Apple
                </span>
                <span className="ha-pill">
                  <Lock className="w-3 h-3" /> Nothing leaves your Mac
                </span>
              </div>
            </div>

            <div className="ha-reveal ha-reveal-2 relative flex justify-center lg:justify-end">
              <div aria-hidden="true" className="ha-hero-card-glow" />
              <div className="ha-hero-card-float relative">
                <UsageGauge />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ═══════════════ WHAT IT WATCHES ═══════════════ */}
      <section
        id="watches"
        className="ha-bg-surface px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-6xl">
          <SectionHead
            eyebrow="What it watches"
            title={<>Three windows. One quiet wolf.</>}
            sub="Claude Code limits move and Anthropic doesn't print a number. HowlAlert reads your own usage history and tells you where you stand."
          />

          <div className="mt-14 grid md:grid-cols-3 gap-5">
            {[
              {
                icon: Clock,
                title: "The 5-hour window",
                body: "Your rolling 5-hour block, anchored to first activity. See the percent used and a plain-language time-to-empty.",
                href: "/docs/how-it-works",
                cta: "How the window works",
              },
              {
                icon: Gauge,
                title: "Your real limit",
                body: "No hard-coded plan numbers. HowlAlert estimates your limit from the P90 of your own completed windows, with a remote override when limits change.",
                href: "/docs/how-it-works",
                cta: "Why P90",
              },
              {
                icon: Layers,
                title: "Per-model usage",
                body: "See which models ate the window — Sonnet, Opus, and the rest — with a small sparkline so spikes are obvious.",
                href: "/docs/features",
                cta: "See every feature",
              },
            ].map(({ icon: Icon, title, body, href, cta }) => (
              <div key={title} className="ha-card ha-card-hover ha-glass flex flex-col">
                <div
                  className="w-11 h-11 rounded-xl inline-flex items-center justify-center mb-5"
                  style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-500)" }}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <h3 className="ha-display ha-text-1 text-xl mb-2">{title}</h3>
                <p className="ha-text-2 text-base leading-relaxed flex-1">{body}</p>
                <Link
                  href={href}
                  className="ha-text-brand mt-5 inline-flex items-center gap-1.5 text-sm font-semibold"
                >
                  {cta}
                  <ArrowRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════════ THE WINDOW ═══════════════ */}
      <section
        id="window"
        className="ha-bg-base px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-6xl grid md:grid-cols-2 gap-12 lg:gap-16 items-center">
          <div>
            <p className="ha-text-brand text-sm font-semibold mb-3">
              The 5-hour window
            </p>
            <h2 className="ha-display ha-text-1 text-4xl sm:text-5xl">
              A number you can trust, in plain words.
            </h2>
            <p className="ha-text-2 text-lg mt-5 leading-relaxed">
              HowlAlert parses your local Claude Code transcripts, rebuilds the
              5-hour window the same way the limit does, and turns it into a
              sentence:{" "}
              <span className="ha-text-1 font-medium">
                &ldquo;Runs out in 47m.&rdquo;
              </span>{" "}
              No raw token counts to decode, no dashboard to refresh.
            </p>
            <Link
              href="/docs/how-it-works"
              className="ha-text-brand mt-6 inline-flex items-center gap-1.5 text-sm font-semibold"
            >
              Read how the window is built
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          <div
            className="ha-card ha-glass space-y-2.5 text-sm ha-mono"
            aria-label="Example HowlAlert states"
          >
            <div className="flex items-center justify-between">
              <span className="ha-text-2">12% used</span>
              <span style={{ color: "var(--state-fresh)" }}>Fresh · 4h 24m left</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="ha-text-2">61% used</span>
              <span style={{ color: "var(--brand-500)" }}>OK · 1h 56m left</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="ha-text-2">84% used</span>
              <span style={{ color: "var(--state-warn)" }}>Low · runs out in 47m</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="ha-text-2">96% used</span>
              <span style={{ color: "var(--state-crit)" }}>Almost out · 11m</span>
            </div>
          </div>
        </div>
      </section>

      {/* ═══════════════ NOTIFICATIONS ═══════════════ */}
      <section
        id="alerts"
        className="ha-bg-surface px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-6xl grid md:grid-cols-2 gap-12 lg:gap-16 items-center">
          <div
            className="order-2 md:order-1 ha-card ha-glass flex items-start gap-3"
            aria-label="Example notification"
          >
            <span
              className="inline-flex items-center justify-center shrink-0"
              style={{
                width: "2.25rem",
                height: "2.25rem",
                borderRadius: "10px",
                backgroundColor: "var(--brand-50)",
                color: "var(--brand-500)",
              }}
            >
              <Bell className="w-4 h-4" />
            </span>
            <div className="min-w-0">
              <p className="ha-text-1 font-semibold text-sm">HowlAlert</p>
              <p className="ha-text-2 text-sm mt-0.5 leading-relaxed">
                16% of your 5-hour window left · resets in 47m
              </p>
            </div>
          </div>

          <div className="order-1 md:order-2">
            <p className="ha-text-brand text-sm font-semibold mb-3">Alerts</p>
            <h2 className="ha-display ha-text-1 text-4xl sm:text-5xl">
              A nudge at the edge, not a stream of noise.
            </h2>
            <p className="ha-text-2 text-lg mt-5 leading-relaxed">
              HowlAlert stays quiet until the window crosses into low or almost-out,
              then sends one local notification — and re-arms only after you
              recover. You choose the thresholds. Push to iPhone and Apple Watch
              is coming.
            </p>
            <Link
              href="/docs/features"
              className="ha-text-brand mt-6 inline-flex items-center gap-1.5 text-sm font-semibold"
            >
              See alert settings
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>
      </section>

      {/* ═══════════════ APPLE EVERYWHERE ═══════════════ */}
      <section
        id="apple"
        className="ha-bg-base px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-5xl">
          <SectionHead
            eyebrow="Built for the Apple ecosystem"
            title={<>The menu bar today. Your wrist next.</>}
            sub="Native Swift, Liquid Glass, no Electron. The Mac app ships now. iPhone and Apple Watch — with Live Activities and the Dynamic Island — are on the way."
          />

          <div className="mt-14 grid sm:grid-cols-3 gap-4">
            {[
              {
                icon: Activity,
                title: "Mac menu bar",
                body: "Always visible, one click for the full popover. Free, signed, and notarized.",
                tag: "Available now",
                live: true,
              },
              {
                icon: Smartphone,
                title: "iPhone",
                body: "A Live Activity and Dynamic Island that count your window down on the Lock Screen.",
                tag: "Coming soon",
                live: false,
              },
              {
                icon: Watch,
                title: "Apple Watch",
                body: "A complication that turns amber before you run out, so a glance is enough.",
                tag: "Coming soon",
                live: false,
              },
            ].map(({ icon: Icon, title, body, tag, live }) => (
              <div
                key={title}
                className="ha-card ha-bg-surface"
                style={{ border: "1px solid var(--hairline)" }}
              >
                <div
                  className="w-10 h-10 rounded-xl inline-flex items-center justify-center mb-4"
                  style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-500)" }}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <div className="flex items-center gap-2 mb-2">
                  <h3 className="ha-display ha-text-1 text-lg">{title}</h3>
                  <span
                    className="text-xs font-medium px-2 py-0.5 rounded-full"
                    style={{
                      backgroundColor: live ? "var(--brand-50)" : "var(--bg-base)",
                      color: live ? "var(--brand-600)" : "var(--txt-2)",
                      border: live ? "none" : "1px solid var(--hairline)",
                    }}
                  >
                    {tag}
                  </span>
                </div>
                <p className="ha-text-2 text-sm leading-relaxed">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════════════ COMPARISON ═══════════════ */}
      <section
        id="compare"
        className="ha-bg-surface px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-6xl">
          <SectionHead
            eyebrow="Honest comparison"
            title={<>Better than guessing.</>}
            sub="The usual options are checking the CLI by hand or hitting the wall mid-task. HowlAlert just watches."
          />

          <div className="mt-12 overflow-x-auto">
            <div
              className="ha-card ha-bg-elev min-w-[640px]"
              style={{ border: "1px solid var(--hairline)" }}
            >
              <table className="w-full text-sm">
                <thead>
                  <tr style={{ borderBottom: "1px solid var(--hairline)" }}>
                    <th className="text-left py-4 pr-4 ha-text-2 font-medium" scope="col">
                      What you get
                    </th>
                    <th className="text-center py-4 px-3 ha-text-brand font-semibold" scope="col">
                      HowlAlert
                    </th>
                    <th className="text-center py-4 px-3 ha-text-2 font-medium" scope="col">
                      Checking by hand
                    </th>
                    <th className="text-center py-4 pl-3 ha-text-2 font-medium" scope="col">
                      Hitting the wall
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {[
                    { feature: "Time left at a glance", ha: "yes", hand: "no", wall: "no" },
                    { feature: "Warns you before you run out", ha: "yes", hand: "no", wall: "no" },
                    { feature: "Auto-detects your real limit", ha: "yes", hand: "partial", wall: "no" },
                    { feature: "Apple Watch + iPhone (soon)", ha: "yes", hand: "no", wall: "no" },
                    { feature: "Open source & fully local", ha: "yes", hand: "partial", wall: "no" },
                  ].map((row, i, arr) => (
                    <tr
                      key={row.feature}
                      style={
                        i < arr.length - 1
                          ? { borderBottom: "1px solid var(--hairline)" }
                          : undefined
                      }
                    >
                      <td className="py-4 pr-4 ha-text-1">{row.feature}</td>
                      <td className="py-4 px-3"><CompareCell state={row.ha as CellState} /></td>
                      <td className="py-4 px-3"><CompareCell state={row.hand as CellState} /></td>
                      <td className="py-4 pl-3"><CompareCell state={row.wall as CellState} /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </section>

      {/* ═══════════════ PRIVACY ═══════════════ */}
      <section
        id="privacy"
        className="ha-bg-base px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-3xl text-center">
          <div
            className="w-12 h-12 rounded-2xl inline-flex items-center justify-center mb-6 mx-auto"
            style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-500)" }}
          >
            <Shield className="w-5 h-5" />
          </div>
          <h2 className="ha-display ha-text-1 text-4xl sm:text-5xl">
            Your usage stays yours.
          </h2>
          <p className="ha-text-2 text-lg mt-5 leading-relaxed">
            HowlAlert reads the usage files already on your Mac under{" "}
            <code className="ha-mono ha-text-1">~/.claude</code>. It never
            connects to Anthropic&rsquo;s services, and nothing about your
            prompts or code leaves your machine. When the iPhone and Watch apps
            land, the server holds only device tokens — never your usage.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-2">
            {["Local-only reads", "No telemetry", "No account needed", "Open source"].map(
              (label) => (
                <span key={label} className="ha-pill">
                  {label}
                </span>
              ),
            )}
          </div>
        </div>
      </section>

      {/* ═══════════════ PRICING ═══════════════ */}
      <section
        id="pricing"
        className="ha-bg-surface px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-5xl">
          <SectionHead
            eyebrow="Pricing"
            title={<>The Mac app is free.</>}
            sub="Download it today at no cost. Pro and Max unlock the iPhone and Apple Watch apps when they ship — both with a 7-day free trial."
          />

          <div className="mt-14 grid md:grid-cols-3 gap-5 items-stretch">
            {/* Free */}
            <div
              className="ha-card ha-bg-elev flex flex-col"
              style={{ border: "1px solid var(--hairline)" }}
            >
              <p className="ha-text-2 text-sm font-semibold">Mac app</p>
              <p className="ha-display ha-text-1 text-4xl mt-2">Free</p>
              <p className="ha-text-2 text-sm mt-1">Forever</p>
              <ul className="mt-5 space-y-2.5 text-sm ha-text-2 flex-1">
                {["Menu bar app", "5-hour window + per-model", "Local notifications", "Open source"].map(
                  (f) => (
                    <li key={f} className="flex gap-2.5">
                      <Check className="w-4 h-4 mt-0.5 shrink-0" style={{ color: "var(--brand-500)" }} />
                      <span>{f}</span>
                    </li>
                  ),
                )}
              </ul>
              <Link href="/download" className="ha-btn ha-btn-ghost mt-6">
                <Download className="w-4 h-4" />
                Download for Mac
              </Link>
            </div>

            {/* Max (highlighted, default) */}
            <div
              className="ha-card ha-bg-elev flex flex-col relative"
              style={{ border: "2px solid var(--brand-500)" }}
            >
              <span
                className="absolute -top-3 left-1/2 -translate-x-1/2 text-xs font-semibold px-3 py-1 rounded-full"
                style={{ backgroundColor: "var(--brand-500)", color: "#fff" }}
              >
                BEST VALUE
              </span>
              <p className="ha-text-brand text-sm font-semibold">HowlAlert Max</p>
              <p className="ha-display ha-text-1 text-4xl mt-2">
                $29.99<span className="ha-text-2 text-lg font-normal"> / year</span>
              </p>
              <p className="text-sm mt-1" style={{ color: "var(--brand-600)" }}>
                Save $30 vs Pro
              </p>
              <ul className="mt-5 space-y-2.5 text-sm ha-text-2 flex-1">
                {["Everything in Free", "iPhone app + Live Activity", "Apple Watch complication", "Push alerts to all your devices"].map(
                  (f) => (
                    <li key={f} className="flex gap-2.5">
                      <Check className="w-4 h-4 mt-0.5 shrink-0" style={{ color: "var(--brand-500)" }} />
                      <span>{f}</span>
                    </li>
                  ),
                )}
              </ul>
              <span className="ha-btn ha-btn-primary mt-6" style={{ opacity: 0.85, cursor: "default" }}>
                Start 7-day free trial
              </span>
              <p className="text-xs ha-text-2 text-center mt-2">Coming with the mobile apps</p>
            </div>

            {/* Pro */}
            <div
              className="ha-card ha-bg-elev flex flex-col"
              style={{ border: "1px solid var(--hairline)" }}
            >
              <p className="ha-text-2 text-sm font-semibold">HowlAlert Pro</p>
              <p className="ha-display ha-text-1 text-4xl mt-2">
                $4.99<span className="ha-text-2 text-lg font-normal"> / month</span>
              </p>
              <p className="ha-text-2 text-sm mt-1">Same features, monthly</p>
              <ul className="mt-5 space-y-2.5 text-sm ha-text-2 flex-1">
                {["Everything in Free", "iPhone app + Live Activity", "Apple Watch complication", "Push alerts to all your devices"].map(
                  (f) => (
                    <li key={f} className="flex gap-2.5">
                      <Check className="w-4 h-4 mt-0.5 shrink-0" style={{ color: "var(--brand-500)" }} />
                      <span>{f}</span>
                    </li>
                  ),
                )}
              </ul>
              <span className="ha-btn ha-btn-ghost mt-6" style={{ cursor: "default" }}>
                Start 7-day free trial
              </span>
              <p className="text-xs ha-text-2 text-center mt-2">Coming with the mobile apps</p>
            </div>
          </div>

          <p className="mt-8 text-center text-xs ha-text-2">
            Pro and Max unlock the same features — pick monthly or yearly. No third
            tier, no upsells.
          </p>
        </div>
      </section>

      {/* ═══════════════ FAQ ═══════════════ */}
      <section
        id="faq"
        className="ha-bg-base px-6 py-14 sm:py-20 lg:py-28 scroll-mt-20"
      >
        <div className="mx-auto max-w-3xl">
          <SectionHead
            eyebrow="Questions, answered"
            title={<>Anything else?</>}
            sub="The short answers. Longer ones live in the docs."
          />

          <div className="mt-12 space-y-3">
            <FaqRow
              q="Does HowlAlert connect to my Claude account?"
              a={
                <>
                  No. It reads the usage files Claude Code already writes to{" "}
                  <code className="ha-mono ha-text-1">~/.claude</code> on your Mac.
                  It never signs in to Anthropic, never sends your prompts
                  anywhere, and works fully offline.
                </>
              }
            />
            <FaqRow
              q="How does it know my limit if Anthropic doesn't show one?"
              a={
                <>
                  It estimates from your own history — the P90 of your completed
                  5-hour windows — and can pull a remote override when limits
                  change. There are no hard-coded plan numbers to go stale.
                </>
              }
            />
            <FaqRow
              q="Is it really free?"
              a={
                <>
                  The Mac menu bar app is free and open source. Paid Pro and Max
                  tiers will unlock the iPhone and Apple Watch apps when they
                  ship, each with a 7-day free trial.
                </>
              }
            />
            <FaqRow
              q="Which Macs are supported?"
              a={
                <>
                  macOS 26 (Tahoe) or newer on Apple Silicon. HowlAlert uses
                  Liquid Glass and modern APIs with no pre-26 fallback.
                </>
              }
            />
            <FaqRow
              q="Is this an official Anthropic app?"
              a={
                <>
                  No. HowlAlert is an independent, open-source project by
                  MrDemonWolf, Inc. and is not affiliated with or endorsed by
                  Anthropic. &ldquo;Claude&rdquo; and &ldquo;Claude Code&rdquo;
                  are trademarks of Anthropic, PBC.
                </>
              }
            />
            <FaqRow
              q="How do updates work?"
              a={
                <>
                  The Mac app updates through Sparkle with signed appcasts, or via{" "}
                  <code className="ha-mono ha-text-1">brew upgrade --cask</code> if
                  you install through Homebrew.
                </>
              }
            />
          </div>

          <p className="mt-10 text-center text-sm ha-text-2">
            More questions?{" "}
            <Link href="/docs/faq" className="ha-text-brand font-semibold">
              Read the full FAQ
            </Link>{" "}
            or{" "}
            <a
              href={repo.discord}
              target="_blank"
              rel="noopener noreferrer"
              className="ha-text-brand font-semibold"
            >
              ask in Discord
            </a>
            .
          </p>
        </div>
      </section>

      {/* ═══════════════ CTA ═══════════════ */}
      <section id="cta" className="ha-bg-surface px-6 py-28 sm:py-36 scroll-mt-20">
        <div className="mx-auto max-w-4xl text-center">
          <div
            className="w-12 h-12 rounded-2xl inline-flex items-center justify-center mb-6 mx-auto"
            style={{ backgroundColor: "var(--brand-50)", color: "var(--brand-500)" }}
          >
            <Activity className="w-5 h-5" />
          </div>
          <h2 className="ha-display ha-text-1 text-5xl sm:text-6xl lg:text-7xl">
            Stop guessing.
            <br />
            <span className="ha-text-brand">Let the wolf watch.</span>
          </h2>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-3">
            <Link href="/download" className="ha-btn ha-btn-primary">
              <Download className="w-4 h-4" />
              Download HowlAlert
            </Link>
            <Link href="/docs" className="ha-btn ha-btn-ghost">
              <BookOpen className="w-4 h-4" />
              Read the docs
            </Link>
            <a
              href={repo.url}
              target="_blank"
              rel="noopener noreferrer"
              className="ha-btn ha-btn-ghost"
            >
              <GithubMark className="w-4 h-4" />
              Star on GitHub
            </a>
          </div>
          <p className="mt-5 text-sm ha-text-2">
            Free · macOS 26+ · Apple Silicon · Built by{" "}
            <a
              href="https://github.com/MrDemonWolf"
              target="_blank"
              rel="noopener noreferrer"
              className="ha-text-brand font-semibold"
            >
              @MrDemonWolf
            </a>
          </p>
        </div>
      </section>
    </main>
  );
}
