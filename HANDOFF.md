# HANDOFF — HowlAlert v2.1

> Continuation notes for a fresh Claude Code session. Read `CLAUDE.md` first, then this. Last updated 2026-05-29.

## Where things stand

Repo was **wiped from the old v3 plan and rebuilt as v2.1** (Hono on Bun + Postgres + Redis → Dokploy; Apple apps target **macOS 26 / iOS 26 / watchOS 26 only**). Old v3 committed state is backed up on branch `backup/pre-v2.1-wipe` (origin). Working tree is clean; `main` is in sync with origin. Pushes to `main` bypass the "Solo Main Protection" ruleset (expected — solo admin).

## Commits this session (on `main`)

- `6b7257b` wipe v3 (the reset)
- `8403f6a` better-t-stack scaffold (Hono+Next+Drizzle+Postgres+tRPC+better-auth+fumadocs+turborepo)
- `85ecb6d` Redis service + Swift dirs + workspace excludes
- `91f5c9a` regenerate CLAUDE.md (v2.1 rules + structure, 26-only)
- `4093c8e` HowlAlertUI scaffold (tokens + first components) + import design bundle
- `fda98e5` HowlAlertUI full 20-component set

## Monorepo (built + verified)

- `apps/server` `@howlalert/server` Hono+tRPC (:3000) · `apps/web` `@howlalert/web` Next (:3001) · `apps/docs` `@howlalert/docs` fumadocs (:4000)
- `packages/{api,auth,config,db,env,ui}` `@howlalert/*`
- `packages/db/docker-compose.yml` = Postgres + Redis (NOT root). `bun run db:start` brings both up.
- Swift (excluded from Bun workspaces): `apps/macos`, `apps/mobile`, `packages/HowlAlertUI`
- Verified earlier: `bun install` clean · pg+redis healthy · `db:push` · all 3 dev servers 200 · `redis-cli ping` PONG.

## HowlAlertUI (HAA-118 — In Progress)

Swift package at `packages/HowlAlertUI`. `swift-tools-version: 6.2`, platforms `.v26`. **`swift build` is green.**
- Tokens (exact from design bundle): `HowlColor` (ink-500 = `#9AA9C5` AAA — never `#6A7A99`), `HowlSpacing`, `HowlRadius`, `HowlTypography`, `HowlMotion`, `HowlState`
- 20 components: CritBar, TwoBarMeter, UsageMeter, UsageRow, PaceChip, ResetCountdown, ModelRow(+Sparkline), Primary/Secondary/Ghost button styles, PairingCard, EmptyState, NotificationCard, SettingsRow(+PillSelect), StateIcon, WolfMark(full/mono/template), PricingToggle, PopoverTabBar, MenuActionRow, CostSummary, DetailedPopover
- **Pending:** visual/pixel QA vs the HTML refs (can't render SwiftUI headlessly); exact type-scale reconciliation; Liquid Glass material wrappers.

Design bundle (source of truth) lives at `apps/docs/design-bundle/`: `design-system.html` + `section-b..h-*.html` + `chats/chat1.md` (intent). Build from `design-system.html`.

## Jira (project HAA, cloud `7566ead4-4eb1-467e-87cd-f187718109ab`)

Old backlog HAA-1–112 all moved to **Done** (board cleared). Fresh v2.1 backlog created:
- Epics: `HAA-113` P0 · `HAA-114` P1 · `HAA-115` P2 · `HAA-116` P3 · `HAA-117` P4
- Tasks under each: P0 `HAA-118–125`, P1 `HAA-126–132`, P2 `HAA-133–138`, P3 `HAA-139–142`, P4 `HAA-143–148`
- `HAA-76` (scaffold) Done · `HAA-118` (HowlAlertUI) In Progress · rest To Do.

## Next steps

- [ ] **HAA-119** — `apps/macos` Xcode shell that imports HowlAlertUI and renders `DetailedPopover`, so the design can be visually QA'd vs `section-b-macos.html`. (Fastest way to "see it.")
- [ ] Finish HAA-118 visual QA → mark Done.
- [ ] Then HAA-120+ (MenuBarExtra, FSEvents, Stop hook, 5h window math + P90).

## Test HowlAlertUI now

```bash
cd packages/HowlAlertUI && swift build      # compiles clean
```
To see it: open the package in Xcode 26 and preview `DetailedPopover()`, or add it to a host app target.

## Gotchas

- **Docker pulls** fail on this machine with osxkeychain `-128` — bypass with a PATH-shadow stub (see memory `env-docker-keychain`). Cached images survive restarts.
- `.v26` SwiftPM platform needs `swift-tools-version: 6.2+`.
- Don't `git push --force` to main. One Jira ticket per session.
