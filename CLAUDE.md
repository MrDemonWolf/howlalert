# HowlAlert — Developer Guide

## What is HowlAlert?

HowlAlert is a Claude Code usage monitor for macOS, iOS, and watchOS. It watches Claude's JSONL session files, calculates token burn rate, and sends push notifications to paired Apple devices when usage approaches limits.

## Repo Structure

```
howlalert/
├── apps/
│   ├── worker/          # Cloudflare Worker — APNs push relay (Hono)
│   ├── macos/           # macOS menu bar app (Xcode)
│   ├── ios/             # iOS companion app (Xcode)
│   └── watchos/         # watchOS app (Xcode)
├── packages/
│   ├── shared-types/    # Zero-build shared TypeScript types
│   ├── config/          # Shared tsconfig/eslint configs
│   └── howlalert-kit/   # Swift Package — shared Swift logic
├── howlalert.xcodeproj/ # Single Xcode project for all Apple targets
└── ...
```

## Common Commands

```bash
bun install          # Install all JS/TS dependencies
bun dev              # Start worker dev server
bun run build        # Build all packages and apps
bun run typecheck    # Type-check all packages
bun run test         # Run all tests
bun run lint         # Lint all packages

make build-macos     # Build macOS app via xcodebuild
make build-ios       # Build iOS app via xcodebuild
make test-kit        # Run HowlAlertKit Swift tests
make deploy-worker   # Deploy Cloudflare Worker
```

## Architecture Overview

```
macOS app ──── reads ──────► ~/.claude/projects/*/*.jsonl
    │                         (Claude Code session files)
    │
    ├─ detects plan ────────► ~/.claude/.credentials.json
    │                         (subscriptionType → ClaudePlan)
    │
    ├─ calculates pace (HowlAlertKit)
    ├─ CloudKit pairing (device token sync)
    └─ POST /api/push ──────► Cloudflare Worker
                                    │
                               APNs push API
                                    │
                         iOS/watchOS notification
```

## Key Design Rules

1. **No database** — The worker is stateless. Device tokens live in CloudKit. No KV namespaces.
2. **CloudKit pairing** — Device tokens are synced via CloudKit (no sign-in, no accounts).
3. **Stateless Worker** — Receives a push payload, signs an APNs JWT, relays to Apple. Nothing stored.
4. **Local plan detection** — Plan tier (Free/Pro/Max5/Max20) is read from `~/.claude/.credentials.json`. No remote config needed.
5. **Zero-build packages** — `packages/shared-types` exports raw `.ts` files. No build step needed.
6. **HowlAlertKit** — All Swift business logic (pace engine, threshold notifier, token math, plan detection) lives in the Swift Package at `packages/howlalert-kit/`.

## Environment Variables

Worker secrets (set via `wrangler secret put <NAME>`):
- `APNS_AUTH_KEY` — PKCS#8 PEM private key (.p8 file contents)
- `APNS_KEY_ID`   — 10-char key ID from Apple Developer portal
- `APNS_TEAM_ID`  — 10-char team ID from Apple Developer portal

## Bundle IDs

- macOS: `com.mrdemonwolf.howlalert.macos`
- iOS: `com.mrdemonwolf.howlalert`
- watchOS: `com.mrdemonwolf.howlalert.watchkitapp`
- CloudKit container: `iCloud.com.mrdemonwolf.howlalert`
