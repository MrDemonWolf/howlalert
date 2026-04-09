# HowlAlert Rebuild Execution Plan

## Current State Assessment

**Repo:** 122 deleted files (unstaged), only `.editorconfig`, `.github/workflows/`, and `howlalert.xcodeproj/` remain on disk. Git history has ~20 commits from the old architecture including worktree-agent merges.

**Old architecture (from git):**
- Root-level `worker/` (standalone Cloudflare Worker with Hono)
- Root-level `admin/` (standalone Next.js dashboard)
- `apps/macos/`, `apps/ios/`, `apps/watchos/` (Swift native apps)
- `apps/docs/` (Fumadocs site)
- `packages/HowlAlertKit/` (Swift Package — pace engine, models, color state, token math)
- `Makefile`-driven (no Turborepo, no bun workspaces)
- `project.yml` (XcodeGen)

**Target architecture (fangdash-style):**
- Bun workspaces + Turborepo monorepo
- `apps/worker/` (Cloudflare Worker — Hono, KV, APNs relay)
- `apps/admin/` (Next.js 15 on Cloudflare Pages)
- `apps/docs/` (Fumadocs)
- `packages/shared/` (TypeScript types, constants)
- `packages/HowlAlertKit/` (Swift Package — lives outside Turbo pipeline)
- Swift apps via Xcode project (macOS, iOS, watchOS)
- `@howlalert/` workspace scope

---

## Phase 0: Jira Cleanup & Repo Reset

### 0A. Jira Ticket Triage

**Close as "Won't Do" (old architecture, superseded):**
- HAA-7: RateWindow model (rebuilt differently in new arch)
- HAA-8: (old architecture ticket)
- HAA-9: ProviderSnapshot / 30-day history (old approach)
- HAA-12: Settings plan picker (old UI)

**Keep open (still valid concepts):**
- HAA-5: Core concept still applies
- HAA-6: Core concept still applies
- HAA-10: MenuBarExtra redesign (concept valid, will be re-implemented)
- HAA-11: Still valid
- HAA-13: Still valid
- HAA-14: ThresholdNotifier (concept valid)

**Overlap analysis — existing vs new tickets:**
| Existing | Concept | New Ticket | Action |
|----------|---------|------------|--------|
| HAA-5 | Docs site | HAA-18 (Fumadocs scaffold) | Close HAA-5 when HAA-18 done |
| HAA-6 | Worker API | HAA-19 (Worker scaffold) | Close HAA-6 when HAA-19 done |
| HAA-10 | macOS MenuBar | HAA-33 (macOS menu bar) | Close HAA-10 when HAA-33 done |
| HAA-11 | iOS app | HAA-22 (Xcode targets) | Close HAA-11 when HAA-22 done |
| HAA-13 | Admin dashboard | HAA-25 (Admin scaffold) | Close HAA-13 when HAA-25 done |
| HAA-14 | Notifications | HAA-37 (threshold alerts) | Close HAA-14 when HAA-37 done |

**Recommendation:** Close HAA-5, 6, 10, 11, 13, 14 as "Won't Do — superseded by rebuild" with a link to the replacement ticket. This keeps the Jira board clean with only HAA-15+ tickets.

### 0B. Repo Reset

1. `git checkout -b rebuild/v2` (preserve old history on main)
2. `git rm -r .` to stage all deletes
3. Commit: `chore: wipe old architecture for v2 rebuild`
4. This gives a clean slate on the `rebuild/v2` branch

---

## Phase 1: Research & Scaffold (HAA-15, 16, 17, 18)

**Goal:** Monorepo boots, `bun install` works, all apps have skeleton `package.json` files.

### Tickets

| Ticket | Title | Description | Worktree? |
|--------|-------|-------------|-----------|
| HAA-15 | Monorepo scaffold | Root `package.json`, `turbo.json`, `bunfig.toml`, `.gitignore`, `CLAUDE.md`, `.editorconfig`, `tsconfig.base.json`, `eslint.config.mjs`, `.prettierrc.json` | Main branch |
| HAA-16 | Research: CloudKit + KV architecture | Doc: how pairing works (CloudKit record -> KV key), push flow, no-DB rationale | Can be parallel |
| HAA-17 | Research: APNs on Cloudflare Workers | Doc: p8 key signing, HTTP/2 to APNs via Worker, token caching in KV | Can be parallel |
| HAA-18 | Docs site scaffold | `apps/docs/` with Fumadocs, placeholder pages | After HAA-15 |

