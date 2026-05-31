# HANDOFF — HowlAlert v2.1

> Continuation notes for a fresh Claude Code session. Read `CLAUDE.md` first, then this. Last updated 2026-05-30 (legal + Pages + repo-settings pass).

## TL;DR — start here

Phase 0 desktop is **functional end-to-end**: the menu-bar app watches `~/.claude`, computes the 5-hour usage window with a P90-auto-detected limit, and shows it live in the popover. **6 of 8 P0 tickets done** (HAA-118 pixel-QA + HAA-125 packaging remain). Docs auto-deploy to GitHub Pages. CI green on every push.

To see it: open `apps/desktop/HowlAlert.xcodeproj` in Xcode 26 → **⌘R** → click the wolf icon in the menu bar. Or `swift test` in `packages/HowlAlertCore` (66 tests).

## Where things stand

Repo wiped from the old v3 plan, rebuilt as **v2.1** (Hono on Bun + Postgres + Redis → Dokploy; Apple apps **macOS 26 / iOS 26 / watchOS 26 only**). Old v3 backed up on branch `backup/pre-v2.1-wipe`. Working tree clean; `main` in sync. Pushes to `main` bypass "Solo Main Protection" (solo admin).

## Key commits (newest first)

- `1b1d81e` native menu-bar rows (Button hover/.help/⌘shortcuts) + visible SF-Symbol status icon
- `0c68d5e` bundle id → com.mrdemonwolf.howlalert.mac (iOS owns root)
- `a86aaca` HAA-122 Stop-hook binary → instant refresh
- `52843a6` HAA-124 bind live usage to popover + Demo Mode
- `dbb3cc2` HAA-121 FSEvents watcher → live pipeline
- `2afbd49` CI: GitHub Pages docs deploy + CI/license/sponsors workflows
- `779d0ce` docs: sync HANDOFF + CLAUDE.md
- `c52f4c8` HAA-123 usage engine (HowlAlertCore) — 5h window + P90
- `16884ff` HAA-120 MenuBarExtra + Liquid Glass popover shell
- `49e87af` rename apps/macos → apps/desktop, org bundle id
- `b8ca65d` HAA-119 Phase-0 Xcode shell
- earlier: scaffold, Redis, CLAUDE.md, HowlAlertUI 20 components

## Monorepo

- JS: `apps/server` `@howlalert/server` (:3000) · `apps/web` (:3001) · `apps/docs` fumadocs (:4000) · `packages/{api,auth,config,db,env,ui}`
- `packages/db/docker-compose.yml` = Postgres + Redis. `bun run db:start`.
- **Swift dirs** (excluded from Bun workspaces): `apps/desktop`, `apps/mobile`, `packages/HowlAlertUI`, `packages/HowlAlertCore`

## packages/HowlAlertCore (usage engine — pure, tested)

`swift-tools-version: 6.2`, `.v26`. **`swift test` → 66 tests green.**
- `UsageEvent` + `ClaudeTranscriptParser` — JSONL → events; dedupe `messageId:requestId` (last chunk wins, parent>subagent, non-sidechain wins), drop all-zero, ISO-8601. Fields validated against real transcripts.
- `FiveHourWindow` — first-activity-anchored 5h blocks, gap-split >5h; `currentBlock`, `completedBlockTotals`.
- `PlanLimitEstimator` + `Percentile` — P90 (type-7) of completed-window totals; remote `limits.json` override; config fallback (NO hard-coded limit).
- `UsageEngine.snapshot(...)` → `UsageSnapshot`; `UsageEngine.recentModels(...)` → `[ModelUsage]` (per-model totals + sparkline).
- `ClaudeConfig.discoverTranscriptRoots()`; `TranscriptReader` (incremental byte-cursor reads, `modifiedAfter` filter).
- `HowlSignal` — Darwin notification post/observe (Stop-hook IPC).
- `UsageAlert` + `usageAlert(previous:current:preferences:)` — pure local-notification transition rule (fire on a rise into warn/crit, re-arm on drop, seed silently, gate via `AlertPreferences`). `UsageState.severity`. 10 unit tests; the desktop `UsageModel.notifyIfNeeded()` just maps the result to a `UNNotificationRequest`.
- `JSONValue` (lossless JSON enum, preserves unknown keys + int/double) + `ClaudeSettingsHook` (`register`/`unregister`/`isRegistered` for the `Stop` hook in `settings.json` — idempotent, never clobbers other hooks). 9 unit tests. Desktop `HookInstaller` does the file I/O on top (backup + atomic write + refuses to touch malformed JSON).
- `howlalert-hook` executable target — posts the stop signal (the Stop-hook binary).

## packages/HowlAlertUI (design system)

