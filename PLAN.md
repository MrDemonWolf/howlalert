# HowlAlert — Master Plan (v3)

<p align="center">
  <img src="./assets/logo.svg" alt="HowlAlert logo" width="160" />
</p>

**HowlAlert** is a Claude Code usage monitor for the Apple ecosystem. Watches Claude Code session files on macOS, calculates token burn pace, and pushes alerts to iPhone + Apple Watch when you're approaching a limit or when Claude finishes replying.

- **Owner:** Nathanial Henniges (MrDemonWolf, Inc.)
- **Repo:** `mrdemonwolf/howlalert`
- **Docs:** `mrdemonwolf.github.io/howlalert`
- **Jira:** `mrdemonwolf.atlassian.net` — project key `HAA`
- **Brand:** deep navy `#091533`, cyan `#0FACED`

**Target:** MVP 1 shipped to App Store within ~2 weeks of Phase 0 start.

---

## 0. What changed in v3

This plan supersedes previous plan docs. Deltas:

1. **Claude Opus 4.7 shipped April 16, 2026.** New tokenizer counts ~1.0–1.35x more tokens per request than Opus 4.6. Token math must be model-aware — pace calculations now require knowing which model ran each request so the budget isn't silently overrun.
2. **Claude Code 2.1.111+ ships `xhigh` effort level** between `high` and `max`. Auto mode is now GA for Max subscribers on Opus 4.7.
3. **Claude's tertiary limit is now "Current week (Sonnet only)"** — was "Opus". Parser must match new wording (with legacy fallback).
4. **Gemini CLI is easier than we thought.** CodexBar ships Gemini via OAuth-backed quota API using Gemini CLI credentials (not by parsing `~/.gemini/tmp/**/*.json`). Gemini moves from "scary v2.0" to "tractable v2.0" — still deferred, but the door is clearer.
5. **Explicit MVP split:** MVP 1 = minimum shippable to App Store. MVP 2 = Gemini + polish. MVP 3+ = everything else. See `MVP1.md` and `MVP2.md`.
6. **New infra URLs:** Worker at `howlalert.mrdemonwolf.workers.dev`; docs at `mrdemonwolf.github.io/howlalert`.

---

## 1. MVP scopes at a glance

| | **MVP 1 (SHIP)** | **MVP 2** | **MVP 3+** |
|---|---|---|---|
| **Platforms** | macOS, iOS, watchOS | same | same |
| **Providers** | Claude Code only (Gemini protocol stubbed) | + Gemini CLI (OAuth API) | + Codex / Cursor / others |
| **Distribution** | iOS + watchOS → App Store · macOS → notarized DMG + Homebrew cask | same | same |
| **Pricing** | $3.99/mo · $35.99/yr · 7-day trial (RevenueCat) | same | tier bumps? |
| **Pairing** | CloudKit auto-pair (same iCloud = linked) | same | — |
| **Pace math** | debt / on-track / reserve, model-aware for Opus 4.7 | + historical pace profiles | + predictive ML |
| **Alerts** | 60 / 85 / 100% thresholds + Claude-done event | + Live Activity / Dynamic Island | + Smart Stack tiles |
| **Multi-Mac** | Yes (aggregated on iOS) | + "Active Macs" card polish | — |
| **Demo Mode** | Required on all 3 platforms | same | same |
| **Admin dashboard** | Deferred | Cloudflare Pages + limit multiplier remote config | + push log analytics |
| **Widgets** | Deferred | iOS Home Screen + macOS desktop widgets | Watch complications family full set |
| **Observability** | MetricKit only | + anonymous aggregate stats (opt-in) | — |

---

## 2. Locked architecture

**Components:**

1. **macOS menu bar app** — Swift/SwiftUI, `LSUIElement = true` (icon-only, no Dock), FSEvents watcher on `~/.claude/**`, Claude Code `Stop` hook fires pushes, Sparkle for updates, SMAppService for launch-at-login
2. **Cloudflare Worker** — stateless Hono TypeScript app, ~80 lines, pure APNs relay + RevenueCat webhook receiver, stores nothing personal. Deployed to `howlalert.mrdemonwolf.workers.dev`.
3. **iOS app** — SwiftUI, CloudKit private DB for history + entitlement + pairing secrets, RevenueCat paywall, Demo Mode, push handler, multi-Mac aggregator
4. **watchOS app** — companion to iOS, complication showing current pace, notification view with crit bar
5. **Shared Swift package — `howlalert-kit`** — `UsageProvider` protocol, `ClaudeCodeProvider`, `PaceCalculator`, `ColorState`, data models. `GeminiCLIProvider` stub only in MVP 1.
6. **Docs site** — GitHub Pages served from `/docs` folder at `mrdemonwolf.github.io/howlalert`
7. **Admin web dashboard** — Next.js on Cloudflare Pages. **Deferred to MVP 2.**
8. **Shared TS package — `shared-types`** — types shared by Worker + Admin

**Non-negotiables:**

- **No backend DB for user data.** CloudKit private DB only. Worker is stateless except entitlement lookup in D1.
- **No user accounts.** iCloud account IS the identity.
- **macOS is not Mac App Store.** Sandboxing blocks the file watching we need.
- **No third-party tracking.** MetricKit only — preserves the "no tracking" product promise.
- **Cloudflare free tier is a hard constraint.** D1 is primary store. KV only for hot reads (1K writes/day limit is binding).

**Repo layout (Better-T-Stack / fangdash pattern):**

