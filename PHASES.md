# HowlAlert v2.0 — Build Phases

## Phase 0 · Wipe
- [x] Delete everything except LICENSE and .git/
- [x] Commit: `chore: wipe repository for v2.0 rebuild`

## Phase 1 · Monorepo Scaffold
- [x] Scaffold Better-T-Stack (Hono + Workers + D1 + Drizzle + Turborepo + Fumadocs)
- [ ] `bun install` succeeds
- [ ] Create `apps/macos/`, `apps/ios/`, `apps/watchos/`, `packages/HowlAlertKit/`
- [ ] Root tooling: Makefile, CLAUDE.md, PHASES.md, README.md, .editorconfig
- [ ] Commit: `feat: scaffold Better-T-Stack monorepo`

## Phase 2 · HowlAlertKit Swift Package
- [ ] `Package.swift` with targets: Models, TokenMath, ColorState, PaceEngine, Providers, Config, DemoMode
- [ ] Models: UsageSnapshot, PaceState, PairingConfig, EntitlementState
- [ ] Provider protocol + ClaudeCodeProvider + GeminiCLIProvider (stub)
- [ ] PaceCalculator — debt/on-track/reserve logic
- [ ] SnapshotAggregator — merge multi-Mac snapshots
- [ ] ThresholdColor + ThresholdNotifier (60/85/100% + 30-min cooldown)
- [ ] DemoDataGenerator — 60s cycle
- [ ] HowlAlertConstants + EntitlementManager
- [ ] 8+ PaceCalculator tests, 4 ThresholdColor tests, 2 provider tests
- [ ] `swift build && swift test` passes
- [ ] Commit: `feat: HowlAlertKit with Provider protocol, pace engine, demo mode`

## Phase 3 · Cloudflare Worker
- [ ] Install `@fivesheepco/cloudflare-apns2`
- [ ] Hono routes: /health, POST /register, POST /push, POST /entitlement/sync
- [ ] Drizzle D1 schema: users table
- [ ] KV namespaces: HOWLALERT_DEVICES, HOWLALERT_PUSH_LOG
- [ ] Zod validation on all routes
- [ ] Push throttling: 1 push/user/30min/kind
- [ ] /admin/usage endpoint
- [ ] 3+ Vitest tests
- [ ] `wrangler deploy --dry-run` succeeds
- [ ] Commit: `feat: Hono worker with APNs relay and entitlement check`

## Phase 4 · Fumadocs Site → GitHub Pages
- [ ] Static export config with basePath /howlalert
- [ ] Landing page: hero, download buttons, features, pricing, FAQ
- [ ] Legal pages: privacy, terms, subscription-terms
- [ ] Docs MDX: getting-started, faq, how-it-works, multi-mac-setup, troubleshooting
- [ ] .github/workflows/deploy-docs.yml
- [ ] Local build produces valid out/
- [ ] Commit: `feat: landing page, legal docs, and GH Pages deploy`

## Phase 5 · Xcode Projects
- [ ] iOS .xcodeproj with push, CloudKit, App Groups, RevenueCat SDK
- [ ] watchOS target inside iOS project
- [ ] macOS .xcodeproj with LSUIElement, Hardened Runtime, Sparkle 2
- [ ] All link HowlAlertKit via SPM
- [ ] Commit: `feat: Xcode projects for macOS, iOS, watchOS`

## Phase 6 · CloudKit Pairing + Entitlement + Multi-Mac Sync
- [ ] CloudKitSyncManager in HowlAlertKit
- [ ] Record types: DevicePairing, Entitlement, UsageSnapshot
- [ ] Each Mac writes own UsageSnapshot (throttled 1/10s)
- [ ] iOS aggregates via SnapshotAggregator
- [ ] macOS queries Entitlement on launch + 6h + wake
- [ ] CKDatabaseSubscription on all record types
- [ ] Keychain 7-day grace cache
- [ ] Stale Mac detection (>30min = idle)
- [ ] Commit: `feat: CloudKit sync with multi-Mac usage aggregation`