`swift build` green. Tokens (`HowlColor` ink-500 `#9AA9C5` — never `#6A7A99`, `HowlSpacing`, `HowlRadius`, `HowlTypography`, `HowlMotion`, `HowlState`). 20 components. `HowlGlass.howlGlass(_:in:)` + `HowlGlassGroup`. **`DetailedPopover` is data-driven**: `init(data: PopoverData = .demo, demoEnabled:, onRefresh:, onQuit:, onToggleDemo:)`; week row renders only when present.
Design source of truth: `apps/docs/design-bundle/` (`design-system.html` + `section-b..h-*.html`).

## apps/desktop (menu-bar app — functional)

`HowlAlert.xcodeproj` (objectVersion 77, FS-synchronized group). `LSUIElement`, macOS 26, Hardened Runtime. Bundle id `com.mrdemonwolf.howlalert.mac` / `.mac.dev` debug. Imports both Swift packages via local SPM refs.

**Bundle-ID scheme (per-app unique; iOS owns the root):** iOS `com.mrdemonwolf.howlalert` · watch `com.mrdemonwolf.howlalert.watchkitapp` · macOS `com.mrdemonwolf.howlalert.mac`. Shared CloudKit container `iCloud.com.mrdemonwolf.howlalert` (desktop↔mobile pairing). Set iOS/watch ids when the mobile project is created. IAP SKUs (`com.howlalert.*`) are a separate namespace.
- Pipeline: `TranscriptWatcher` (FSEvents, 1s debounce) + 60s timer + `HowlSignal` Stop-hook observer → `TranscriptReader` → `UsageEngine` → `UsageSnapshot`. `UsageModel` (`@Observable @MainActor`, 14-day retention), started synchronously in `applicationDidFinishLaunching`.
- `UsageModel.popoverData` maps snapshot + recentModels → `PopoverData`. `PopoverContent` shows live data, or `.demo` when Demo Mode (`@AppStorage("demoMode")`); wires Refresh/Quit/Demo toggle. `StatusItemLabel` → menu-bar icon reflects live state.
- **Native UI pass** (`1b1d81e`, via the `macos` skill): `MenuActionRow` is a real `Button` with animated hover highlight + `.help` tooltips + accessibility; `DetailedPopover` binds per-row actions + real keyboard shortcuts (⌘R refresh, ⌘Q quit). `MenuBarIcon` is an SF Symbol (`gauge…`) — the custom `WolfShape` didn't template-render in the menu bar (read as invisible); swap back to a wolf template later. Brand look kept; interactions are now idiomatic SwiftUI.
- **Native polish pass 2** (`7f8d4a1`, 2026-05-30) + **notifications** (follow-up commit): build-clean (`xcodebuild -scheme HowlAlert` SUCCEEDED) —
  - **Local notifications** — `UsageModel.notifyIfNeeded()` posts a `UNUserNotificationCenter` alert when the window crosses *up* into warn/crit (once per rise, re-arms on drop; first snapshot seeds silently; `isLive` guard keeps QA/dump paths quiet). Gated by Settings toggles `notifyLow` / `notifyAlmostOut` (both default on). New Notifications tab in `SettingsView`. Auth requested in `start()`. Body in brand voice ("16% of your 5-hour window left · resets in 47m").
  - `MenuBarIcon` now uses native `.symbolEffect(.bounce, value: state)` on transitions + a pulsing symbol badge for `.crit` (replaced hand-rolled `scaleEffect`/`opacity`/`onAppear`); `.symbolRenderingMode(.hierarchical)`; mono-default / state-color-on-attention (HIG).
  - **Native `Settings` scene** — new `apps/desktop/HowlAlert/SettingsView.swift` (`TabView` General + About, `Form` `.formStyle(.grouped)`). General wires **launch-at-login via `SMAppService.mainApp`** (toggle mirrors real `.status`), **refresh cadence** (`@AppStorage("refreshInterval")` → `UsageModel.armTimer()`), demo toggle. About = `WolfMark` + version + links. `Settings { SettingsView() }` added to `HowlAlertApp`; popover Settings row wired via `@Environment(\.openSettings)` + `NSApp.activate` (new `onSettings` closure on `DetailedPopover`).
  - **Live footer** — `PopoverData.lastUpdated: Date?`; `DetailedPopover` footer in `TimelineView(.periodic by:1)` → "Updated Ns ago" (`relativeUpdated`) ticking while open. `UsageModel` stamps `lastRefresh` per `refresh()`.
  - **Code-quality** — timer interval is settings-driven (`armTimer()`); `recentModels` uses the snapshot's `now` not a fresh `Date()`.
  - **Stop-hook auto-register (Phase A)** — new **Integration** settings tab + `HookInstaller`. Opt-in toggle writes/removes HowlAlert's Stop hook in `~/.claude/settings.json` (no more manual JSON editing). Locates the binary via `HOWL_HOOK_PATH` (dev) → bundled aux executable (release). Backs up the file once, atomic write, refuses malformed JSON. Merge logic is the tested Core `ClaudeSettingsHook`. **Phase B (bundle the `howlalert-hook` binary into `HowlAlert.app` via a Copy-Files build phase) deferred to HAA-125 packaging** — until then the toggle shows "binary not available" unless `HOWL_HOOK_PATH` is set.
  - **Tab bar wired** — `PopoverTabBar` now uses text labels (Overview / 5-Hour / Weekly / Models) instead of SF Symbols, and the selection actually switches the `DetailedPopover` middle panel (was a dead control). Weekly shows an honest placeholder until the weekly window is live; Models shows per-model rows (placeholder when empty). Header / action rows / footer are shared across tabs.
