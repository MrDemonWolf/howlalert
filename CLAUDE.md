# HowlAlert — Claude Code Guide

## Repository structure

Monorepo with three independent apps — no workspace tooling (no npm/bun workspaces). Each app manages its own dependencies.

```
apps/
  api/       Cloudflare Worker (Hono + D1 + KV)
  docs/      Next.js 15 docs site (Fumadocs)
  native/    SwiftUI multiplatform app (macOS / iOS / watchOS)
```

## Commands

All common operations are in the root `Makefile`. Run `make help` to list them.

### API (Cloudflare Worker)
```sh
make worker-dev      # wrangler dev (local)
make worker-deploy   # wrangler deploy (production)
cd apps/api && bun run typecheck   # tsc --noEmit
cd apps/api && bun run lint        # eslint src
make apply-migrations              # D1 migrations — local
make apply-migrations-prod         # D1 migrations — production
```

### Docs
```sh
make docs-dev    # next dev --turbopack
make docs-build  # next build
```

### Native (Swift)
```sh
make build-mac      # xcodebuild macOS
make build-ios      # xcodebuild iOS Simulator
make build-watch    # xcodebuild watchOS Simulator
make build-all      # all three targets
make test           # swift test (HowlAlertKit SPM package only)
make open-xcode     # open apps/native/howlalert.xcodeproj
make update-deps    # swift package update
```

### CI
```sh
make ci   # typecheck API + docs build + swift test
```

## API architecture

- **Runtime**: Cloudflare Workers, `nodejs_compat` flag enabled
- **Framework**: Hono 4.x with `{ Bindings: Env }` generic pattern
- **Storage**:
  - KV namespace `HOWLALERT_DEVICES` (binding name) — devices and preferences
  - D1 database `howlalert-db` (binding `DB`) — usage event history
- **Package manager**: Bun

### KV key naming
| Key | Content |
|-----|---------|
| `device:{userId}:{deviceToken}` | `DeviceRegistration` JSON |
| `prefs:{userId}` | `UserPreferences` JSON |
| `apple_public_keys` | Cached Apple JWKS (TTL 24h) |

### Auth flow
Every protected endpoint calls `verifyAppleToken(c)` which:
1. Reads `Authorization: Bearer <token>` header
2. In `development` env: returns `dev_user_{token.slice(0,8)}` (no real verification)
3. In production: fetches/caches Apple public keys, verifies JWT signature (RSASSA-PKCS1-v1_5 / SHA-256), validates `iss`, `aud` (`com.mrdemonwolf.howlalert`), and `exp`

### Threshold alerting
On each `POST /event`, the worker:
1. Inserts the event into D1
2. Fetches today's daily cost summary
3. Loads user preferences from KV (`prefs:{userId}`)
4. Compares daily cost against configured threshold (default $5.00 if no prefs)
5. If exceeded, sends APNs push to every registered device for that user

### Threshold types
```ts
type: "daily_cost" | "token_count" | "session_count"
```

## Docs architecture

- **Framework**: Next.js 15 + React 19, Turbopack in dev
- **Docs engine**: Fumadocs (fumadocs-core, fumadocs-mdx, fumadocs-ui) v14
- Content lives in `apps/docs/content/docs/` as MDX files
- Source configured via `apps/docs/source.config.ts`

## Native architecture

- **Language**: Swift, SwiftUI multiplatform
- **Targets**: macOS, iOS, watchOS — single scheme `howlalert`
- **Xcode project**: `apps/native/howlalert.xcodeproj`
- **SPM package**: `apps/native/howlalert/HowlAlertKit/` — testable library code, tested independently with `swift test`
- **Bundle ID**: `com.mrdemonwolf.howlalert`

## Code style

Enforced by `.editorconfig`:
- **Tabs** for indentation (size 4) in all source files
- **Spaces** (size 2) for YAML / JSON
- LF line endings, UTF-8, trailing newline required

TypeScript is strict (`tsconfig.json` in each app). No `any` without justification.
