# HowlAlert — Developer Guide

## What is HowlAlert?

HowlAlert is a Claude Code usage monitor for macOS, iOS, and watchOS. It watches Claude's JSONL session files, calculates token burn rate, and sends push notifications to paired Apple devices when usage approaches limits.

## Repo Structure

```
howlalert/
├── apps/
│   ├── worker/          # Cloudflare Worker — push relay + admin API (Hono)
│   ├── admin/           # Next.js admin dashboard
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
bun dev              # Start all dev servers (worker + admin)
bun run build        # Build all packages and apps
bun run typecheck    # Type-check all packages
bun run test         # Run all tests
bun run lint         # Lint all packages
bun run check        # Lint + format check

make build-macos     # Build macOS app via xcodebuild
make build-ios       # Build iOS app via xcodebuild
make test-kit        # Run HowlAlertKit Swift tests
make deploy-worker   # Deploy Cloudflare Worker
make deploy-admin    # Deploy admin dashboard
```

## Architecture Overview

```
macOS app ──── reads ──────► ~/.claude/projects/*/*.jsonl
    │                         (Claude Code session files)
    │
    ├─ calculates pace (HowlAlertKit)
    ├─ CloudKit pairing (device token sync)
    └─ POST /push ──────────► Cloudflare Worker
                                    │
                               APNs push API
                                    │
                         iOS/watchOS notification
```

## Key Design Rules

1. **No database** — The worker is stateless. Config and device tokens live in Cloudflare KV. Push logs are append-only KV entries.
2. **CloudKit pairing** — Device tokens are synced via CloudKit (no sign-in, no accounts). The macOS app writes tokens; the Worker reads them via a shared KV namespace.
3. **Stateless Worker** — The worker never stores session data. It receives a push payload, validates the admin secret, calls APNs, and logs the result.
4. **Zero-build packages** — `packages/shared-types` exports raw `.ts` files. No build step needed — bundlers resolve directly.
5. **HowlAlertKit** — All Swift business logic (pace engine, threshold notifier, token math) lives in the Swift Package at `packages/howlalert-kit/`.

## Environment Variables

Worker (set in Cloudflare dashboard or `wrangler.toml` secrets):
- `ADMIN_SECRET` — shared secret for admin API auth
- `APNS_KEY_ID` — APNs key ID
- `APNS_TEAM_ID` — Apple Developer Team ID
- `APNS_PRIVATE_KEY` — APNs private key (p8 contents)
- `APNS_BUNDLE_ID` — app bundle ID (com.mrdemonwolf.howlalert)

## Bundle IDs

- macOS: `com.mrdemonwolf.howlalert.macos`
- iOS: `com.mrdemonwolf.howlalert`
- watchOS: `com.mrdemonwolf.howlalert.watchkitapp`
- CloudKit container: `iCloud.com.mrdemonwolf.howlalert`