## Phase 7 · macOS JSONL Watcher + Menu Bar
- [ ] JSONLWatcher with FSEvents + UsageProvider array
- [ ] Parse output_tokens, cache_read_input_tokens, cache_creation_input_tokens
- [ ] Aggregate into UsageSnapshot per 5h window
- [ ] Entitlement check on launch → paywall state
- [ ] MenuBarView: icon only 16x16, tinted by pace state
- [ ] Popover: session/weekly/pace cards
- [ ] PreferencesView: launch at login, push toggle, done alerts, providers
- [ ] CritBarView with smooth color transitions
- [ ] Stop-hook detection → "done" event
- [ ] Demo Mode via right-click
- [ ] Commit: `feat: minimal wolf menu bar, launch-at-login, bare-bones preferences`

## Phase 8 · Push Pipeline
- [ ] Threshold evaluation against aggregated multi-Mac usage
- [ ] 30-min cooldown per threshold (server-side KV)
- [ ] "Done" events fire per-Mac
- [ ] Mac-attributed notifications
- [ ] Commit: `feat: push pipeline with multi-Mac aggregation and attribution`

## Phase 9 · iOS Dashboard + Dynamic Island
- [ ] DashboardView: stacked cards
- [ ] CloudKit subscription → SnapshotAggregator → UI
- [ ] Active Macs card (hidden when 1 Mac)
- [ ] Settings → Devices (list + remove)
- [ ] WatchConnectivity forwarding
- [ ] Live Activity / Dynamic Island
- [ ] Empty state: "Waiting for Mac..."
- [ ] Commit: `feat: iOS dashboard with multi-Mac aggregation and Dynamic Island`

## Phase 10 · watchOS
- [ ] Compact crit bar + pace text
- [ ] WidgetKit circular complication
- [ ] WCSession message handling
- [ ] "Done" haptic
- [ ] Commit: `feat: watchOS app and circular complication`

## Phase 11 · RevenueCat Paywall
- [ ] Products: monthly $3.99, annual $35.99, 7-day trial
- [ ] CloudKit user ID as RevenueCat appUserID
- [ ] PaywallView with trial badge + toggle + restore
- [ ] On purchase → write Entitlement to CloudKit
- [ ] Worker validates D1 entitlement on /push
- [ ] Commit: `feat: RevenueCat paywall with cross-device CloudKit entitlement sync`

## Phase 12 · Demo Mode + Compliance
- [ ] iOS: empty state button + Settings toggle + deep link
- [ ] watchOS: auto-activate + standalone toggle
- [ ] macOS: right-click menu bar toggle
- [ ] App Review Notes
- [ ] PrivacyInfo.xcprivacy on all platforms
- [ ] Commit: `feat: Demo Mode on all three platforms + App Review compliance`

## Phase 13 · CI/CD
- [ ] .github/workflows/release.yml (build, notarize, DMG, Sparkle, GitHub Release)
- [ ] Homebrew tap workflow in mrdemonwolf/homebrew-den
- [ ] Initial Casks/howlalert.rb
- [ ] Document required secrets
- [ ] Commit: `feat: full CI/CD for macOS releases + homebrew-den tap auto-update`

## Phase 14 · Marketing Jira Specs
- [ ] Generate MARKETING_JIRA.md with all ticket YAML blocks
- [ ] Commit: `docs: self-contained marketing jira ticket specs for packrunner`

## Phase 15 · Post-Launch Polish
- [ ] Sparkle EdDSA key docs
- [ ] StoreKit configuration file
- [ ] Universal Links + apple-app-site-association
- [ ] URL scheme registration
- [ ] Accessibility sweep
- [ ] MetricKit crash reporting
- [ ] Commit: `feat: launch polish - sparkle, storekit, universal links, accessibility`
