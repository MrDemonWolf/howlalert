# HowlAlert v2.0

Claude Code usage monitor — Mac → iPhone → Apple Watch via push.

## Product

- **Name:** HowlAlert (never "Howl Alert")
- **Company:** MrDemonWolf, Inc.
- **Copyright:** © 2026 MrDemonWolf, Inc.
- **Support:** support@mrdemonwolf.com
- **Legal:** legal@mrdemonwolf.com

## Architecture

```
~/.claude/projects/**/*.jsonl
        │ FSEvents
        ▼
  macOS menu bar ──► Cloudflare Worker ──► APNs ──► iOS ──► Watch
       │                    │
       └─ CloudKit ◄────────┴─ D1 entitlement check
          (auto-pair)
```

## Bundle IDs

- iOS: `com.mrdemonwolf.howlalert`
- watchOS: `com.mrdemonwolf.howlalert.watchkitapp`
- macOS: `com.mrdemonwolf.howlalert.mac`
- CloudKit: `iCloud.com.mrdemonwolf.howlalert`
- App Group: `group.com.mrdemonwolf.howlalert`

## Deployment Targets

- macOS 15.0 (Sequoia) — Apple Silicon only
- iOS 17.0
- watchOS 10.0

## Tech Stack

- **Monorepo:** Better-T-Stack (Turborepo + Bun)
- **Backend:** Hono on Cloudflare Workers + KV + D1
- **Docs:** Fumadocs → GitHub Pages
- **Apple:** SwiftUI, Swift 6, Xcode 16
- **Swift Package:** `packages/HowlAlertKit/`
- **Push:** APNs via `@fivesheepco/cloudflare-apns2`
- **Pairing:** CloudKit private DB
- **Monetization:** RevenueCat SDK v5.x — $3.99/mo or $35.99/yr

## Brand Colors

- Deep navy: `#091533`
- Cyan: `#0FACED`
- Amber (approaching): `#F5A623`
- Red (limit hit): `#FF3B30`
- Green (reset): `#34C759`

## Commands

```bash
make dev-worker     # Hono dev server
make dev-docs       # Fumadocs dev server
make build-kit      # swift build HowlAlertKit
make test-kit       # swift test HowlAlertKit
make build-macos    # Xcode build macOS app
make build-ios      # Xcode build iOS app
make deploy-worker  # wrangler deploy
make deploy-docs    # Build docs static export
```

## Rules

1. TypeScript only — no .js files
2. Conventional commits
3. Every commit must build
4. Never `git push` without asking
5. macOS is free (Developer ID notarized). iOS is paid.
6. Cloudflare free tier — $0/month target
7. No analytics SDKs, no crash reporting SDKs that collect PII