### Execution Order
```
HAA-15 (main branch, sequential — everything depends on this)
  |
  +-- HAA-16 (worktree: research/cloudkit-kv) -- parallel
  +-- HAA-17 (worktree: research/apns-worker) -- parallel
  +-- HAA-18 (worktree: feat/docs-scaffold)   -- parallel (after HAA-15 merged)
```

### PackRunner Configuration
- HAA-15: Run first, merge to `rebuild/v2`
- HAA-16 + HAA-17: Launch 2 subagents in parallel worktrees (research-only, produce markdown docs)
- HAA-18: Launch after HAA-15 merge, needs the root `package.json`

### Phase 1 Verification Checklist
- [ ] `bun install` succeeds at root
- [ ] `bun run build` passes (turbo, no errors)
- [ ] `bun run typecheck` passes
- [ ] `apps/docs/` dev server starts
- [ ] Research docs exist at `docs/research/cloudkit-kv.md` and `docs/research/apns-worker.md`

---

## Phase 2: Worker & Shared Code (HAA-19, 20, 21, 23, 24, 26)

**Goal:** Worker deploys to Cloudflare, KV namespaces bound, push endpoint works (can test with curl).

### Tickets

| Ticket | Title | Description |
|--------|-------|-------------|
| HAA-19 | Worker scaffold | `apps/worker/` — Hono app, `wrangler.toml`, KV bindings, types |
| HAA-20 | KV schema & helpers | `packages/shared/` — KV key patterns, config types, push-log types |
| HAA-21 | APNs relay endpoint | `POST /push` — validate, sign JWT, relay to APNs, log to KV |
| HAA-23 | Config CRUD routes | `GET/PUT /config` — admin config stored in KV |
| HAA-24 | Push log routes | `GET /push-log` — paginated push history from KV |
| HAA-26 | Admin auth middleware | Bearer token auth for admin routes (simple shared secret from env) |

### Execution Order
```
HAA-19 + HAA-20 (parallel — worker scaffold + shared types)
  |
  +-- HAA-26 (worktree: feat/admin-auth) -- needs HAA-19
  +-- HAA-21 (worktree: feat/apns-relay) -- needs HAA-19 + HAA-20
  |
  +-- HAA-23 (worktree: feat/config-routes) -- needs HAA-19 + HAA-20 + HAA-26
  +-- HAA-24 (worktree: feat/push-log-routes) -- needs HAA-19 + HAA-20 + HAA-26
```

### PackRunner Configuration
- Wave 1: HAA-19 + HAA-20 in parallel worktrees
- Wave 2: HAA-26 + HAA-21 in parallel worktrees (after wave 1 merges)
- Wave 3: HAA-23 + HAA-24 in parallel worktrees (after wave 2 merges)

### Phase 2 Verification Checklist
- [ ] `bun run --filter @howlalert/worker dev` starts on port 8787
- [ ] `curl localhost:8787/health` returns 200
- [ ] `curl -X POST localhost:8787/push` with valid payload returns 200
- [ ] `curl localhost:8787/config` with auth header returns config
- [ ] `curl localhost:8787/push-log` returns paginated results
- [ ] `bun run typecheck` passes across all packages
- [ ] `bun run test` passes (worker + shared tests)

---

## Phase 3: Admin Dashboard (HAA-25, 27, 28, 29, 30, 31, 32)

**Goal:** Full admin web app on Cloudflare Pages, can manage config and view push logs.

### Tickets

| Ticket | Title | Description |
|--------|-------|-------------|
| HAA-25 | Admin scaffold | `apps/admin/` — Next.js 15, Tailwind v4, shadcn/ui, Cloudflare Pages adapter |
| HAA-27 | Admin layout & auth | Login page, sidebar, header, auth state management |
| HAA-28 | Dashboard overview | Stats cards (total pushes, active devices, uptime) |
| HAA-29 | Config management page | Form to edit worker config (thresholds, intervals) |
| HAA-30 | Push log viewer | Filterable, paginated table of push history |
| HAA-31 | Device management page | List paired devices, remove pairing |
| HAA-32 | Admin deploy pipeline | `wrangler pages deploy`, GitHub Actions workflow |

### Execution Order
```
HAA-25 (sequential — scaffold first)
  |
  +-- HAA-27 (worktree: feat/admin-auth-ui) -- needs HAA-25
  |
  +-- HAA-28 (worktree: feat/admin-dashboard) -- needs HAA-27
  +-- HAA-29 (worktree: feat/admin-config)    -- needs HAA-27, parallel with 28
  +-- HAA-30 (worktree: feat/admin-push-log)  -- needs HAA-27, parallel with 28/29
  +-- HAA-31 (worktree: feat/admin-devices)   -- needs HAA-27, parallel with 28/29/30
  |
  +-- HAA-32 (worktree: feat/admin-deploy)    -- needs all above merged
```

