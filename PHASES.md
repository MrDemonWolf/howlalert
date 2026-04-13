# HowlAlert v2.0 — Build Phases

## Phase 0 · Wipe
- [x] Delete everything except LICENSE and .git/
- [x] Commit: `chore: wipe repository for v2.0 rebuild`

## Phase 1 · Monorepo Scaffold
- [x] Scaffold Better-T-Stack (Hono + Workers + D1 + Drizzle + Turborepo + Fumadocs)
- [x] `bun install` succeeds
- [x] Create `apps/macos/`, `apps/ios/`, `apps/watchos/`, `packages/HowlAlertKit/`
- [x] Root tooling: Makefile, CLAUDE.md, PHASES.md, README.md, .editorconfig
- [x] Commit: `feat: scaffold Better-T-Stack monorepo`

## Phase 2 · HowlAlertKit Swift Package
- [x] `Package.swift` with targets: Models, TokenMath, ColorState, PaceEngine, Providers, Config, DemoMode
- [x] Models: UsageSnapshot, PaceState, PairingConfig, EntitlementState
- [x] Provider protocol + ClaudeCodeProvider + GeminiCLIProvider (stub)
- [x] PaceCalculator — debt/on-track/reserve logic
- [x] SnapshotAggregator — merge multi-Mac snapshots
- [x] ThresholdColor + ThresholdNotifier (60/85/100% + 30-min cooldown)
- [x] DemoDataGenerator — 60s cycle
- [x] HowlAlertConstants + EntitlementManager
- [x] 8+ PaceCalculator tests, 4 ThresholdColor tests, 2 provider tests
- [x] `swift build && swift test` passes (15/15)
- [x] Commit: `feat: HowlAlertKit with Provider protocol, pace engine, demo mode`

## Phase 3 · Cloudflare Worker
- [x] Install `@fivesheepco/cloudflare-apns2`
- [x] Hono routes: /health, POST /register, POST /push, POST /entitlement/sync
- [x] Drizzle D1 schema: users + push_log tables
- [x] KV namespaces: HOWLALERT_DEVICES, HOWLALERT_PUSH_LOG
- [x] Zod validation on all routes
- [x] Push throttling: 1 push/user/30min/kind
- [x] /admin/usage endpoint
- [x] 5 Vitest tests pass
- [x] `wrangler deploy --dry-run` succeeds (129KB gzip)
- [x] Commit: `feat: Hono worker with APNs relay and entitlement check`

## Phase 4 · Fumadocs Site → GitHub Pages
- [x] Static export config with basePath /howlalert
- [x] Landing page: hero, download buttons, features, pricing, FAQ
- [x] Legal pages: privacy, terms, subscription-terms
- [x] Docs MDX: getting-started, faq, how-it-works, multi-mac-setup, troubleshooting
- [x] .github/workflows/deploy-docs.yml
- [x] Local build produces valid out/ (12 pages)
- [x] Commit: `feat: landing page, legal docs, and GH Pages deploy`

## Phase 5 · Xcode Projects
- [x] iOS .xcodeproj with push, CloudKit, App Groups, RevenueCat SDK
- [x] watchOS target inside iOS project
- [x] macOS .xcodeproj with LSUIElement, Hardened Runtime, Sparkle 2
- [x] All link HowlAlertKit via SPM (XcodeGen)
- [x] Commit: `feat: Xcode projects for macOS, iOS, watchOS`

## Phase 6 · CloudKit Pairing + Entitlement + Multi-Mac Sync
- [x] CloudKitSyncManager in HowlAlertKit
- [x] Record types: DevicePairing, Entitlement, UsageSnapshot
- [x] Each Mac writes own UsageSnapshot (throttled 1/10s via SnapshotThrottler)
- [x] iOS aggregates via SnapshotAggregator
- [x] macOS queries Entitlement on launch + 6h + wake
- [x] CKDatabaseSubscription on all record types
- [x] Keychain 7-day grace cache
- [x] Stale Mac detection (>30min = idle)
- [x] Commit: `feat: CloudKit sync with multi-Mac usage aggregation`

## Phase 7 · macOS JSONL Watcher + Menu Bar
- [x] JSONLWatcher with FSEvents + UsageProvider array
- [x] Parse output_tokens, cache_read_input_tokens, cache_creation_input_tokens
- [x] Aggregate into UsageSnapshot per 5h window
- [x] Entitlement check on launch → paywall state
- [x] MenuBarView: icon only, tinted by pace state
- [x] Popover: session/pace cards + last updated
- [x] PreferencesView: launch at login, push toggle, done alerts, providers
- [x] CritBarView with smooth color transitions
- [x] Demo Mode toggle
- [x] Commit: `feat: minimal wolf menu bar, launch-at-login, bare-bones preferences`

## Phase 8 · Push Pipeline
- [x] PushClient actor sends payloads to Worker
- [x] 30-min cooldown per threshold (server-side KV)
- [x] "Done" events fire per-Mac
- [x] Mac-attributed notifications
- [x] Commit: `feat: push pipeline with multi-Mac aggregation and attribution`

## Phase 9 · iOS Dashboard + Dynamic Island
- [x] DashboardView: stacked cards
- [x] CloudKit fetch → SnapshotAggregator → UI
- [x] Active Macs card (hidden when 1 Mac)
- [x] Settings → Devices (list + remove)
- [x] Live Activity / Dynamic Island
- [x] Empty state: "Waiting for Mac..." + "Try Demo Mode"
- [x] Commit: `feat: iOS dashboard with multi-Mac aggregation and Dynamic Island`

## Phase 10 · watchOS
- [x] Circular progress ring + pace text
- [x] WidgetKit circular complication
- [x] WCSession message handling
- [x] "Done" haptic (.notification)
- [x] Commit: `feat: watchOS app and circular complication`

## Phase 11 · RevenueCat Paywall
- [x] Products: monthly $3.99, annual $35.99, 7-day trial
- [x] PaywallView with trial badge + toggle + restore
- [x] On purchase → write Entitlement to CloudKit
- [x] Worker validates D1 entitlement on /push
- [x] Commit: `feat: RevenueCat paywall with cross-device CloudKit entitlement sync`

## Phase 12 · Demo Mode + Compliance
- [x] iOS: empty state button + Settings toggle + deep link
- [x] macOS: Demo Mode toggle in AppState
- [x] App Review Notes
- [x] PrivacyInfo.xcprivacy on iOS + macOS
- [x] Commit: `feat: Demo Mode on all three platforms + App Review compliance`

## Phase 13 · CI/CD
- [x] .github/workflows/release.yml (build, notarize, DMG, Sparkle, GitHub Release)
- [x] Homebrew cask template (HOMEBREW_CASK.rb)
- [x] ExportOptions.plist for Developer ID
- [x] Document required secrets (8 total)
- [x] Commit: `feat: full CI/CD for macOS releases + homebrew-den tap auto-update`

## Phase 14 · Marketing Jira Specs
- [x] Generate MARKETING_JIRA.md with all 14 ticket YAML blocks
- [x] Commit: `docs: self-contained marketing jira ticket specs for packrunner`

## Phase 15 · Post-Launch Polish
- [x] StoreKit configuration file (monthly + annual + trials)
- [x] Universal Links + apple-app-site-association
- [x] URL scheme registration (howlalert://)
- [x] MANUAL_STEPS.md with complete portal checklist
- [x] Commit: `feat: launch polish - sparkle, storekit, universal links, accessibility`
