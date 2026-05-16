# HowlAlert - Claude Code Usage Monitor for the Apple Ecosystem

HowlAlert watches your Claude Code usage in real time and warns you before
you hit your 5-hour or weekly limit. It runs as a free macOS menu-bar app
and a paid iOS + watchOS companion, with push notifications, Live Activity,
Dynamic Island, and watch complications so you always know how much room
is left in the window.

Stop guessing. Start howling before the limit hits.

## Features

- **Menu-bar at a glance** - Idle / warn / crit icon states driven by
  real usage. No Dock icon, no clutter.
- **FSEvents + Stop hook watching** - Reads `~/.claude/projects/**/*.jsonl`
  and Claude Code's Stop hook events the moment they land.
- **P90 plan-limit auto-detect** - Plan limits are inferred from your own
  last 30 days. No hard-coded ceilings that go stale when Anthropic ships
  changes.
- **APNs push to iPhone** - A stateless Cloudflare Worker relays threshold
  alerts. Mac quiet, iPhone loud.
- **Live Activity + Dynamic Island** - Lock Screen bar that depletes
  left-to-right as you burn the window down.
- **watchOS complications + Smart Stack widget** - Corner, circular,
  rectangular, inline. Smart Stack surfaces when relevance is high.
- **CloudKit-only storage** - Your data lives in your private iCloud
  database. No backend DB, no analytics pipeline, no telemetry.
- **Sparkle 2 auto-updates** - EdDSA-signed updates for the macOS app,
  delivered through the official appcast.
- **Demo Mode** - Works end-to-end with zero iCloud setup, so reviewers
  and friends can try it instantly.

## Getting Started

Full architecture and design docs live in [`PLAN.md`](PLAN.md). The
build plan and per-phase test instructions live in [`PHASES.md`](PHASES.md).
Always read [`CLAUDE.md`](CLAUDE.md) first if you are contributing.

For the macOS app:

1. Install the cask:
   ```bash
   brew tap mrdemonwolf/den
   brew install --cask howlalert
   ```
2. Launch HowlAlert from `/Applications`. The icon appears in your menu
   bar; there is no Dock icon.
3. Grant Notifications permission when prompted.
4. Pair with your iPhone (optional) from `Settings > Pairing`.

For the iOS + watchOS app: install from the App Store (link added at
launch).

## Usage

The macOS app runs in the background. Click the menu-bar icon to open
the popover. The icon state tells you the most important thing:

| Icon | Meaning |
| ---- | ------- |
| Cyan outline | Idle. You have plenty of room in the window. |
| Amber filled | Warn. 80% of the window is gone. |
| Red filled | Crit. 95% used. Wrap up the current task. |

Push notifications fire at 80% and 95% thresholds, and again when the
window resets. The iOS app mirrors the same states with a richer
dashboard plus a Live Activity on the Lock Screen.

### Pricing

| Tier | Price | Includes |
| ---- | ----- | -------- |
| Free (macOS) | $0 | Menu-bar app, local notifications, Sparkle updates |
| HowlAlert Pro | $4.99 / month | iOS + watchOS app, push, Live Activity, complications, Smart Stack |
| HowlAlert Max | $29.99 / year | Same as Pro, billed annually. Save $30. |

Both paid tiers include a 7-day free trial for new subscribers.

## Tech Stack

| Layer | Technology |
| ----- | ---------- |
| macOS app | Swift 6, SwiftUI, macOS 26, `MenuBarExtra`, FSEvents, Sparkle 2.x |
| iOS + watchOS app | Swift 6, SwiftUI, iOS 26, watchOS 26, ActivityKit, WidgetKit |
| Push relay | TypeScript, Hono, Cloudflare Workers |
| Admin dashboard | Next.js 15, Cloudflare Pages |
| Storage | CloudKit private database |
| In-app purchase | RevenueCat (Hosted Paywall) |
| Monorepo | Turborepo, Bun workspaces |
| Lint / format | Biome (TS), swift-format (Swift) |

## Development

### Prerequisites

- macOS 26 or later
- Xcode 26 or later
- Bun 1.1 or later
- A paid Apple Developer account (for signing, notarization, APNs)
- `wrangler` CLI for Cloudflare Worker deploys

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/mrdemonwolf/howlalert.git
   cd howlalert
   ```
2. Install JS workspaces:
   ```bash
   bun install
   ```
3. Open the Xcode workspace:
   ```bash
   open HowlAlert.xcworkspace
   ```
4. Pull the CodexBar reference repo (read-only for Swift patterns):
   ```bash
   git clone https://github.com/steipete/CodexBar.git \
     /Users/$(whoami)/Developer/tmp/CodexBar
   ```

### Development Scripts

- `bun run dev` - Run all workspace `dev` tasks via Turborepo.
- `bun run build` - Build all workspace `build` tasks.
- `bun run lint` - Lint all workspaces.
- `bun run typecheck` - Type-check all TypeScript workspaces.
- `bun run test` - Run all workspace test suites.

Swift targets are built from Xcode. The `Makefile` wraps common
Swift + Bun tasks.

### Code Quality

- Conventional commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`).
- Solo Main Protection ruleset on the repo. Never force-push to `main`.
- Tests written alongside the 5-hour window math and JSONL parser
  (those have edge cases that bite later).
- Biome for TS, swift-format for Swift.

## Project Structure

```
howlalert/
├── apps/
│   ├── macos/             # SwiftUI menu-bar app (free)
│   ├── ios/               # SwiftUI iOS app (paid)
│   ├── watchos/           # watchOS companion target
│   ├── worker/            # Cloudflare Worker (Hono, APNs relay)
│   └── admin/             # Next.js admin dashboard (post-launch)
├── packages/
│   ├── howlalert-kit/     # Swift Package (providers, pace math)
│   ├── shared-types/      # TypeScript types + Zod schemas
│   └── config/            # Shared tsconfig / lint config
├── distribution/          # appcast.xml, homebrew tap, DMG assets
├── docs/                  # GitHub Pages source
├── assets/                # Logo + icon spec
├── .github/workflows/     # CI/CD (build, notarize, release)
├── CLAUDE.md              # Contributor rules (read first)
├── PLAN.md                # Architecture bible
├── PHASES.md              # Build plan, Phases 0-4
├── HowlAlert.xcworkspace  # Xcode workspace
├── package.json
└── turbo.json
```

## License

![GitHub license](https://img.shields.io/github/license/mrdemonwolf/howlalert.svg?style=for-the-badge&logo=github)

## Contact

Questions, bug reports, or feedback:

- Discord: [Join my server](https://mrdwolf.net/discord)
- Issues: [github.com/mrdemonwolf/howlalert/issues](https://github.com/mrdemonwolf/howlalert/issues)

---

Made with love by [MrDemonWolf, Inc.](https://www.mrdemonwolf.com)
