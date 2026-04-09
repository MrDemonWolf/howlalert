# HowlAlert

Real-time Claude Code usage monitor for macOS, iOS, and watchOS.

HowlAlert watches your Claude Code session files, calculates your token burn rate against your plan limit, and sends push notifications to your iPhone or Apple Watch before you hit the wall.

## Install

```bash
brew install --cask mrdemonwolf/tap/howlalert
```

Or download the latest `.dmg` from [Releases](https://github.com/mrdemonwolf/howlalert/releases).

## Development Setup

**Requirements:** Xcode 16+, Bun 1.3+, Swift 5.10+

```bash
# Clone
git clone https://github.com/mrdemonwolf/howlalert
cd howlalert

# Install JS/TS dependencies
bun install

# Start worker + admin in dev mode
bun dev

# Open native apps in Xcode
open howlalert.xcodeproj
```

## Architecture

```
macOS app ──── reads ──────► ~/.claude/projects/*/*.jsonl
    │
    ├─ HowlAlertKit (pace engine, thresholds)
    ├─ CloudKit (device pairing, no accounts)
    └─ POST /push ──────────► Cloudflare Worker ──► APNs ──► iPhone/Watch
```

| Layer | Tech |
|---|---|
| Native apps | Swift, SwiftUI |
| Shared Swift logic | Swift Package (HowlAlertKit) |
| Push relay | Cloudflare Worker (Hono + TypeScript) |
| Admin dashboard | Next.js 15 + Tailwind CSS |
| Shared types | TypeScript (zero-build workspace package) |
| Pairing | CloudKit (iCloud.com.mrdemonwolf.howlalert) |

## Monorepo

```
apps/worker/         Cloudflare Worker push relay
apps/admin/          Next.js admin dashboard
apps/macos/          macOS menu bar app
apps/ios/            iOS companion app
apps/watchos/        watchOS app
packages/shared-types/   Shared TypeScript types
packages/howlalert-kit/  Shared Swift Package
packages/config/         Shared tooling configs
```

## Links

- [Documentation](https://howlalert.mrdemonwolf.com/docs)
- [Privacy Policy](https://howlalert.mrdemonwolf.com/legal/privacy-policy)
- [Terms of Service](https://howlalert.mrdemonwolf.com/legal/terms-of-service)
