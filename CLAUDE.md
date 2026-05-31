# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Read this first. These rules override defaults. Architecture is **v2.1** (Hono on Bun + Postgres + Redis, deployed to Dokploy). Apple apps target **macOS 26 / iOS 26 / watchOS 26 only**.

---

## 1. Who you are + how to talk to Nathanial

Primary developer on **HowlAlert** — a Claude Code usage-limit monitor for the Apple ecosystem. Owner: Nathanial Henniges ([MrDemonWolf, Inc.](https://mrdemonwolf.com)). GitHub `mrdemonwolf/howlalert`. Jira `mrdemonwolf.atlassian.net`, project key `HAA`, cloud ID `7566ead4-4eb1-467e-87cd-f187718109ab`.

- ADHD + Asperger's. Be direct, specific, concrete. No vague framing, no corporate filler, no emojis.
- Numbered checkbox steps (`- [ ]`) for any plan. Lead with your top recommendation + one-line reason; alternatives only if asked.
- Plain language first, technical terms after. Push back if he's wrong — don't just agree.
- Plan, then build. Don't dive into code on the first turn of a new ticket.

## 2. What HowlAlert is

Three surfaces + a relay:

| Surface | Path | Distribution | Cost |
|---|---|---|---|
| Desktop menu bar | `apps/desktop` | Notarized DMG via Homebrew cask | Free |
| Mobile (iOS + watchOS) | `apps/mobile` | App Store | Paid |
| Server (APNs relay) | `apps/server` | Hono on Bun → Dokploy | — |
| Admin + Docs | `apps/web`, `apps/docs` | Next.js + fumadocs | — |

Desktop watches `~/.claude/` via FSEvents + Claude Code's Stop hook, computes usage, fires local + push notifications. Inspired by CodexBar (`github.com/steipete/CodexBar`, MIT) — study patterns, never copy verbatim.

## 3. Pricing (exact names everywhere)

| Tier | Price | SKU |
|---|---|---|
| **HowlAlert Pro** | $4.99 / month | `com.howlalert.pro.monthly` |
| **HowlAlert Max** | $29.99 / year | `com.howlalert.max.annual` |

Both grant the same RevenueCat entitlement `pro_features` — **never gate features between them**. 7-day free trial on both. Max (annual) default-selected on paywall, cyan border + "BEST VALUE" + "Save $30 vs Pro". CTA always `"Start 7-day free trial"`. Same subscription group in App Store Connect. No third tier, no countdown timers, no monthly→annual auto-prompt. App Store Small Business Program (15%).

## 4. Tech stack

- **Desktop:** Swift 6 / SwiftUI, `LSUIElement = true`, FSEvents + Hardened Runtime + Developer ID notarization. **macOS 26.0+ only.**
- **Mobile:** Swift 6 / SwiftUI — ONE Xcode project, two targets (iOS app + watchOS app). **iOS 26.0+ / watchOS 26.0+ only.**
- **Shared Swift UI:** `packages/HowlAlertUI` Swift package — design tokens + 20 components, imported by both Xcode projects via local Swift Package reference.
- **Shared Swift logic:** `packages/HowlAlertCore` Swift package — usage engine (JSONL parse + dedupe, 5h-window math, P90 limit auto-detect). Pure + unit-tested (`swift test`); no UI. Imported by `apps/desktop` (+ `apps/mobile` later).
- **Liquid Glass:** unconditional (26-only) — navigation layer only (toolbars, popovers, floating CTAs), never on content cards. No `@available` guards, no `.ultraThinMaterial` fallback.
- **Server:** Hono + tRPC on Bun → Dokploy. **Postgres + Drizzle** (device tokens, pairing records) and **Redis/ioredis** (APNs JWT ~50min TTL, replay nonces, Live Activity throttle, rate limits).
- **Admin:** Next.js 15 + tRPC + better-auth. **Docs:** fumadocs. **Monorepo:** Turborepo + Bun workspaces.
- **Auth:** macOS→server = HMAC-SHA256 over a CloudKit-shared secret; admin = better-auth. **Push:** APNs HTTP/2 from Hono, ES256 JWT cached in Redis. **IAP:** RevenueCat (`purchases-ios` 5.x SPM). **Updates:** Sparkle 2.x (EdDSA).

## 5. Monorepo layout

Bun + Turborepo. Workspaces glob `apps/*` + `packages/*` **excluding the Swift dirs** (`!apps/desktop`, `!apps/mobile`, `!packages/HowlAlertUI`, `!packages/HowlAlertCore`).

```
apps/
  server/   @howlalert/server  — Hono + tRPC on Bun (:3000)
  web/      @howlalert/web      — Next.js 15 admin (:3001)
  docs/     @howlalert/docs     — fumadocs (:4000)
  desktop/  Xcode macOS app     (Swift, not a Bun workspace)
  mobile/   Xcode iOS+watchOS   (Swift, not a Bun workspace)
packages/
  api/      @howlalert/api      — tRPC routers + context
  auth/     @howlalert/auth     — better-auth
  db/       @howlalert/db       — Drizzle schema + docker-compose.yml (Postgres + Redis)
  env/      @howlalert/env      — env validation (server reads from apps/server/.env)
  config/   @howlalert/config   — shared TS config
  ui/       @howlalert/ui       — shared React UI (web)
  HowlAlertUI/    Swift design system (not a Bun workspace)
  HowlAlertCore/  Swift usage engine — JSONL parse, 5h window, P90 limit (not a Bun workspace)
```

Two Xcode projects only: `apps/desktop` = macOS desktop, `apps/mobile` = iOS + watchOS together. Never split watch into its own project.

## 6. Commands

```bash
bun install                                   # install all JS workspaces
bun run db:start                              # docker compose up -d (Postgres + Redis) in packages/db
bun run db:push                               # drizzle-kit push schema (reads apps/server/.env)
bun run db:studio | db:generate | db:migrate | db:stop | db:down
bun run dev                                   # turbo dev — runs server + web + docs (start db first)
bun run dev:server                            # @howlalert/server only (:3000)
bun run dev:web                               # @howlalert/web only (:3001)
bun run --filter @howlalert/docs dev          # docs only (:4000)
bun run build                                 # turbo build (all)
bun run check-types                           # turbo check-types (tsc)

# Swift (not Bun workspaces)
cd packages/HowlAlertCore && swift test       # usage-engine unit tests (32)
cd packages/HowlAlertUI   && swift build      # design system compiles
cd apps/desktop && xcodebuild -project HowlAlert.xcodeproj -scheme HowlAlert \
  -configuration Debug -destination 'platform=macOS' build   # use -scheme, NOT -target
```

Docker compose lives at `packages/db/docker-compose.yml` (not root). No JS test runner/linter configured yet — don't invent `bun test`/lint commands. Swift logic is unit-tested via `swift test` in `packages/HowlAlertCore`; build the desktop app with `xcodebuild -scheme` (never `-target` — it won't resolve the local SPM package).

## 7. Architecture notes

- **No sensitive user data on the server.** Postgres holds only device tokens + pairing HMACs; CloudKit holds the truth. Redis is hot/ephemeral (TTL'd).
- **Don't hard-code Claude plan limits** — Anthropic doubled them May 2026. Use P90 auto-detect + a remote `limits.json`.
- **Pairing:** CloudKit-shared secret → HMAC-SHA256 on macOS→server calls; Redis nonce for replay protection.
- env vars validated via `@howlalert/env`; local dev values in gitignored `.env` (see `apps/server/.env.example`).

## 8. Brand & voice

Colors: navy `#091533`, cyan `#0FACED`, green `#3DDC97` / amber `#FFA533` / red `#FF4D4D`. `ink-500` = `#9AA9C5` (audited for AA — **do NOT revert to `#6A7A99`**). Voice: **"watching"** not "monitoring". Natural time strings ("Runs out in 47m"). No emojis in product UI. No exclamation points except resets.

## 9. Hard rules — never violate

- ❌ Don't gate features between Pro and Max — same `pro_features` entitlement. No third tier. No countdown timers / fake scarcity.
- ❌ Don't store sensitive user data on the server — device tokens + pairing HMACs only.
- ❌ Don't hard-code Claude plan limits — P90 auto-detect + remote `limits.json`.
- ❌ Don't use React Native — iOS/watchOS is native Swift.
- ❌ Don't make more than two Xcode projects (`desktop` = macOS, `mobile` = iOS + watch).
- ❌ Don't add conditional pre-26 fallbacks — target macOS 26 / iOS 26 / watchOS 26 only.
- ❌ Don't revert `ink-500` to `#6A7A99` (fails AA) — use `#9AA9C5`.
- ❌ Don't commit secrets (`.p8`, App Store Connect keys, RevenueCat keys). Use `.env` (gitignored) + Dokploy env vars + Xcode `.xcconfig` (gitignored).
- ❌ Don't `codesign --deep` the macOS app — breaks Sparkle's nested signatures.
- ❌ Don't use `create-dmg` (npm) or node-appdmg — build the DMG with a bare-`hdiutil` script (mirrors `mrdemonwolf/wolfwave` `scripts/create-dmg.sh`: UDRW image → AppleScript Finder layout → UDZO convert).
- ❌ Don't write tests after the fact — write alongside, especially the 5h-window math + JSONL parser.
- ❌ Never force-push to `main`; never rewrite published history.
- If something feels wrong or ambiguous, **stop and ask**.

## 10. Soft rules — push back if asked to break these

- Prefer self-hosted + open-source over SaaS. TypeScript over JavaScript always.
- READMEs in MrDemonWolf house format (use the `mrdw-readme` skill).
- Run the `audit-duplicates` skill before any refactor session.
- Conventional commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`). Solo project — push directly to `main`; the "Solo Main Protection" ruleset + CI gates guard bad pushes.

## 11. Environment / IDs / URLs

| Resource | Value |
|---|---|
| GitHub | `mrdemonwolf/howlalert` |
| Jira | project `HAA`, cloud ID `7566ead4-4eb1-467e-87cd-f187718109ab` |
| Server (APNs relay) | Hono on Bun → Dokploy |
| Bundle ID — iOS | `com.mrdemonwolf.howlalert` (root) |
| Bundle ID — watchOS | `com.mrdemonwolf.howlalert.watchkitapp` (must prefix the iOS id) |
| Bundle ID — macOS desktop | `com.mrdemonwolf.howlalert.mac` (debug `.mac.dev`) |
| CloudKit container (shared) | `iCloud.com.mrdemonwolf.howlalert` |
| App Store SKU (Pro) | `com.howlalert.pro.monthly` |
| App Store SKU (Max) | `com.howlalert.max.annual` |
| RevenueCat entitlement | `pro_features` |

> Bundle IDs are **per-app unique** (3 separate App Store / Developer records). The iOS app owns the root; macOS/watch are suffixed. IAP SKUs are a separate namespace (no overlap). The CloudKit container is **shared** across all apps — that's how desktop ↔ mobile pair.
| Local DB | `postgresql://postgres:password@localhost:5432/howlalert` |
| Local Redis | `redis://localhost:6379` |

## 12. Jira workflow + when to ask

Statuses: To Do → In Progress → Done (no "Deploy"). On 2026-05-29 the entire legacy backlog (HAA-1–112) was moved to Done to clear the board for a fresh v2.1 ticket set — new work starts at new keys. Work one ticket per session: quote its acceptance criteria, propose a checkbox breakdown, ask blocking questions, then build; commit + push per phase; mark the ticket Done when criteria are met.

Ask first for: Apple Developer portal actions, App Store Connect changes, RevenueCat config, GitHub Actions secrets, installing anything outside the locked stack, or unclear/contradictory acceptance criteria.
