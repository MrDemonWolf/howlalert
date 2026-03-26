# HowlAlert — Claude Code Guide

## Repository structure

Monorepo with five independent apps — no workspace tooling. Each app manages its own dependencies.

```
apps/
  macos/         macOS menu bar app (SwiftUI, FSEvents)
  ios/           iOS app (SwiftUI, CloudKit, APNs)
  watchos/       watchOS companion (WatchConnectivity)
  docs/          Next.js 15 docs site (Fumadocs)
packages/
  HowlAlertKit/  Shared Swift package (pace, models, UI)
worker/          Cloudflare Worker (Hono, stateless APNs relay)
admin/           Admin dashboard (Next.js 15, Tailwind CSS 4)
```

## Commands

All common operations are in the root `Makefile`. Run `make help` to list them.

### Worker (Cloudflare)
```sh
make worker-dev        # wrangler dev (local)
make worker-deploy     # wrangler deploy (production)
make worker-typecheck  # tsc --noEmit
```

### Admin Dashboard
```sh
make admin-dev     # next dev (port 3001)
make admin-build   # next build
make admin-deploy  # deploy to Cloudflare Pages
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
make open-xcode     # open Xcode project
make update-deps    # swift package update
```

### CI
```sh
make ci   # worker typecheck + docs build + swift test
```

## Worker architecture

- **Runtime**: Cloudflare Workers, `nodejs_compat` flag enabled
- **Framework**: Hono 4.x with `{ Bindings: Env }` generic pattern
- **URL**: `https://howlalert-worker.mrdemonwolf.workers.dev`
- **Storage**: KV only (stateless relay, no D1)
  - `HOWLALERT_CONFIG` — remote limit config (multiplier, schedule)
  - `HOWLALERT_PUSH_LOG` — ring buffer of push delivery logs (30-day TTL)
- **Package manager**: Bun

### Routes
| Route | Auth | Purpose |
|-------|------|---------|
| `POST /push` | Pairing secret | Receive usage alert from macOS, relay via APNs |
| `GET /config` | Public | Return current limit config (multiplier, schedule) |
| `POST /config` | Admin | Update limit config |
| `POST /auth/verify` | Admin | Verify admin token, set session cookie |
| `GET /push-log` | Admin | List recent push deliveries |
| `GET /push-log/stats` | Admin | Push delivery statistics |
| `GET /status` | Public | Health check |

### Auth
- **Push route**: Validates `secret` field in payload against CloudKit pairing secret
- **Admin routes**: Bearer token + signed JWT session cookie via `admin-auth` middleware
- **Public routes**: No auth required

## Admin dashboard

