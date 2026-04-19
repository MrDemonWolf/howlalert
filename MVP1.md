# MVP 1 — Ship to App Store

> **Goal:** macOS menu bar + iPhone + Apple Watch apps live. Claude Code only. Paid via RevenueCat.
> **Target:** ~2 weeks from Phase 0 start.
> **Companion:** `PLAN.md` (architecture), `TODO.md` (Nathanial's manual tasks).

<p align="center">
  <img src="./assets/logo.svg" alt="HowlAlert" width="120" />
</p>

---

## Rules (from `CLAUDE.md`)

1. Work phases in order. Don't skip.
2. At the end of each phase: commit AND push to `main`.
3. Tick checkboxes in this file as you complete them. Commit the update with the phase's code.
4. Use conventional commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`).
5. Before coding, run the session startup ritual in `CLAUDE.md` (includes CodexBar pull).
6. Don't implement Gemini. That's MVP 2.

---

## Prerequisites (Nathanial — must be done first)

See `TODO.md` Block 1. Phase 0 will not work without:

- Apple Dev App IDs + APNs key + certs
- App Store Connect products (`howlalert_pro_monthly`, `howlalert_pro_yearly`)
- RevenueCat project + webhook
- Cloudflare: D1 database, KV namespaces
- GitHub Actions secrets

---

# Phase 0 — Repo wipe + scaffold

**Goal:** clean slate monorepo, everything compiles empty.

### Tasks

- [x] Clone CodexBar to `/Users/nathanialhenniges/Developer/tmp/CodexBar` (or `git pull` if exists)
- [x] Wipe repo, preserving only: `LICENSE`, `.git/`, `CLAUDE.md`, `PLAN.md`, `MVP1.md`, `MVP2.md`, `TODO.md`, `README.md`, `assets/`
- [x] Initialize Better-T-Stack monorepo with Bun + Turbo:
  - [x] `package.json` with Bun workspaces pointing at `apps/*` and `packages/*`
  - [x] `turbo.json` with `dev`, `build`, `lint`, `typecheck`, `test` tasks
  - [x] `.gitignore` covering Node, Swift, Xcode, macOS
  - [x] `Makefile` with Swift task shortcuts + Bun delegation
  - [x] `tsconfig.base.json` in `packages/config/`
- [x] Scaffold `apps/worker/` — Hono app, basic `/health` endpoint, `wrangler.toml`
- [x] Scaffold `apps/admin/` — Next.js App Router (placeholder "coming in v2" page)
- [x] Create empty Xcode workspace `HowlAlert.xcworkspace` containing:
  - [x] `apps/macos/HowlAlert.xcodeproj` — SwiftUI menu bar app target, `LSUIElement = true`
  - [x] `apps/ios/HowlAlert.xcodeproj` — SwiftUI iOS app target
  - [x] `apps/watchos/HowlAlertWatch.xcodeproj` — SwiftUI watchOS companion target
  - [x] `packages/howlalert-kit/Package.swift` — Swift Package with one public `Greeter` placeholder
- [x] Scaffold `packages/shared-types/` — one TS file exporting `UsageSnapshot` interface
- [x] Scaffold `docs/` folder with `index.md` (GitHub Pages will serve this)
- [ ] Enable GitHub Pages in repo Settings: source = `/docs` on `main` *(Nathanial — manual)*
- [x] Add GitHub Actions workflows (all green on push):
  - [x] `.github/workflows/ci-swift.yml` — builds + lints Swift packages
  - [x] `.github/workflows/ci-bun.yml` — typecheck + lint for Worker and shared packages
- [x] Verify: `bun install` clean, `bun dev` starts Worker
- [x] Verify: Xcode workspace opens all 3 targets, all build empty
- [x] Commit: `chore: wipe and scaffold v3 monorepo`
- [x] Push to `main`

### Done when

- CI green on `main`
- Can open Xcode workspace and see 3 empty app targets + `howlalert-kit` Swift Package
- `bun dev` starts Worker on `localhost:8787`
- `mrdemonwolf.github.io/howlalert` renders the placeholder index

---

# Phase 1 — Cloudflare Worker (APNs relay + RevenueCat webhook)

**Goal:** stateless push relay deployed at `howlalert.mrdemonwolf.workers.dev`.

### Tasks

- [ ] In `apps/worker/`, build Hono app with routes:
  - [ ] `GET /health` → `{ status: "ok", version }`
  - [ ] `POST /push` → validates payload, signs APNs JWT, forwards to Apple
  - [ ] `POST /webhooks/revenuecat` → validates signature, upserts entitlement to D1
- [ ] APNs client using `jose` for ES256 JWT signing
- [ ] D1 schema + migration:
  ```sql
  CREATE TABLE entitlements (
    cloudkit_user_id TEXT PRIMARY KEY,
    active INTEGER NOT NULL,
    expires_at INTEGER NOT NULL,
    product_id TEXT,
    updated_at INTEGER NOT NULL
  );
  ```
- [ ] KV bindings in `wrangler.toml`: `HOWLALERT_CONFIG`, `HOWLALERT_DEVICE_TOKENS`, `HOWLALERT_PUSH_LOG`
- [ ] Secrets via `wrangler secret put`: `APNS_KEY_P8`, `APNS_KEY_ID`, `APNS_TEAM_ID`, `APNS_BUNDLE_ID`, `REVENUECAT_WEBHOOK_SECRET`
- [ ] Deploy: `wrangler deploy` → live at `howlalert.mrdemonwolf.workers.dev`
- [ ] Paste webhook URL into RevenueCat dashboard
- [ ] `curl https://howlalert.mrdemonwolf.workers.dev/health` returns 200
- [ ] Unit tests for JWT signing + payload validation
- [ ] Commit: `feat(worker): stateless APNs relay + revenuecat webhook`
- [ ] Push to `main`

### Done when

- Health endpoint live at `howlalert.mrdemonwolf.workers.dev/health`
- D1 entitlements table exists
- RevenueCat sandbox webhook hits Worker successfully
- Test APNs push (using a dev device token) delivers to a real iPhone

---

# Phase 2 — `howlalert-kit` shared Swift package

**Goal:** pure-logic core all three apps import. Tested.

### Tasks

- [ ] Data models in `Sources/HowlAlertKit/Models/`:
  - [ ] `UsageSnapshot` (timestamp, per-model totals, window bounds, source device)
  - [ ] `TokenTotals` (per-model dictionary, combined total)
  - [ ] `ModelIdentifier` (enum incl. `opus4_7`, `opus4_6`, `sonnet4_6`, `haiku4_5`, `unknown`)
  - [ ] `EffortLevel` (enum: `min`, `low`, `medium`, `high`, `xhigh`, `max`)
  - [ ] `PaceState` (`.onTrack`, `.debt(Double, duration)`, `.reserve(Double)`)
  - [ ] `WindowKind` (`.session` / `.weekly`)
- [ ] `UsageProvider` protocol per `PLAN.md` §4
- [ ] `ClaudeCodeProvider` implementation:
  - [ ] JSONL streaming parser for `~/.claude/projects/**/*.jsonl`
  - [ ] Parses `message.usage.*` fields (be aware: `input_tokens` can be under-reported — rely on `cache_read_input_tokens` + `cache_creation_input_tokens` as primaries per CodexBar findings)
  - [ ] Reads `~/.claude/.credentials.json` for subscription tier
  - [ ] Reads `~/.claude.json` for usage state
  - [ ] Detects `Stop` hook event signatures
  - [ ] Parses weekly limit wording: match both `"Current week (Sonnet only)"` and `"Opus"` (legacy fallback)
- [ ] `GeminiCLIProvider` stub — compiles, `refresh()` throws `ProviderError.notImplemented`
- [ ] `PaceCalculator`:
  - [ ] Model-aware: keeps per-model totals, doesn't collapse until reporting
  - [ ] Window math: 5-hour session window + weekly window tracked separately
  - [ ] Returns `PaceState` for each window
  - [ ] Hides pace output when <3% of window elapsed (not enough data)
- [ ] `ColorState` threshold → crit bar color mapping:
  - [ ] OK (`#0FACED`) 0–60%
  - [ ] Approaching (`#F5A623`) 60–85%
  - [ ] Limit Hit (`#FF3B30`) ≥85%
  - [ ] Reset (`#34C759`) fresh window
- [ ] Unit tests against real Claude Code JSONL fixtures in `Tests/Fixtures/`:
  - [ ] Opus 4.7 session with xhigh effort
  - [ ] Opus 4.6 session with high effort
  - [ ] Mixed-model session
  - [ ] Rate-limited session (StopFailure event)
  - [ ] Empty/fresh window
- [ ] `swift test` passes
- [ ] Commit: `feat(kit): provider protocol + model-aware pace math + Opus 4.7 support`
- [ ] Push to `main`

### Done when

- `swift test` green on both macOS and Linux
- `ClaudeCodeProvider` correctly parses a real `~/.claude/` snapshot from Nathanial's machine
- Pace math returns expected results for all 5 fixture files

---

# Phase 3 — macOS menu bar watcher

**Goal:** Mac menu bar icon shows live usage. No push yet.

### Tasks

- [ ] `MenuBarExtra` app with wolf icon (render `assets/logo.svg` into appropriate `.iconset` PNGs)
- [ ] Icon states:
  - [ ] Grayscale when no entitlement or not paired
  - [ ] Full color (cyan/navy) when active
  - [ ] Two-bar meter icon: top bar = session window, bottom bar = weekly window (inspired by CodexBar)
- [ ] `LSUIElement = true` in Info.plist (no Dock icon)
- [ ] FSEvents watcher on `~/.claude/**/*.jsonl` and `~/.claude/.credentials.json`
- [ ] JSONL streaming tail parser feeds `ClaudeCodeProvider.refresh()`
- [ ] Popover UI:
  - [ ] Crit bar (horizontal, brand colors)
  - [ ] Pace label ("87% used · runs out in ~2h")
  - [ ] Per-model breakdown line (`Opus 4.7 · xhigh · 42%`) — collapsible
  - [ ] Window toggle: Session / Weekly
- [ ] Settings pane (minimal — bare minimum only):
  - [ ] Start at Login toggle (SMAppService)
  - [ ] Provider toggles (Claude Code enabled, Gemini CLI disabled + "Coming in v2" label)
  - [ ] "Track effort level" toggle (default on)
  - [ ] About section
- [ ] Claude Code `Stop` hook auto-installed on first run (edits `~/.claude/settings.json`)
- [ ] Sparkle integration (feed URL placeholder, populated in Phase 9)
- [ ] Menu icon updates within 2s of a real Claude Code turn
- [ ] Commit: `feat(macos): menu bar watcher + popover UI`
- [ ] Push to `main`

### Done when

- Run a Claude Code session → menu icon + popover update live
- Settings changes persist across relaunch
- Start at Login works from a fresh install

---

# Phase 4 — iOS app + CloudKit pairing

**Goal:** Install iOS app, open Mac app, they auto-pair.

### Tasks

- [ ] iOS app scaffold in `apps/ios/`:
  - [ ] Dashboard tab (crit bar, pace, recent events)
  - [ ] Settings tab (minimal)
  - [ ] Empty state pre-pairing: "Install HowlAlert on your Mac, or try Demo Mode"
  - [ ] Paywall screen (placeholder, fleshed out in Phase 7)
- [ ] CloudKit container configured: `iCloud.com.mrdemonwolf.howlalert`
- [ ] Record types:
  - [ ] `PairingConfig` — per-iCloud-user, contains pairing secret + device tokens
  - [ ] `UsageEvent` — historical push events
  - [ ] `Entitlement` — subscription state (written in Phase 7)
  - [ ] `UsageSnapshot` — per-Mac latest state
- [ ] iPhone writes `PairingConfig` on first launch
- [ ] Mac reads `PairingConfig` on first launch → pairing success with zero user input
- [ ] APNs registration → device token stored in CloudKit
- [ ] Multi-Mac handling: each Mac writes its own `UsageSnapshot`, iOS aggregates
- [ ] **Demo Mode** — fully functional from empty state, zero CloudKit dependency:
  - [ ] Fixture plist with a realistic week of usage data bundled in app
  - [ ] Toggle in empty state AND in Settings
  - [ ] Clearly labeled as Demo
- [ ] Commit: `feat(ios): cloudkit pairing + dashboard + demo mode`
- [ ] Push to `main`

### Done when

- Install iOS app → open Mac app → pairing works with no prompts
- Dashboard shows real Mac data after pairing
- Demo Mode works before pairing

---

# Phase 5 — Push pipeline end-to-end

**Goal:** JSONL write on Mac → banner on iPhone within 5s.

### Tasks

- [ ] Mac fires pushes on:
  - [ ] 60% threshold (session window)
  - [ ] 85% threshold
  - [ ] 100% threshold
  - [ ] Claude-done event (on `Stop` hook fire)
  - [ ] Weekly window reset
- [ ] Per-threshold cooldown: 30 minutes (prevent spam)
- [ ] POST to Worker `/push` with:
  ```json
  {
    "cloudkitUserId": "...",
    "deviceToken": "...",
    "deviceName": "MacBook Pro",
    "kind": "threshold" | "done" | "reset",
    "payload": { "usage", "pace", "windowEnd" }
  }
  ```
- [ ] Worker signs APNs JWT, forwards to Apple
- [ ] iPhone banner arrives within 5s of JSONL write
- [ ] Notification text:
  - [ ] Single-Mac: `🐺 85% used · ~2h left`
  - [ ] Multi-Mac: `🐺 {MacName} · 85% used · ~2h left`
- [ ] iOS receives push → writes `UsageEvent` to CloudKit → Dashboard updates
- [ ] Watch receives forwarded event via WatchConnectivity (Phase 6 wires this up fully)
- [ ] E2E test: real Claude Code turn triggers real push on physical iPhone
- [ ] Commit: `feat: end-to-end push pipeline with multi-mac attribution`
- [ ] Push to `main`

### Done when

- Physical test on a real iPhone + real Mac running Claude Code delivers a banner within 5s
- Multi-Mac test: push from two Macs show correct attribution
- Cooldown prevents duplicate 85% pushes within 30 min

---

# Phase 6 — watchOS companion

**Goal:** glanceable pace on the wrist.

### Tasks

- [ ] Complication families:
  - [ ] `accessoryCircular` (ring showing session percent)
  - [ ] `accessoryRectangular` (crit bar + "85% · 2h left")
  - [ ] `accessoryCorner` (ring + percent)
- [ ] Notification view: crit bar + pace text + Mac name
- [ ] WatchConnectivity sync with iPhone (reactive to new `UsageEvent` records)
- [ ] Demo Mode reachable from Watch Settings (reuses iOS fixture data)
- [ ] No independent push — iPhone forwards via WatchConnectivity
- [ ] Commit: `feat(watchos): complications + notification view`
- [ ] Push to `main`

### Done when

- Complications update on Watch face within 30s of a Mac event
- Tapping notification on watch shows crit bar view

---

# Phase 7 — RevenueCat + entitlement sync

**Goal:** iOS subscription unlocks Mac via iCloud.

### Tasks

- [ ] RevenueCat SDK integrated in iOS app (`RevenueCat` Swift Package)
- [ ] Paywall screen (SwiftUI, brand colors, matches design brief):
  - [ ] Monthly $3.99 / Yearly $35.99 options
  - [ ] 7-day free trial callout
  - [ ] Restore Purchases button
  - [ ] Privacy + ToS links
- [ ] On purchase: iOS writes `Entitlement` record to CloudKit private DB:
  ```
  { entitlementActive: Bool, expiresAt: Date, productID: String, updatedAt: Date }
  ```
- [ ] Mac queries CloudKit on: launch, wake, every 6h via background task
- [ ] Mac unlocks full UI when entitlement active
- [ ] Mac paywall state when not active:
  - [ ] Wolf icon grayscale
  - [ ] Popover shows "🐺 HowlAlert Pro required — subscribe on your iPhone"
  - [ ] Deep link button → `howlalert://` URL scheme (or App Store link)
  - [ ] Still shows raw JSONL being watched + token count (read-only teaser)
- [ ] Worker validates entitlement via D1 on every `/push` (anti-abuse)
- [ ] 7-day offline grace period cached in Keychain
- [ ] Manual test matrix:
  - [ ] New user → trial → paid → cancel → grace → locked
  - [ ] Restore on reinstall
  - [ ] Multi-device (same iCloud account)
- [ ] Commit: `feat: revenuecat + cloudkit entitlement sync`
- [ ] Push to `main`

### Done when

- Sandbox purchase in iOS → Mac unlocks within 30s
- Canceling in Settings → Mac re-locks after grace period
- Worker rejects `/push` from users without active entitlement

---

# Phase 8 — Demo Mode hardening + App Review prep

**Goal:** Apple reviewer can experience the product without a Mac running Claude Code.

### Tasks

- [ ] Fixture plist: realistic week of usage data bundled in app (multiple models, varying pace)
- [ ] Demo Mode entry in empty state (pre-pairing) + buried in Settings (post-pairing)
- [ ] Demo Mode clearly labeled everywhere as "Demo" (Apple doesn't like invisible demo data)
- [ ] Watch also has Demo Mode accessible from Watch Settings
- [ ] `App Review Notes.md` — verbatim Demo Mode instructions for reviewer:
  - [ ] Step-by-step "On the empty state, tap 'Try Demo Mode'"
  - [ ] Include subscription sandbox credentials if needed
  - [ ] Note that macOS app is not part of this submission
- [ ] Privacy manifest `PrivacyInfo.xcprivacy` for all 3 targets:
  - [ ] Reasons for required API usage (UserDefaults, Keychain, File Timestamp)
  - [ ] Data collection: none
  - [ ] Tracking: none
- [ ] Privacy Policy at `https://mrdemonwolf.com/howlalert/privacy` — returns 200
- [ ] Terms of Service at `https://mrdemonwolf.com/howlalert/terms` — returns 200
- [ ] Subscription disclosure text matches Apple's exact required wording
- [ ] All in-app copy reviewed for App Store compliance
- [ ] Skill check: run `app-store-review-audit` skill on iOS + watchOS
- [ ] Commit: `chore: app review prep + privacy manifests + demo mode hardening`
- [ ] Push to `main`

### Done when

- `app-store-review-audit` skill returns zero blocking issues
- Privacy + ToS URLs live
- Demo Mode walkthrough matches App Review Notes exactly

---

# Phase 9 — Notarized DMG + Homebrew cask

**Goal:** macOS distribution pipeline automated.

### Tasks

- [ ] `.github/workflows/macos-release.yml`:
  1. [ ] Trigger: `release` published event
  2. [ ] Build: `xcodebuild archive` with release config
  3. [ ] Notarize: `notarytool submit` + wait
  4. [ ] Staple: `stapler staple`
  5. [ ] Pack DMG: `create-dmg` with branded background, drag-to-Applications layout, Finder window settings
  6. [ ] Upload DMG to the GitHub Release
  7. [ ] Repository dispatch → `mrdemonwolf/homebrew-den` with version + SHA256 payload
- [ ] Cask formula template `Casks/howlalert.rb` in `mrdemonwolf/homebrew-den` (copy the wolfwave pattern):
  ```ruby
  cask "howlalert" do
    version "VERSION_PLACEHOLDER"
    sha256 "SHA256_PLACEHOLDER"
    url "https://github.com/mrdemonwolf/howlalert/releases/download/v#{version}/HowlAlert-#{version}.dmg"
    name "HowlAlert"
    desc "Claude Code usage monitor for Apple ecosystem"
    homepage "https://howlalert.app"
    app "HowlAlert.app"
    zap trash: [
      "~/Library/Application Support/com.mrdemonwolf.howlalert.mac",
      "~/Library/Preferences/com.mrdemonwolf.howlalert.mac.plist",
    ]
  end
  ```
- [ ] Auto-PR workflow in `homebrew-den` that accepts the dispatch, templates the cask, opens PR
- [ ] Sparkle appcast feed live at `mrdemonwolf.github.io/howlalert/appcast.xml`
- [ ] Update Mac app's `SUFeedURL` Info.plist entry
- [ ] Test run:
  - [ ] Tag `v0.1.0-test` → full pipeline runs green
  - [ ] Homebrew PR opens in `homebrew-den` automatically
  - [ ] Merge PR, then `brew install --cask mrdemonwolf/den/howlalert` installs the test build
  - [ ] Sparkle update check works
  - [ ] Delete test release after verification
- [ ] Commit: `ci: notarize + dmg + homebrew auto-pr + sparkle`
- [ ] Push to `main`

### Done when

- One `git tag` + GitHub release publish triggers the full pipeline green
- Homebrew cask installs cleanly
- Sparkle update from v0.1.0-test to a hypothetical v0.1.1 works

---

# Phase 10 — TestFlight + App Store submission

**Goal:** green submit button → publish.

### Tasks

- [ ] iOS + watchOS archive uploaded to App Store Connect (Xcode Organizer)
- [ ] Internal TestFlight build processed + available
- [ ] Invite 5–10 testers (friends, designer, yourself on multiple devices)
- [ ] Fix all blocking bugs reported during TestFlight week
- [ ] App Store screenshots (shoot from real builds):
  - [ ] iPhone 6.7" (required)
  - [ ] iPhone 6.1"
  - [ ] Apple Watch Series 10
- [ ] App description, keywords, subtitle, promo text
- [ ] App Review Notes pasted into submission form (from Phase 8)
- [ ] Demo Mode highlighted for reviewer
- [ ] Submit to App Review (iOS + watchOS bundle as one submission)
- [ ] While waiting: publish macOS `v1.0.0` GitHub release:
  - [ ] Homebrew cask auto-PR opens → merge
  - [ ] Sparkle appcast updated
  - [ ] Test fresh install via `brew install --cask mrdemonwolf/den/howlalert`
- [ ] Landing page live at `howlalert.app`
- [ ] Docs complete at `mrdemonwolf.github.io/howlalert` (install guide, pairing guide, FAQ)
- [ ] Commit: `chore: v1.0.0`
- [ ] Push to `main`
- [ ] Tag `v1.0.0`

### Done when

- iOS + watchOS approved and Ready for Sale
- macOS v1.0.0 installable via Homebrew
- First paying customer recorded in RevenueCat dashboard 🎉

---

## Post-MVP 1 cooldown

After shipping: wait **14 days** and watch MetricKit + RevenueCat before starting MVP 2.

- [ ] MetricKit reports zero crashes for 14 days
- [ ] Zero P1 bugs in reported issues
- [ ] Nathanial makes the "go MVP 2" call

Then → `MVP2.md`.
