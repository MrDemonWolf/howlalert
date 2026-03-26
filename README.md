# HowlAlert

Claude Code usage monitor & push notification system for Apple platforms — macOS menu bar, iOS, watchOS.

## Overview

HowlAlert watches your Claude Code session files on macOS and pushes real-time usage alerts to your iPhone and Apple Watch. No accounts, no backend database — just CloudKit pairing and APNs.

```
┌─────────────┐    HTTPS     ┌──────────────────┐    APNs    ┌─────────────┐
│  macOS App   │ ──────────► │ Cloudflare Worker │ ────────► │  iOS / watch │
│ (FSEvents)   │             │ (stateless relay) │           │ (CloudKit)   │
└─────────────┘             └──────────────────┘           └─────────────┘
```

## Features

- **Crit Bar** — color-coded usage progress (cyan → amber → red)
- **Pace System** — are you burning through your limit too fast?
- **Remote Config** — adjust multipliers when Anthropic runs promotions
- **Demo Mode** — try the app without a Mac (for App Store review)

## Installation

### macOS

```bash
brew install --cask mrdemonwolf/tap/howlalert
```

### iOS & watchOS

Download from the [App Store](https://apps.apple.com/app/howlalert).

## Development

```bash
make help          # Show all available commands
make build-all     # Build all native targets
make test          # Run Swift tests
make worker-dev    # Run Worker locally
make admin-dev     # Run admin dashboard locally
make docs-dev      # Run docs site locally
```

## Project Structure

```
apps/
  macos/         macOS menu bar app (SwiftUI)
  ios/           iOS app (SwiftUI)
  watchos/       watchOS companion (SwiftUI)
  docs/          Documentation site (Fumadocs)
packages/
  HowlAlertKit/  Shared Swift package (pace calculator, models)
worker/          Cloudflare Worker (Hono, stateless APNs relay)
admin/           Admin dashboard (Next.js, Tailwind)
```

## License

[MIT](LICENSE) — MrDemonWolf, Inc.
