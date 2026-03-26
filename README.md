# HowlAlert - Claude Code Usage Monitor for Apple Platforms

HowlAlert watches your Claude Code session files on macOS and
pushes real-time usage alerts to your iPhone and Apple Watch.
No accounts, no backend database — just CloudKit pairing and
APNs push notifications through a stateless Cloudflare Worker relay.

Never get caught off guard by a rate limit again.

## Features

- **Crit Bar** — Color-coded usage progress bar across every
  surface (cyan for OK, amber for approaching, red for limit hit,
  green for reset).
- **Pace System** — Compares your actual consumption rate against
  an even-spend rate to show if you're in debt, on track, or
  in reserve.
- **Remote Config** — Adjust limit multipliers when Anthropic
  runs promotions (like 2x off-peak) without shipping an app
  update.
- **FSEvents Watcher** — Reads Claude Code JSONL session files
  directly via macOS native file system events. No polling, no
  CLI parsing.
- **CloudKit Pairing** — Automatic device pairing via iCloud
  private database. Install on Mac and iPhone, same iCloud
  account, done.
- **Push Notifications** — Real-time alerts at 60%, 85%, and
  100% usage thresholds via APNs.
- **Demo Mode** — Fully functional demo for App Store review
  that cycles through all crit bar and pace states without
  network access.
- **Admin Dashboard** — Web-based admin panel for managing
  multiplier config, viewing push delivery logs, and monitoring
  paired devices.

## Getting Started

Full documentation is available at the
[HowlAlert Docs](https://docs.howlalert.mrdemonwolf.com).

1. Install the macOS app via Homebrew:
   ```bash
   brew install --cask mrdemonwolf/tap/howlalert
   ```
2. Install the iOS app from the App Store.
3. Sign in to the same iCloud account on both devices.
4. Pairing happens automatically via CloudKit.
5. Start using Claude Code — usage alerts will arrive on your
   iPhone and Apple Watch.

## Tech Stack

| Layer             | Technology                                    |
| ----------------- | --------------------------------------------- |
| macOS App         | Swift, SwiftUI, MenuBarExtra, FSEvents        |
| iOS App           | Swift, SwiftUI, CloudKit, APNs                |
| watchOS App       | Swift, SwiftUI, WatchConnectivity              |
| Shared Library    | Swift Package (HowlAlertKit)                  |
| Push Relay        | Cloudflare Workers, Hono, jose (JWT)          |
| Admin Dashboard   | Next.js 15, React 19, Tailwind CSS 4, SWR     |
| Documentation     | Next.js 15, Fumadocs                          |
| Device Pairing    | CloudKit (private iCloud database)            |
| Push Delivery     | Apple Push Notification Service (APNs)        |
| Config Storage    | Cloudflare KV                                 |

## Development

### Prerequisites

- Xcode 16+ (macOS 14 Sonoma SDK, iOS 17 SDK, watchOS 10 SDK)
- Swift 5.9+
- Bun 1.x (for Cloudflare Worker and docs)
- Node.js 20+ and npm (for admin dashboard)
- Wrangler CLI (for Cloudflare Workers)
- Apple Developer account (for push notifications and CloudKit)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/MrDemonWolf/howlalert.git
   cd howlalert
   ```

2. Install Worker dependencies:
   ```bash
   cd worker && bun install
   ```

3. Install admin dashboard dependencies:
   ```bash
   cd admin && npm install
   ```

4. Install docs dependencies:
   ```bash
   cd apps/docs && bun install
   ```

5. Build the shared Swift package:
   ```bash
   cd packages/HowlAlertKit && swift build
   ```

6. Run tests to verify everything works:
   ```bash
   make test
   ```

### Development Scripts

- `make help` — Show all available Makefile targets.
- `make build-mac` — Build the macOS app.
- `make build-ios` — Build the iOS app for Simulator.
- `make build-watch` — Build the watchOS app for Simulator.
- `make build-all` — Build all native targets.
- `make test` — Run all tests (HowlAlertKit unit tests).
- `make worker-dev` — Start the Cloudflare Worker locally.
- `make worker-deploy` — Deploy the Worker to production.
- `make worker-typecheck` — Typecheck the Worker source.
- `make admin-dev` — Start the admin dashboard on port 3001.
- `make admin-build` — Build the admin dashboard.
- `make admin-deploy` — Deploy admin to Cloudflare Pages.
- `make docs-dev` — Start the docs site with Turbopack.
- `make docs-build` — Build the docs site.
- `make ci` — Run full CI checks (typecheck + build + test).
- `make open-xcode` — Open the Xcode project.
- `make clean` — Remove all build artifacts and `node_modules`.

### Code Quality

- Strict TypeScript (`"strict": true`) for Worker and admin.
- SwiftLint for Swift code.
- EditorConfig enforced: tabs for source files, spaces for
  YAML/JSON.
- Conventional commits (`feat:`, `fix:`, `chore:`, `docs:`).

## Project Structure

```
howlalert/
  apps/
    macos/              macOS menu bar app (SwiftUI, FSEvents)
    ios/                iOS app (SwiftUI, CloudKit, push)
    watchos/            watchOS companion (complication, alerts)
    docs/               Documentation site (Fumadocs, legal pages)
  packages/
    HowlAlertKit/       Shared Swift package
      Sources/
        TokenMath/      PaceCalculator, LimitMultiplier
        ColorState/     ThresholdColor, CritBarView
        Models/         RemoteConfig, UsageSnapshot, PairingConfig
        Config/         ConfigFetcher, CloudKitPairing
  worker/               Cloudflare Worker (stateless APNs relay)
    src/
      routes/           /push, /config, /auth/verify, /push-log
      apns/             APNs HTTP/2 client (jose JWT)
      kv/               KV helpers for config and push log
      middleware/        Admin auth (Bearer + session cookie)
  admin/                Admin dashboard (Next.js + Tailwind)
    src/
      app/              Route groups: (auth)/login, (dashboard)/*
      components/       UI, layout, and feature components
      lib/              API client, auth helpers, constants
      hooks/            SWR hooks for config and push log
  assets/
    icon/               App icons (wolf-themed, brand colors)
    screenshots/        App Store and README screenshots
```

## License

![GitHub license](https://img.shields.io/github/license/mrdemonwolf/howlalert.svg?style=for-the-badge&logo=github)

## Contact

For questions, feedback, or support:

- Discord: [Join my server](https://mrdwolf.net/discord)

Made with love by [MrDemonWolf, Inc.](https://www.mrdemonwolf.com)
