# PHASES.md — HowlAlert Build Plan

> Five testable phases. Work one at a time. Tick checkboxes in the same commit as the phase's code. After each phase, push to `main` and tell Nathanial **exactly what to test**.

---

## Phase 0 — macOS menu bar, local-only

**Goal:** a working, local-only menu bar app that can be handed to 5 friends.
**Jira:** HAA-15 → HAA-22.
**Design reference:** Section B of [`docs/design/HowlAlert.html`](docs/design/HowlAlert.html). Match the menu-bar icon states, popover layout, Settings window, and Demo / error states pixel-for-pixel.

### Tasks

- [ ] Xcode project scaffold for `apps/macos/` (verify existing scaffold, fill gaps).
- [ ] Wire `HowlAlertKit.Theme` (`HowlColor`, `HowlSpacing`, `HowlRadius`, `HowlTypography`, `HowlMotion`) into the macOS app. No hard-coded hex.
- [ ] Build menu-bar popover per Section B — `TwoBarMeter`, `PaceChip`, `ResetCountdown`, model rows. Liquid Glass nav surfaces only.
- [ ] `MenuBarExtra` with three icon states (idle / warn / crit).
- [ ] FSEvents watcher on `~/.claude/projects/**/*.jsonl`.
- [ ] Stop hook handler binary (reads JSON from stdin, exits 0 in <5s).
- [ ] 5-hour window math: floor first timestamp to UTC hour, add 5h.
- [ ] P90 plan-limit auto-detect (no hard-coded values).
- [ ] Local `UNUserNotificationCenter` notifications at 80% / 95% / reset.
- [ ] Popover UI: `TwoBarMeter` + `PaceChip` + `ResetCountdown` + model rows.
- [ ] Demo Mode toggle in Settings.
- [ ] Sparkle 2.x integration with EdDSA keys.
- [ ] Notarized DMG via `appdmg` + GitHub Actions release workflow.
- [ ] Homebrew tap at `mrdemonwolf/homebrew-den`.

### You can now test

1. Open `HowlAlert.xcworkspace`, build + run the macOS scheme. Menu-bar icon appears (no Dock icon).
2. Toggle Demo Mode in Settings → icon cycles idle → warn → crit on its own.
3. Run `claude` in a terminal, do real work. Menu-bar app picks up the new JSONL events within ~2s. Popover updates.
4. Trigger 80% / 95% / reset thresholds (Demo Mode) → macOS local notifications fire.
5. Run the release workflow (`workflow_dispatch`) → get a notarized DMG attached to a GitHub release.
6. `brew tap mrdemonwolf/den && brew install --cask howlalert` works end-to-end.

### Manual-only tasks for Nathanial

- Apple Developer ID certificate + notarization API key in GH Actions secrets.
- Create `mrdemonwolf/homebrew-den` repo.
- Sparkle EdDSA private key in GH Actions secrets; public key in app bundle.
- **Generate app icons in Apple's Icon Composer.app** from `downloads/howlalert-design/howlalert/project/assets/wolf.png` (1024×1024). Export macOS / iOS / watchOS appiconsets and drop into `apps/{macos,ios,watchos}/Sources/Assets.xcassets/AppIcon.appiconset/`. Same for the 22pt menu-bar template (template image, three states: idle / warn / crit).

---

## Phase 1 — Worker + APNs + iOS basic

**Goal:** Mac → Worker → iPhone push works end-to-end.
**Jira:** HAA-23 → HAA-30.
**Design reference:** Section C of [`docs/design/HowlAlert.html`](docs/design/HowlAlert.html) — Welcome, Pair (QR scanner), dashboard, history, settings on iPhone 17 Pro. Light + dark token mirrors throughout.

### Tasks

- [ ] Scaffold `apps/worker/` with better-t-stack (Hono, CF Workers runtime). Verify existing scaffold.
- [ ] APNs relay: ES256 JWT mint, KV cache (TTL 3000s), HTTP/2 fetch to `api.push.apple.com`.
- [ ] HMAC-SHA256 pairing-token validation on every request.
- [ ] Scaffold `apps/ios/` with basic dashboard + pairing flow.
- [ ] CloudKit pairing: iPhone writes secret → Mac reads on launch.
- [ ] Basic alert push from macOS → Worker → iPhone.
- [ ] Demo Mode in iOS app (works with zero iCloud setup).

### You can now test

1. `cd apps/worker && bun run dev` → `curl localhost:8787/health` returns 200.
2. `wrangler deploy` → `curl https://howlalert.mrdemonwolf.workers.dev/health` returns 200.
3. Build iOS app on a real device. Open it → CloudKit pairing screen → completes within 10s.
4. Mac picks up the pairing on next launch (no manual action).
5. In Mac Demo Mode, trigger 95% threshold → push arrives on iPhone in <5s.
6. iOS Demo Mode toggle shows a synthetic dashboard with no iCloud account needed.

### Manual-only tasks for Nathanial

- APNs `.p8` key from Apple Developer portal → `wrangler secret put APNS_KEY`.
- Apple Team ID + Key ID → Worker env vars.
- iCloud + CloudKit container enabled on `com.mrdemonwolf.howlalert`.