- **Framework**: Next.js 15 + React 19 + Tailwind CSS 4 + SWR
- **Theme**: Dark navy (#091533) with cyan accent (#0FACED)
- **Pages**: Login, Overview (stats cards), Config (multiplier editor), Push Log, Devices
- **Deploys to**: Cloudflare Pages

## Docs architecture

- **Framework**: Next.js 15 + React 19, Turbopack in dev
- **Docs engine**: Fumadocs (fumadocs-core, fumadocs-mdx, fumadocs-ui) v14
- Content: `apps/docs/content/docs/` (MDX) + `apps/docs/content/legal/` (TOS, PP)
- Source configured via `apps/docs/source.config.ts`

## HowlAlertKit (Swift Package)

Shared library at `packages/HowlAlertKit/`. Platforms: macOS 14+, iOS 17+, watchOS 10+.

### Modules
| Module | Key Types |
|--------|-----------|
| `TokenMath` | `PaceCalculator`, `LimitMultiplier`, `ThresholdNotifier` |
| `ColorState` | `ThresholdColor`, `CritBarView`, `PaceLabel` |
| `Models` | `RemoteConfig`, `UsageSnapshot`, `PairingConfig`, `UsageEvent`, `UsageHistory` |
| `Config` | `ConfigFetcher`, `CloudKitPairing` |

### Testing
```sh
cd packages/HowlAlertKit && swift test
```

## Native architecture

- **Language**: Swift 5.9+, SwiftUI
- **Bundle ID**: `com.mrdemonwolf.howlalert`
- **CloudKit container**: `iCloud.com.mrdemonwolf.howlalert`

### macOS app (`apps/macos/`)
| File | Role |
|------|------|
| `App/HowlAlertApp.swift` | MenuBarExtra entry point + AppDelegate for APNs |
| `Views/MenuBarView.swift` | Main dashboard popover — crit bar, stats, recent events |
| `Views/PreferencesView.swift` | Settings — plan picker, thresholds, hook setup, remote config |
| `Views/RecentEventsView.swift` | Compact event list with model + tokens + timestamp |
| `Services/SessionFileWatcher.swift` | FSEvents watcher for `~/.claude/projects/**/*.jsonl` |
| `Services/JSONLParser.swift` | Claude Code JSONL line parser |
| `Services/UsageAggregator.swift` | Running token totals from parsed events |
| `Services/AlertCoordinator.swift` | Orchestrates watcher → aggregator → pace → push |
| `Services/PushService.swift` | POST /push to Worker on threshold crossing |
| `Services/RemoteConfigService.swift` | Periodic GET /config with multiplier cache |
| `Services/PairingReader.swift` | Reads CloudKit pairing + Keychain storage |
| `Services/HookHandler.swift` | Claude Code StopFailure/rate_limit detection |
| `Services/CredentialsReader.swift` | Reads `~/.claude/.credentials.json` |

### iOS app (`apps/ios/`)
| File | Role |
|------|------|
| `App/HowlAlertApp.swift` | UIApplication entry + APNs registration |
| `Views/ContentView.swift` | Root — pairing gate → dashboard or setup |
| `Views/DashboardView.swift` | Crit bar, stats cards, usage history |
| `Views/PreferencesView.swift` | Plan, thresholds, demo mode, remote config |
| `DemoMode/DemoDataGenerator.swift` | Cycles through all crit bar/pace states |
| `DemoMode/DemoModeView.swift` | Demo dashboard for App Store review |
| `Services/PairingManager.swift` | Writes PairingConfig to CloudKit |

### watchOS app (`apps/watchos/`)
| File | Role |
|------|------|
| `Views/WatchDashboardView.swift` | Crit bar, pace arrow, multiplier badge |
| `Views/WatchNotificationView.swift` | Custom push notification display |
| `Views/WatchComplicationView.swift` | Inline complication (percent + arrow) |
| `Services/WatchSessionManager.swift` | WCSession delegate for iOS companion data |

### Data flow
```
~/.claude/projects/**/*.jsonl
    → FSEvents (SessionFileWatcher)
    → JSONLParser → UsageAggregator
    → PaceCalculator + LimitMultiplier
    → ThresholdNotifier
    → PushService → POST /push → Worker → APNs
    → iOS/watchOS push notification
```

### CloudKit pairing
1. iOS registers for APNs, gets device token
2. iOS writes `PairingConfig` (secret + token + device info) to CloudKit private DB
3. macOS fetches pairing configs on launch, stores secret + token in Keychain
4. macOS includes secret + token in POST /push payload
5. Worker validates secret and forwards to APNs using the device token

### Demo mode
- Toggled from iOS PreferencesView
- `DemoDataGenerator` cycles through OK → Approaching → Limit Hit → Reset → pace states
- `DemoModeView` shows crit bar, stats cards, fake events — no network required
- Used for App Store review

### Hook integration
- Claude Code hooks: `Stop` and `StopFailure` events
- `HookHandler` parses stdin JSON, detects `error: "rate_limit"`
- Rate limit triggers immediate `forcePush` (bypasses threshold tracking)
- PreferencesView has "Copy Hook Config" button for `.claude/settings.json`

## Code style

Enforced by `.editorconfig`:
- **Tabs** for indentation (size 4) in all source files
- **Spaces** (size 2) for YAML / JSON
- LF line endings, UTF-8, trailing newline required

TypeScript is strict (`tsconfig.json` in each app). No `any` without justification.
