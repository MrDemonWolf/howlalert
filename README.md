<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-light.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/logo.svg">
    <img alt="HowlAlert" src="assets/logo.svg" width="400">
  </picture>
</p>

# HowlAlert - Monitor Claude Code Spending with Push Notifications

Monitor your Claude Code usage and get push notifications when you hit spending thresholds. Native apps for macOS, iOS, and watchOS.

## Features

- **Real-Time Usage Monitoring** — Track Claude Code API spending as events come in
- **Threshold Alerts** — Get push notifications when daily cost, token count, or session count exceeds your configured limits
- **Apple Push Notifications** — Native APNs integration delivers alerts instantly to all your devices
- **Multi-Platform** — Native SwiftUI apps for macOS, iOS, and watchOS
- **watchOS Complications** — Glanceable ring complication showing spend against threshold right on your watch face
- **Configurable Preferences** — Set custom thresholds per metric type (daily cost, tokens, sessions)
- **Secure Auth** — Sign In with Apple JWT verification in production, dev bypass for local development
- **Edge-First API** — Cloudflare Workers with D1 + KV for globally distributed, low-latency backend
- **Full Documentation** — Fumadocs-powered docs site with quickstart, API reference, and troubleshooting

## Getting Started

Check out the [full documentation](https://mrdemonwolf.github.io/howlalert/) for detailed guides.

1. **Sign in** with your Apple ID in the HowlAlert app
2. **Configure thresholds** for daily cost, token count, or session count
3. **Submit usage events** via the API (or integrate with your Claude Code workflow)
4. **Receive push notifications** when your spending exceeds configured limits

## Usage

HowlAlert works by collecting usage events submitted to its API. Each event includes cost, token count, and session metadata. The edge-first API evaluates your configured thresholds in real time and sends push notifications through APNs when limits are exceeded.

Events can be submitted programmatically via `POST /event` with a valid Apple auth token. The native apps handle device registration, preference management, and displaying your usage history.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Native Apps | Swift, SwiftUI (macOS / iOS / watchOS) |
| API | Hono 4.x on Cloudflare Workers |
| Database | Cloudflare D1 (SQLite) |
| Key-Value Store | Cloudflare KV |
| Push Notifications | Apple Push Notification Service (APNs) |
| Documentation | Next.js 15, Fumadocs v14, MDX |
| Auth | Sign In with Apple (JWT) |
| Package Manager | Bun |
| Build Tools | Xcode, Wrangler, Make |

## Development

### Prerequisites

- Xcode 16+
- Bun
- Wrangler CLI
- Node 20+

### Setup

```bash
# Clone the repo
git clone https://github.com/mrdemonwolf/howlalert.git
cd howlalert

# Install API dependencies
cd apps/api && bun install && cd ../..

# Install docs dependencies
cd apps/docs && bun install && cd ../..

# Start the API locally
make worker-dev

# Start the docs site
make docs-dev

# Open the native app in Xcode
make open-xcode
```

### Development Scripts

All common operations are available via the root `Makefile`. Run `make help` to list them.

```bash
# API
make worker-dev           # Local dev server
make worker-deploy        # Deploy to production
make apply-migrations     # Run D1 migrations (local)

# Docs
make docs-dev             # Dev server with Turbopack
make docs-build           # Production build

# Native
make build-mac            # Build macOS target
make build-ios            # Build iOS Simulator target
make build-watch          # Build watchOS Simulator target
make build-all            # Build all targets
make test                 # Run HowlAlertKit tests

# CI
make ci                   # Full CI pipeline
```

### Code Quality

- TypeScript strict mode enabled across all TS apps
- Tabs for indentation (size 4) in source files, spaces (size 2) for YAML/JSON
- ESLint configured for the API (`cd apps/api && bun run lint`)
- Type checking via `cd apps/api && bun run typecheck`

## Branches

- **`main`** — Production-ready code. Protected branch, requires pull request reviews.
- Feature branches follow conventional prefixes: `feat/`, `fix/`, `docs/`, `ci/`.

## Project Structure

```
howlalert/
  apps/
    api/          Cloudflare Worker (Hono + D1 + KV)
    docs/         Next.js 15 docs site (Fumadocs)
    native/       SwiftUI multiplatform app (macOS / iOS / watchOS)
  assets/         Logo and brand assets
  Makefile        All build/dev/deploy commands
```

## License

[![License](https://img.shields.io/github/license/mrdemonwolf/howlalert?style=for-the-badge)](LICENSE)

## Contact

[![Discord](https://img.shields.io/discord/451737538209751050?color=7289DA&label=Discord&logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/invite/mrdemonwolf)

---

<p align="center">Made with love by <a href="https://github.com/mrdemonwolf">MrDemonWolf, Inc.</a></p>