---

## Phase 2 — watchOS + Live Activity + Dynamic Island

**Goal:** glanceable usage everywhere on Apple.
**Jira:** HAA-31 → HAA-36.
**Design reference:** Sections D + E of [`docs/design/HowlAlert.html`](docs/design/HowlAlert.html) — Apple Watch Series 10 / 49mm app + four complication families, Dynamic Island compact/minimal/expanded, Lockscreen Live Activity.

### Tasks

- [ ] watchOS target sharing the iOS target's models.
- [ ] Four complication families: corner / circular / rectangular / inline.
- [ ] Smart Stack widget with `RelevanceConfiguration`.
- [ ] Live Activity with `ActivityKit` — bar depletes left → right as usage grows.
- [ ] Dynamic Island states: compactLeading / compactTrailing / minimal / expanded.
- [ ] Server-side throttle Live Activity updates to once per 2–5 min.

### You can now test

1. Pair an Apple Watch with the test iPhone → all four complication families appear in the watch-face picker.
2. Place the Smart Stack widget on the iPhone Lock Screen → it surfaces when relevance is high.
3. Trigger 80% threshold → Live Activity appears on iPhone Lock Screen, bar shows correct fill %.
4. On a Dynamic Island device, compact + expanded states render with correct copy.
5. Hold at 80–95% for 30 minutes → Live Activity update frequency stays ≤1 per 2 min (confirm in Worker logs).

### Manual-only tasks for Nathanial

- Live Activity entitlement enabled for `com.mrdemonwolf.howlalert`.
- Push-to-Live-Activity APNs topic in the Apple Developer portal.

---

## Phase 3 — Claude Desktop input detection

**Goal:** know when Claude Desktop is waiting on input.
**Jira:** HAA-37 → HAA-40.

### Tasks

- [ ] `HowlAlert.mcpb` MCP server with `notify(title, body, urgency)` tool.
- [ ] Loopback bridge: MCP server POSTs to `http://127.0.0.1:NNNN/event`.
- [ ] Random port chosen at install, stored in App Group container, read by MCP server on every call.
- [ ] AX fallback: `AXObserver` with `AXManualAccessibility = true` (NOT `AXEnhancedUserInterface`).
- [ ] Opt-in Accessibility permission flow.

### You can now test

1. Install `HowlAlert.mcpb` into Claude Desktop → `notify(...)` tool shows up in the tool list.
2. Have Claude Desktop call the tool → menu-bar app receives the loopback POST → notification fires.
3. Revoke Accessibility permission → AX fallback path triggers a graceful onboarding screen, not a silent failure.
4. Restart the menu-bar app → port persists; MCP server still reaches it.

### Manual-only tasks for Nathanial

- Test `.mcpb` install flow in Claude Desktop, confirm packaging works.

---

## Phase 4 — Paywall + App Store submission

**Goal:** monetized iOS + watchOS app live on the App Store.
**Jira:** HAA-41 → HAA-45.
**Design reference:** Section F of [`docs/design/HowlAlert.html`](docs/design/HowlAlert.html) — RevenueCat sheet, Max default-selected with "Save $30 vs Pro" badge, Pro card secondary, 7-day trial CTA. No fake scarcity, no countdown timers.

### Tasks

- [ ] RevenueCat SDK integration in iOS app.
- [ ] **Set RevenueCat App User ID to CloudKit user record ID** via `Purchases.shared.logIn(cloudKitUserRecordID)` on every launch after CloudKit pairing.
- [ ] App Store Connect: create `HowlAlert Pro` + `HowlAlert Max` SKUs in the same subscription group.
- [ ] Configure 7-day free trial as Introductory Offer on both.
- [ ] Build paywall in RevenueCat Dashboard's Paywall Editor (Hosted Paywall).
- [ ] `checkTrialOrIntroDiscountEligibility` before showing CTA.
- [ ] App Review notes explaining Demo Mode (the approval path).
- [ ] App Store assets: screenshots, preview videos, description.
- [ ] Small Business Program enrolled in App Store Connect AND flagged in RevenueCat.

### You can now test

1. Cold-launch iOS app on a fresh sandbox account → paywall shows annual default-selected, cyan border, "BEST VALUE" ribbon, "Save $30 vs Pro" chip.
2. CTA reads `"Start 7-day free trial"` for both selections.
3. Subscribe to Pro in sandbox → `pro_features` entitlement granted; full app unlocks.
4. Cancel → grace period renders correctly.
5. Grant owner lifetime entitlement in RevenueCat Dashboard → reinstall app → entitlement persists.
6. TestFlight build passes App Review notes review with Demo Mode path documented.

### Manual-only tasks for Nathanial

- Create SKUs + intro offers in App Store Connect.
- Configure RevenueCat project: products, entitlement `pro_features`, SBP flag.
- Build paywall in RevenueCat Dashboard's Paywall Editor.
- Enroll in App Store Small Business Program.
- Submit for App Review.
- Post-launch: grant Nathanial (owner) lifetime `pro_features` in RevenueCat Dashboard; same for beta testers + press.