### PackRunner Configuration
- Wave 1: HAA-25 (sequential)
- Wave 2: HAA-27 (sequential, needs scaffold)
- Wave 3: HAA-28 + HAA-29 + HAA-30 + HAA-31 (4 parallel subagents! Each is an isolated page)
- Wave 4: HAA-32 (sequential, deploy config)

### Phase 3 Verification Checklist
- [ ] `bun run --filter @howlalert/admin dev` starts on port 3001
- [ ] Login flow works with admin token
- [ ] Dashboard shows stats from worker API
- [ ] Config form saves and loads
- [ ] Push log table paginates
- [ ] Device list renders
- [ ] `bun run --filter @howlalert/admin build` succeeds
- [ ] Cloudflare Pages deploy works

---

## Phase 4: macOS App (HAA-22, 33, 37, 41)

**Goal:** macOS menu bar app watches Claude session files, sends push notifications via worker.

### Tickets

| Ticket | Title | Description |
|--------|-------|-------------|
| HAA-22 | Xcode project + targets | `howlalert.xcodeproj` with macOS, iOS, watchOS targets, HowlAlertKit SPM dependency |
| HAA-33 | macOS menu bar app | MenuBarExtra with SwiftUI, FSEvents watcher for `~/.claude/` JSONL files |
| HAA-37 | Threshold alerts | Local notifications when usage hits configurable thresholds (via HowlAlertKit) |
| HAA-41 | HowlAlertKit Swift package | `packages/HowlAlertKit/` — PaceEngine, models, ThresholdColor, CritBarView |

### Execution Order
```
HAA-41 (HowlAlertKit first — shared dependency)
  |
  +-- HAA-22 (Xcode project, references HowlAlertKit)
      |
      +-- HAA-33 (macOS menu bar — needs Xcode project)
      +-- HAA-37 (threshold alerts — needs HowlAlertKit + macOS target)
```

### PackRunner Configuration
- Wave 1: HAA-41 (sequential — Swift package)
- Wave 2: HAA-22 (sequential — Xcode project setup, may need manual XcodeGen or manual config)
- Wave 3: HAA-33 + HAA-37 (parallel — menu bar UI + threshold logic are independent)

**Note:** Swift/Xcode tickets are harder to parallelize via worktrees because `.xcodeproj` is a shared artifact. HAA-33 and HAA-37 can use worktrees only if they modify separate Swift files and merge cleanly.

### Phase 4 Verification Checklist
- [ ] `swift build` succeeds for HowlAlertKit
- [ ] `swift test` passes for HowlAlertKit
- [ ] Xcode project opens and builds all 3 targets
- [ ] macOS app appears in menu bar
- [ ] FSEvents watcher detects file changes in `~/.claude/`
- [ ] Threshold notification fires when simulated usage exceeds limit

---

## Phase 5: Apple Pairing & Push (HAA-34, 35, 36)

**Goal:** End-to-end push: macOS detects usage -> Worker relays -> iOS/watchOS receives push.

### Tickets

| Ticket | Title | Description |
|--------|-------|-------------|
| HAA-34 | CloudKit pairing flow | iOS registers device token, writes to CloudKit; macOS reads pairing record |
| HAA-35 | Push pipeline integration | macOS -> Worker -> APNs -> iOS, full flow with error handling |
| HAA-36 | iOS push notification UI | Rich notification with usage stats, tap to open app |

### Execution Order
```
HAA-34 (sequential — pairing is the foundation)
  |
  +-- HAA-35 + HAA-36 (parallel — push pipeline + notification UI)
```

### PackRunner Configuration
- Wave 1: HAA-34 (sequential)
- Wave 2: HAA-35 + HAA-36 (2 parallel subagents)

### Phase 5 Verification Checklist
- [ ] iOS app can create a pairing record in CloudKit
- [ ] macOS app can read the pairing record
- [ ] macOS -> Worker -> APNs push succeeds (test with real device or simulator)
- [ ] iOS shows rich notification with usage data
- [ ] Push log in admin dashboard shows the delivery

---

## Phase 6: iOS/watchOS Polish (HAA-38, 39)

**Goal:** Demo mode for testing without live data, watchOS companion app.

### Tickets