- **APPROVED design deviations (2026-05-30, Nathanial confirmed — do NOT "fix" back to the mock):**
  - **Settings = native `Settings {}` Preferences window** (⌘,), tabs General / Notifications / About. `section-b-macos.html` shows a dimmed *sheet over the popover* (tabs Pairing/Notifications/Integration/About) — we chose the standard-macOS window for native feel. Pairing (P1) + Integration (Stop-hook setup) tabs not built yet; fold them in when those features land.
  - **Popover tab bar = text labels Overview / 5-Hour / Weekly / Models** (not the mock's SF-Symbol icons Overview/Now/Day/Week). Chosen because it's honest to current data (no daily data; weekly not live; Models is real). Revisit icon styling later if desired.
- **Diagnostic env hooks** (file-based, since GUI stderr isn't capturable): `HOWL_QA_RENDER=/x.png` renders the popover to PNG; `HOWL_USAGE_DUMP=/x.txt` dumps the live snapshot; `HOWL_SIGNAL_PROBE=/x.txt` appends a line per refresh.

## Stop hook wiring (manual, optional)

Build the binary: `cd packages/HowlAlertCore && swift build` → `.build/debug/howlalert-hook`. Register in `~/.claude/settings.json`:
```json
"hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "/abs/path/howlalert-hook" } ] } ] }
```
(Auto-bundling the binary into the .app + auto-registering is future work.)

## Test in Xcode

- Open `apps/desktop/HowlAlert.xcodeproj` in **Xcode 26**. Signing & Capabilities → set Team to your Apple ID (free/personal is fine for local; or it falls back to "Sign to Run Locally"). **⌘R** → wolf icon in menu bar → click for the live popover.
- Live `#Preview`s (glass renders in canvas, unlike `ImageRenderer`): `PopoverShell.swift`, `MenuBarIcon.swift`, `DetailedPopover.swift`.
- Build headless: `xcodebuild -project HowlAlert.xcodeproj -scheme HowlAlert -configuration Debug -destination 'platform=macOS' build` — **use `-scheme`, never `-target`**.

## CI / Deploy (`.github/workflows/`, pinned SHAs)

- `docs.yml` — push to `main` → static-export `apps/docs` → **GitHub Pages**. Live: **https://mrdemonwolf.github.io/howlalert/**. (Pages source already = GitHub Actions.)
- `test.yml` — `js` (ubuntu: check-types + docs build) + `swift` (macos-26: `swift test` Core, `swift build` UI, `xcodebuild` desktop, paths-filtered).
- `license-year.yml` — dormant (no LICENSE yet — repo license TBD, paid app, ask).
- `update_sponsors.yml` — dispatch-only (needs SPONSORKIT_TOKEN + config + Sponsors).

## Jira (project HAA, cloud `7566ead4-4eb1-467e-87cd-f187718109ab`)

Epics `HAA-113`(P0)…`HAA-117`(P4). **P0 status:**
| Key | What | Status |
|---|---|---|
| HAA-118 | HowlAlertUI tokens + 20 components | In Progress (pixel/type-scale QA left) |
| HAA-119 | apps/desktop Xcode shell | **Done** |
| HAA-120 | MenuBarExtra + Liquid Glass shell | **Done** |
| HAA-121 | FSEvents watcher | **Done** |
| HAA-122 | Stop hook binary | **Done** |
| HAA-123 | 5h window + P90 (tests) | **Done** |
| HAA-124 | Popover UI + Demo Mode + refresh | **Done** |
| HAA-125 | Sparkle + DMG + Homebrew | To Do |

## Next steps

- [ ] **HAA-118** — close out: pixel/type-scale QA of components vs `section-*.html`, then mark Done. (Smallest remaining P0.)
- [ ] **HAA-125** — Sparkle 2.x + notarized DMG + Homebrew tap. **NEEDS YOU:** Apple Developer ID cert, notarization creds (App Store Connect API key / `.p8`), a Homebrew tap repo. Ask/walk through before starting. Don't `codesign --deep`; use `LinusU/node-appdmg` (not `create-dmg`).
- [ ] **Weekly window** (not yet ticketed) — a 7-day window + limit so the popover Week row goes live (needs more history than the 14-day retention for a reliable P90; reconsider retention or weekly P90 source).
- [ ] Decide whether **cache-read tokens** count toward the window (currently included; P90 keeps it self-relative).
- [ ] Polish DONE (native pass 2): live relative timer ✓; native `Settings` scene ✓ (General / Notifications / About); local notifications on warn/crit ✓ (needs GUI eyeball — auth prompt + delivery can't be verified headlessly); popover tab bar wired to per-tab panels ✓ (only Overview verified via QA render; 5-Hour/Weekly/Models switch on click — GUI eyeball). REMAINING: Stop-hook binary auto-bundle + auto-register; wolf template-image menu-bar icon (replace SF-Symbol placeholder); weekly window data (then the Weekly tab goes live — needs >14d retention/P90 decision); **Stop-hook Phase B** = bundle the `howlalert-hook` binary into `HowlAlert.app` (Copy-Files build phase — do it with HAA-125 packaging; auto-register Phase A is done). [warn/crit transition logic extracted to Core + unit-tested ✓]
- [ ] Then P1 (`HAA-126–132`): server APNs relay, pairing (HMAC), push, etc.

## Compliance (Apple + Anthropic)

Full audit: **`COMPLIANCE.md`** (repo root, 2026-05-30). Verdict: core mechanism is ToS-clean (local `~/.claude` reads + documented hooks; never touches Anthropic's Services, so anti-scraping/automation clauses don't attach). **One real risk: trademark use of "Claude"** — Consumer Terms §12 forbid using Anthropic's name/marks without written consent (email marketing@anthropic.com); `CLAUDE` is registered (#7645254). CodexBar (researched: MIT, hits the API, no disclaimer) is weak precedent, not permission.

**Done:** non-affiliation disclaimer in the desktop About tab; **`LICENSE` = GPLv3** + Apple App-Store §7 additional permission + trademark reservation (README); **Privacy Policy + EULA + Disclaimer published** as fumadocs pages under `apps/docs/content/docs/legal/` (GDPR + CCPA + Apple EULA Schedule A; placeholders filled — MrDemonWolf, Inc., 645 3rd St Beloit WI 53511, WI law, legal@mrdemonwolf.com). Served via GitHub Pages at `https://mrdemonwolf.github.io/howlalert/docs/legal/{privacy,eula,disclaimer}` (mirrors `mrdemonwolf/wolfwave`'s docs `legal` nav group + `disclaimer.mdx`). No workflow change needed: `apps/docs/next.config.mjs` already **defaults `basePath` to `/howlalert`** when `NEXT_PUBLIC_BASE_PATH` is unset (same pattern as WolfWave → `/wolfwave`). Verified locally: `bun run build` exit 0, 18 static pages incl. the 3 legal routes. **Pages must still be enabled** (Settings → Pages → Source: GitHub Actions) — then `docs.yml` deploys on push to `main`.

**TODO before launch:** fill the legal-doc placeholders + host at stable URLs; email Anthropic for brand permission; confirm GPLv3 dep-compatibility (Sparkle/RevenueCat both MIT ✅) and that copyleft (anyone may redistribute the code) is intended. Mobile App Store bake-in list (IAP 3.1.2 disclosures, account deletion 5.1.1(v), `PrivacyInfo.xcprivacy`, trademark-safe metadata) in the doc. **GPLv3 + App Store needs the §7 Apple exception (now in README) — without it GPL apps can't ship on the App Store.**

## Gotchas

- **xcodebuild:** desktop app builds with `-scheme HowlAlert`, never `-target` (won't resolve local SPM packages).
- **ImageRenderer ≠ Liquid Glass:** off-screen renderer blanks `glassEffect` subtrees. Glass only renders live (window / Xcode canvas). QA PNGs show content only.
- **GUI app stderr isn't capturable** headlessly, and a backgrounded headless launch skips `didFinishLaunching` — use the file-based `HOWL_*` env hooks to observe runtime behavior, or run in Xcode.
- **Swift 6 strict concurrency:** `ISO8601DateFormatter` not Sendable for static use — use `Date.ISO8601FormatStyle`.
- **Docker pulls** fail with osxkeychain `-128` — PATH-shadow stub (memory `env-docker-keychain`).
- `.v26` SwiftPM platform needs `swift-tools-version: 6.2+`. Don't force-push `main`.