```
howlalert/
├── apps/
│   ├── macos/           # SwiftUI menu bar app
│   ├── ios/             # SwiftUI iOS app
│   ├── watchos/         # SwiftUI watchOS companion
│   ├── worker/          # Hono on Cloudflare Workers (Bun)
│   └── admin/           # Next.js on Cloudflare Pages (DEFERRED — scaffold only)
├── packages/
│   ├── howlalert-kit/   # Swift Package
│   ├── shared-types/    # TS types
│   └── config/          # shared tsconfig/eslint/prettier
├── docs/                # GitHub Pages source
├── assets/
├── .github/workflows/
├── Makefile
├── turbo.json
├── package.json
├── CLAUDE.md
├── PLAN.md              # this file
├── MVP1.md
├── MVP2.md
├── TODO.md
└── README.md
```

---

## 3. Opus 4.7 impact on pace math

This is new and must be handled in MVP 1.

**The problem:** Opus 4.7 uses a new tokenizer. The same prompt can count as up to 35% more tokens than on Opus 4.6. If HowlAlert treats all tokens as equal-weight, a user on Opus 4.7 will hit their limit *before* HowlAlert's pace math thinks they should.

**The fix — model-aware pace:**

1. Parse `model` field from each Claude Code JSONL event
2. `PaceCalculator` keeps per-model token totals: `{ "claude-opus-4-7": 8920, "claude-opus-4-6": 12340, "claude-sonnet-4-6": 4500 }`
3. No weighting multiplier — Claude's own API returns real token counts per model; we trust what's in the JSONL
4. **Effort level is the new concern:** `xhigh` on Opus 4.7 burns significantly more tokens than `high`. Settings UI exposes a "track effort level" toggle (on by default) so users see effort mix in the popover
5. Weekly limit label: match both `"Current week (Sonnet only)"` (new) and `"Opus"` (legacy fallback) — the CLI wording changed

**Out of scope for MVP 1:**
- Cross-model budget rebalancing
- Per-model pace visualization (shows combined only)

---

## 4. Provider protocol — ready for Gemini in MVP 2

**`howlalert-kit/Sources/HowlAlertKit/UsageProvider.swift`** (MVP 1):

```swift
public protocol UsageProvider: Sendable {
    var id: String { get }                 // "claude-code", "gemini-cli"
    var displayName: String { get }
    var isEnabled: Bool { get }
    var watchPaths: [URL] { get }          // FSEvents targets (empty for API providers)
    func refresh() async throws -> UsageSnapshot
    func detectDoneEvent(_ snapshot: UsageSnapshot) -> Bool
}
```

- **`ClaudeCodeProvider`** — full implementation in MVP 1. FSEvents + JSONL parser.
- **`GeminiCLIProvider`** — **stub only** in MVP 1. File exists, protocol conformance compiles, `refresh()` throws `.notImplemented`. Settings UI has a toggle that's disabled with "Coming in v2" label. MVP 2 fills it in via Gemini's loadCodeAssist OAuth quota API (CodexBar reference pattern).

The point of the stub: zero refactor in MVP 2. `UsageProvider` is designed once, hardened during MVP 1, Gemini slots in later.

---

## 5. Tech stack (locked)

| Layer | Choice |
|---|---|
| macOS / iOS / watchOS | Swift 6, SwiftUI, `@Observable`, Xcode 16+ |
| Shared Swift | Swift Package `howlalert-kit`, target macOS 15 / iOS 18 / watchOS 11 |
| Worker | TypeScript, Hono, Cloudflare Workers |
| Admin (MVP 2) | Next.js App Router, Tailwind, Cloudflare Pages |
| Data | D1 (entitlements), KV (hot reads, remote config), CloudKit private DB (user data) |
| Subscriptions | RevenueCat (iOS-side), CloudKit Entitlement record (Mac-side sync) |
| Updates | Sparkle (macOS), App Store (iOS/watchOS) |
| Docs | GitHub Pages, source in `/docs` on `main`, Fumadocs or MkDocs Material |
| CI/CD | GitHub Actions, auto-notarize + auto-PR to `mrdemonwolf/homebrew-den` |
| Monorepo | Bun + Turborepo (Better-T-Stack) |
| Crash reports | MetricKit (Apple-native, no third parties) |

---

## 6. Pricing (locked)

- `howlalert_pro_monthly` — $3.99
- `howlalert_pro_yearly` — $35.99 (25% off monthly)
- 7-day free trial on both
- Apple Small Business Program — 15% commission
- macOS app itself is **free to download**. Features gate on iOS entitlement via CloudKit sync.

---

## 7. Success metrics for MVP 1

- iOS + watchOS submitted to App Store
- macOS DMG + Homebrew cask live
- First paying customer
- Zero App Review rejections (Demo Mode works first try)
- Zero known crashes in MetricKit for 7 days post-launch
- Push latency P95 < 5s (JSONL write → iPhone banner)

---

## 8. How to run this plan

1. Nathanial clears `BLOCK 1` manual tasks in `TODO.md` (Apple Dev, App Store Connect, RevenueCat, Cloudflare). ~2 hours of portal clicking.
2. Claude Code executes phases sequentially via `MVP1.md` (0 → 10).
3. After MVP 1 ships and stabilizes for 14 days, Claude Code starts `MVP2.md` (11 → 15).
4. All docs for users go in `/docs` — the GitHub Pages site auto-updates on push to `main`.