| Ticket | Title | Description |
|--------|-------|-------------|
| HAA-38 | Demo Mode | Fake data generator for iOS/macOS, toggle in settings, simulates usage patterns |
| HAA-39 | watchOS companion | WatchConnectivity, complication, glanceable usage ring |

### Execution Order
```
HAA-38 + HAA-39 (fully parallel — independent targets)
```

### PackRunner Configuration
- 2 parallel subagents, completely independent

### Phase 6 Verification Checklist
- [ ] Demo Mode toggle in iOS settings generates fake push events
- [ ] watchOS app shows usage ring
- [ ] watchOS complication updates
- [ ] WatchConnectivity syncs data from paired iPhone

---

## Phase 7: Distribution (HAA-40)

**Goal:** `brew install --cask howlalert` works.

### Tickets

| Ticket | Title | Description |
|--------|-------|-------------|
| HAA-40 | Homebrew cask | Cask formula, GitHub Release automation, notarization |

### Execution Order
- Sequential, single ticket

### Phase 7 Verification Checklist
- [ ] `brew install --cask howlalert` installs the macOS app
- [ ] App launches from Homebrew install
- [ ] Notarization passes

---

## Full Dependency Graph

```
Phase 1:  HAA-15 ──┬── HAA-16 (research)
                   ├── HAA-17 (research)
                   └── HAA-18 (docs)

Phase 2:  HAA-19 ──┬── HAA-20 (shared)
          HAA-20 ──┤
                   ├── HAA-26 (auth) ──┬── HAA-23 (config routes)
                   └── HAA-21 (APNs)   └── HAA-24 (push-log routes)

Phase 3:  HAA-25 ── HAA-27 ──┬── HAA-28 (dashboard)
                              ├── HAA-29 (config page)
                              ├── HAA-30 (push log page)
                              └── HAA-31 (devices page) ── HAA-32 (deploy)

Phase 4:  HAA-41 ── HAA-22 ──┬── HAA-33 (macOS menu bar)
                              └── HAA-37 (threshold alerts)

Phase 5:  HAA-34 ──┬── HAA-35 (push pipeline)
                   └── HAA-36 (iOS notification UI)

Phase 6:  HAA-38 (demo mode) ║ HAA-39 (watchOS)  [fully parallel]

Phase 7:  HAA-40 (homebrew)
```

**Cross-phase dependencies:**
- Phase 2 depends on Phase 1 (monorepo must exist)
- Phase 3 depends on Phase 2 (admin calls worker API)
- Phase 4 depends on Phase 1 (monorepo must exist) but NOT Phase 2/3 (Swift is independent)
- Phase 5 depends on Phase 2 (worker push endpoint) + Phase 4 (native apps exist)
- Phase 6 depends on Phase 4 + 5 (native apps + push working)
- Phase 7 depends on Phase 4 (macOS app must be buildable)

**Optimization:** Phases 2+3 (TypeScript) and Phase 4 (Swift) can run in parallel since they share no code. This means:
- Phases 1 -> (2+4 parallel) -> (3+5) -> 6 -> 7

---

## Maximum Parallelism Schedule

| Time Slot | Worktree Agents | Tickets |
|-----------|----------------|---------|
| T1 | 1 agent | HAA-15 (scaffold) |
| T2 | 3 agents | HAA-16, HAA-17, HAA-18 |
| T3 | 2 agents | HAA-19, HAA-20 |
| T3 (also) | 1 agent | HAA-41 (Swift pkg — parallel with TS work) |
| T4 | 2 agents | HAA-26, HAA-21 |
| T4 (also) | 1 agent | HAA-22 (Xcode project) |
| T5 | 2 agents | HAA-23, HAA-24 |
| T5 (also) | 2 agents | HAA-33, HAA-37 (macOS — parallel with TS) |
| T6 | 1 agent | HAA-25 (admin scaffold) |
| T7 | 1 agent | HAA-27 (admin layout) |
| T8 | 4 agents | HAA-28, HAA-29, HAA-30, HAA-31 |
| T9 | 1 agent | HAA-32 (admin deploy) |
| T10 | 1 agent | HAA-34 (CloudKit pairing) |
| T11 | 2 agents | HAA-35, HAA-36 |
| T12 | 2 agents | HAA-38, HAA-39 |
| T13 | 1 agent | HAA-40 (Homebrew) |

**Peak parallelism:** 4 agents at T8 (admin pages), 4 agents at T5 (worker routes + macOS)

---

## Jira Ticket Creation Order

Create tickets in dependency order so blockers are linkable:

**Batch 1 (no blockers):**
HAA-15, HAA-16, HAA-17

