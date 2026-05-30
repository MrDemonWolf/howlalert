# HANDOFF — HowlAlert v2.1

> Continuation notes for a fresh Claude Code session. Read `CLAUDE.md` first, then this. Last updated 2026-05-29.

## Where things stand

Repo was **wiped from the old v3 plan and rebuilt as v2.1** (Hono on Bun + Postgres + Redis → Dokploy; Apple apps target **macOS 26 / iOS 26 / watchOS 26 only**). Old v3 committed state is backed up on branch `backup/pre-v2.1-wipe` (origin). Working tree clean; `main` in sync with origin. Pushes to `main` bypass the "Solo Main Protection" ruleset (expected — solo admin).

## Key commits (newest first)

- `c52f4c8` feat(core): HAA-123 usage engine (HowlAlertCore) — 5h window + P90, 32 tests
- `16884ff` feat(desktop): HAA-120 MenuBarExtra status item + Liquid Glass popover shell
- `49e87af` refactor(desktop): rename apps/macos → apps/desktop, org bundle id
- `b8ca65d` feat(macos): HAA-119 Phase-0 Xcode shell rendering DetailedPopover
- `72cbaee` docs: archive original v2.1 kickoff prompt (`docs/v2.1-kickoff-prompt.md`)
- `fda98e5` feat(ui): HowlAlertUI full 20-component set
- `4093c8e` feat(ui): HowlAlertUI scaffold (tokens + first components) + design bundle
- `91f5c9a` docs: regenerate CLAUDE.md (v2.1 rules + structure, 26-only)
- `85ecb6d` Redis service + Swift dirs + workspace excludes
- `8403f6a` better-t-stack scaffold (Hono+Next+Drizzle+Postgres+tRPC+better-auth+fumadocs+turborepo)
- `6b7257b` wipe v3 (the reset)

## Monorepo (built + verified)

- `apps/server` `@howlalert/server` Hono+tRPC (:3000) · `apps/web` `@howlalert/web` Next (:3001) · `apps/docs` `@howlalert/docs` fumadocs (:4000)
- `packages/{api,auth,config,db,env,ui}` `@howlalert/*`
- `packages/db/docker-compose.yml` = Postgres + Redis (NOT root). `bun run db:start` brings both up.
- **Swift dirs** (excluded from Bun workspaces): `apps/desktop`, `apps/mobile`, `packages/HowlAlertUI`, `packages/HowlAlertCore`
- Verified earlier: `bun install` clean · pg+redis healthy · `db:push` · all 3 dev servers 200 · `redis-cli ping` PONG.

## apps/desktop (HAA-119 + HAA-120 — Done)

Xcode project at `apps/desktop/HowlAlert.xcodeproj` (objectVersion 77, file-system-synchronized group). Menu-bar-only (`LSUIElement`), macOS 26, Hardened Runtime. Bundle id `com.mrdemonwolf.howlalert` (release) / `.dev` (debug). Imports `packages/HowlAlertUI` via local SPM ref.
- `HowlAlertApp.swift` — `MenuBarExtra` (`.window`): state-driven `MenuBarIcon` label + `PopoverShell { DetailedPopover() }`.
- `MenuBarIcon.swift` — `WolfMark(.mono)` tinted by `HowlState`, crit pulse badge.
- `PopoverShell.swift` — Liquid Glass popover chrome (nav layer only).
- **QA harness:** `HOWL_QA_RENDER=/path.png <app-binary>` renders the popover to PNG via `ImageRenderer` and exits. **Limitation:** `ImageRenderer` can't rasterize Liquid Glass (blanks the subtree) — QA PNG shows content only; view glass live in the popover or the `#Preview`s.

## packages/HowlAlertUI (HAA-118 — In Progress)

`swift-tools-version: 6.2`, platforms `.v26`. **`swift build` green.**
- Tokens: `HowlColor` (ink-500 = `#9AA9C5` AAA — never `#6A7A99`), `HowlSpacing`, `HowlRadius`, `HowlTypography`, `HowlMotion`, `HowlState`
- 20 components: CritBar, TwoBarMeter, UsageMeter, UsageRow, PaceChip, ResetCountdown, ModelRow(+Sparkline), Primary/Secondary/Ghost button styles, PairingCard, EmptyState, NotificationCard, SettingsRow(+PillSelect), StateIcon, WolfMark(full/mono/template), PricingToggle, PopoverTabBar, MenuActionRow, CostSummary, DetailedPopover
- `HowlGlass.swift` (added HAA-120): `View.howlGlass(_:in:)` + `HowlGlassGroup` (GlassEffectContainer). Nav layer only.
- **Pending (to close HAA-118):** pixel QA vs HTML refs; exact type-scale reconciliation.

Design bundle (source of truth): `apps/docs/design-bundle/` — `design-system.html` + `section-b..h-*.html` + `chats/chat1.md`. Build from `design-system.html`.

## packages/HowlAlertCore (HAA-123 — Done)

Pure, testable usage engine. `swift-tools-version: 6.2`, `.v26`. **`swift test` green — 32 tests.**
- `UsageEvent` + `ClaudeTranscriptParser` — `~/.claude` JSONL → token events; dedupe `messageId:requestId` (last chunk wins, parent beats subagent, non-sidechain wins), drop all-zero, ISO-8601. Patterns studied from CodexBar, reimplemented.
- `FiveHourWindow` — first-activity-anchored 5h blocks, gap-split > 5h; `currentBlock` + `completedBlockTotals`.
- `PlanLimitEstimator` + `Percentile` — P90 (type-7) of completed-window totals; remote `limits.json` override; config fallback (NO hard-coded limit).
- `UsageEngine.snapshot(events:config:now:)` → `UsageSnapshot` (used %, resets-at, ok/warn/crit, burn-rate run-out).
- **Not yet wired into the app** — HAA-121 feeds it live files, HAA-124 binds the snapshot to the UI.