**Batch 2 (blocked by HAA-15):**
HAA-18, HAA-19, HAA-20

**Batch 3 (blocked by HAA-19/20):**
HAA-21, HAA-23, HAA-24, HAA-26

**Batch 4 (blocked by HAA-19 or standalone):**
HAA-25, HAA-27, HAA-41

**Batch 5 (blocked by HAA-27 or HAA-41):**
HAA-22, HAA-28, HAA-29, HAA-30, HAA-31, HAA-32

**Batch 6 (blocked by HAA-22):**
HAA-33, HAA-34, HAA-35, HAA-36, HAA-37

**Batch 7 (blocked by Phase 4/5):**
HAA-38, HAA-39, HAA-40

---

## ADHD-Friendly Setup Guide

### The "One Command" Principle
Every phase should start with a single copy-pasteable command. No "first do X, then do Y, then..." chains.

### Setup Guide Structure

```
# HowlAlert Dev Setup (5 minutes)

## Prerequisites (one-time)
brew install bun                    # JavaScript runtime
brew install --cask xcodes          # Xcode version manager
xcodes install 16.2                 # Latest Xcode

## Get Running (every time)
git clone ... && cd howlalert
bun install                         # That's it. You're done.

## Prove It Works
bun run build                       # Should see all green checks
bun run dev                         # Worker on :8787, Admin on :3001, Docs on :3000

## What's Where (mental model)
apps/worker/  = "the brain"    (catches pushes, stores in KV)
apps/admin/   = "the dashboard" (web UI to configure & monitor)
apps/docs/    = "the manual"   (public docs site)
packages/     = "shared stuff" (types, Swift code)
```

### ADHD-Specific Patterns in Codebase
1. **Small files:** No file > 150 lines. Split early, split often.
2. **Clear naming:** `push-log-table.tsx` not `PLT.tsx`. `ThresholdNotifier.swift` not `TN.swift`.
3. **Barrel exports:** Every package has `index.ts` so imports are predictable.
4. **Progress indicators:** Each ticket has a verification checklist. Check boxes = dopamine.
5. **One concern per file:** Route handler in one file, KV helper in another, types in a third.
6. **README in every app/package:** 3-line description + "how to run" + "what it depends on".
7. **Makefile aliases:** `make dev`, `make test`, `make build` — muscle memory.

### Session Workflow
```
1. Pick a ticket from the board (look at "Ready" column)
2. Run: /packrunner HAA-XX
3. Wait for subagent to finish
4. Run the verification checklist
5. Merge and move ticket to Done
6. Pick next ticket. Repeat.
```

---

## Monorepo Structure (Target)

```
howlalert/
├── .claude/
│   └── commands/           # Claude Code slash commands
├── .github/
│   └── workflows/          # CI/CD
├── apps/
│   ├── admin/              # Next.js 15 admin dashboard (@howlalert/admin)
│   ├── docs/               # Fumadocs site (@howlalert/docs)
│   └── worker/             # Cloudflare Worker (@howlalert/worker)
├── docs/
│   └── research/           # Architecture decision records
├── packages/
│   ├── HowlAlertKit/       # Swift Package (outside Turbo pipeline)
│   └── shared/             # TypeScript types & constants (@howlalert/shared)
├── howlalert.xcodeproj/    # Xcode project (macOS, iOS, watchOS targets)
├── package.json            # Root workspace config
├── turbo.json              # Turborepo pipeline
├── bunfig.toml             # Bun config (isolated linker)
├── tsconfig.base.json      # Shared TS config
├── eslint.config.mjs       # Root ESLint
├── .prettierrc.json        # Prettier config
├── .editorconfig           # Editor config (tabs)
├── CLAUDE.md               # Claude Code guide
├── Makefile                # Developer shortcuts
└── README.md
```

---

## Risk Register

| Risk | Mitigation |
|------|-----------|
| APNs HTTP/2 from Cloudflare Workers | Research ticket HAA-17 validates this early; fallback: use `fetch()` with `nghttp2` or relay via a thin Node proxy |
| CloudKit JS API complexity | Research ticket HAA-16 validates; fallback: simple KV-only pairing with manual token entry |
| Xcode project conflicts in worktrees | Only 1 worktree touches `.xcodeproj` at a time; Swift file changes in parallel are safe |
| 4 parallel admin pages at T8 | Each page is self-contained (own route, own components); merge conflicts only in sidebar nav (trivial) |
| Homebrew cask requires notarization | Plan notarization in HAA-40; if blocked, distribute as `.dmg` from GitHub Releases first |