## CodexBar reference (study, never copy — MIT)

Local clone: `/Users/nathanialhenniges/Developer/tmp/CodexBar`. Key finding: CodexBar **does NOT compute the 5h window or plan limits from JSONL** — it scrapes those from Anthropic's OAuth API / `claude /usage` CLI. Its JSONL engine (`Sources/CodexBarCore/Vendored/CostUsage/CostUsageScanner+Claude.swift`) only does daily token aggregation + cost. So HowlAlert's window/P90 math is net-new; only the parsing/dedupe patterns were reusable prior art.

## CI / Deploy (`.github/workflows/`)

Mirrored from WolfWave (pinned action SHAs):
- `docs.yml` — push to `main` → build `apps/docs` static export → deploy to **GitHub Pages**. **Docs are statically exported** now (`next.config.mjs` `output: "export"`, `basePath` default `/howlalert`, `trailingSlash`; search → fumadocs `staticGET` + `RootProvider search type:"static"`; `og`/`llms` routes are `force-static`). Local build verified → `apps/docs/out/`. **One-time:** enable repo Settings → Pages → Source = **GitHub Actions**.
- `test.yml` — CI. `js` job (ubuntu): `bun install`, `check-types`, docs build. `swift` job (`macos-26`, paths-filtered): `swift test` HowlAlertCore, `swift build` HowlAlertUI, `xcodebuild build` desktop.
- `license-year.yml` — annual LICENSE year bump. **Dormant: no LICENSE file yet** (repo license TBD — paid app, ask before choosing).
- `update_sponsors.yml` — sponsorkit SVG. **Dormant: dispatch-only.** Needs `SPONSORKIT_TOKEN` secret + sponsor config + `apps/docs/public/` + GitHub Sponsors before re-adding a cron.
- Local docs dev without basePath: `NEXT_PUBLIC_BASE_PATH="" bun run --filter @howlalert/docs dev`.

## Jira (project HAA, cloud `7566ead4-4eb1-467e-87cd-f187718109ab`)

Old backlog HAA-1–112 → Done (board cleared). Fresh v2.1 backlog:
- Epics: `HAA-113` P0 · `HAA-114` P1 · `HAA-115` P2 · `HAA-116` P3 · `HAA-117` P4
- P0 `HAA-118–125` · P1 `HAA-126–132` · P2 `HAA-133–138` · P3 `HAA-139–142` · P4 `HAA-143–148`

**P0 status:**
| Key | What | Status |
|---|---|---|
| HAA-118 | HowlAlertUI tokens + 20 components | In Progress (pixel QA left) |
| HAA-119 | apps/desktop Xcode shell | **Done** |
| HAA-120 | MenuBarExtra + Liquid Glass popover shell | **Done** |
| HAA-121 | FSEvents watcher on `~/.claude/projects/**/*.jsonl` | To Do |
| HAA-122 | Stop hook handler binary | To Do |
| HAA-123 | 5h window math + P90 (tests) | **Done** |
| HAA-124 | Popover UI + Demo Mode + refresh cadence | To Do |
| HAA-125 | Sparkle + notarized DMG + Homebrew tap | To Do |

## Next steps

- [ ] **HAA-121** — FSEvents watcher on `~/.claude/projects/**/*.jsonl`; resolve roots (`CLAUDE_CONFIG_DIR`, then `~/.config/claude/projects`, then `~/.claude/projects`); incremental reads → feed `ClaudeTranscriptParser` → `UsageEngine`. (Wires the engine to live data.)
- [ ] **HAA-124** — bind `UsageSnapshot` to `DetailedPopover` + Demo Mode + refresh cadence. (Needs 121.)
- [ ] **HAA-122** — Stop hook handler binary (Claude Code Stop hook → nudge a refresh).
- [ ] Finish **HAA-118** pixel/type-scale QA vs HTML refs → mark Done.
- [ ] **HAA-125** — Sparkle 2.x + notarized DMG + Homebrew tap (last P0; needs Apple Dev portal — ASK first).

## Build / test commands

```bash
cd packages/HowlAlertCore && swift test     # 32 tests, the usage engine
cd packages/HowlAlertUI   && swift build    # design system compiles
# desktop app (use -scheme, NOT -target — -target won't resolve the SPM product):
cd apps/desktop && xcodebuild -project HowlAlert.xcodeproj -scheme HowlAlert \
  -configuration Debug -destination 'platform=macOS' build
```

## Gotchas

- **xcodebuild:** build the desktop app with `-scheme HowlAlert`, never `-target` — `-target` fails to resolve the local SPM package (`unable to resolve module dependency: 'HowlAlertUI'`).
- **ImageRenderer ≠ Liquid Glass:** off-screen `ImageRenderer` blanks any `glassEffect` subtree. Glass only renders in a live window / Xcode canvas.
- **Swift 6 strict concurrency:** `ISO8601DateFormatter` isn't Sendable for static use — use the value-type `Date.ISO8601FormatStyle` instead.
- **Docker pulls** fail on this machine with osxkeychain `-128` — bypass with a PATH-shadow stub (memory `env-docker-keychain`). Cached images survive restarts.
- `.v26` SwiftPM platform needs `swift-tools-version: 6.2+`.
- Don't `git push --force` to main. One Jira ticket per session.
