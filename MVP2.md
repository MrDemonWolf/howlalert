# MVP 2 — Post-launch polish + Gemini

> **Goal:** Gemini CLI support, Live Activity, widgets, admin dashboard, historical charts.
> **Prereq:** MVP 1 shipped + stable for 14 days + green light from Nathanial.
> **Companion:** `PLAN.md` (architecture), `MVP1.md` (prior phases), `CLAUDE.md` (rules).

<p align="center">
  <img src="./assets/logo.svg" alt="HowlAlert" width="120" />
</p>

---

## Rules (unchanged from MVP 1)

1. Work phases in order. Don't skip.
2. At the end of each phase: commit AND push to `main`.
3. Tick checkboxes in this file as you complete them. Commit the update with the phase's code.
4. Use conventional commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`).
5. Before coding, run the session startup ritual in `CLAUDE.md` (includes CodexBar pull — especially important for Phase 11 Gemini work).

---

## Pre-flight for MVP 2

- [ ] MVP 1 live 14+ days with no P1 bugs
- [ ] RevenueCat shows real paying customers (not just sandbox)
- [ ] Nathanial has reviewed top user feedback and confirmed MVP 2 scope still makes sense
- [ ] CodexBar's Gemini provider code (`Sources/Providers/Gemini/`) reviewed at `/Users/nathanialhenniges/Developer/tmp/CodexBar`
- [ ] Gemini CLI installed locally on Nathanial's Mac to test against (`brew install gemini-cli` or equivalent)

---

# Phase 11 — Gemini CLI provider

**Goal:** Users can toggle Gemini CLI on in Settings and see their Gemini pace alongside Claude.

**Approach note:** DO NOT parse `~/.gemini/tmp/**/*.json`. CodexBar proved the OAuth-backed quota API is more reliable (Gemini rewrites its files on every turn and project directories use opaque SHA-256 hashes).

### Tasks

- [ ] Review CodexBar's `Sources/Providers/Gemini/` directory at `/Users/nathanialhenniges/Developer/tmp/CodexBar` — read the approach, don't copy the code
- [ ] Fill in `GeminiCLIProvider` in `packages/howlalert-kit/Sources/HowlAlertKit/Providers/`:
  - [ ] Read `~/.gemini/oauth_creds.json` for OAuth credentials (access token, refresh token, expiry)
  - [ ] Refresh access token via Google's OAuth endpoint when expired
  - [ ] Call `loadCodeAssist` project-id lookup (prefer this over browser cookies)
  - [ ] Fetch quota via Gemini's quota API endpoint
  - [ ] Normalize Gemini's RPM / TPM / RPD windows into the existing `PaceState` model
  - [ ] Map Gemini models (`gemini-2.0-*`, `gemini-pro-*`) into `ModelIdentifier` enum (extend as needed)
  - [ ] Nix CLI layout support — some users have Gemini CLI installed via Nix (per CodexBar community fix)
- [ ] Provider watching strategy: poll Gemini API every 60s (no FSEvents — API is source of truth)
- [ ] Settings UI:
  - [ ] Gemini toggle enabled (was disabled + "Coming in v2" in MVP 1)
  - [ ] Shows OAuth status ("Signed in as nathanial@..." with revoke button)
  - [ ] "Sign in with Gemini CLI" button runs `gemini auth` and watches for `oauth_creds.json` to appear
- [ ] macOS popover:
  - [ ] Provider switcher at top of popover (Claude / Gemini / Both)
  - [ ] "Both" shows independent crit bars per provider (budgets don't mix)
  - [ ] Clear visual separation — different icon/label per provider
- [ ] iOS Dashboard:
  - [ ] Provider filter toggle
  - [ ] Aggregated view shows both providers as separate cards
- [ ] Notification formatting:
  - [ ] Claude: `🐺 Claude · MacBook Pro · 85% used · ~2h left`
  - [ ] Gemini: `🐺 Gemini · MacBook Pro · 40 of 60 RPM used`
- [ ] Unit tests against captured Gemini API responses (save real responses to `Tests/Fixtures/gemini/`)
- [ ] Commit: `feat(kit+apps): gemini cli provider via oauth quota api`
- [ ] Push to `main`

### Done when

- Toggle Gemini in Settings → authenticate → provider card appears
- Running a Gemini CLI session → pace updates within 60s
- Independent threshold pushes fire for Gemini separately from Claude
- Both providers can be enabled simultaneously without data mixing

---

# Phase 12 — Admin dashboard + remote limit multiplier

**Goal:** Nathanial can remotely toggle promo modes (Anthropic 2x, off-peak) without shipping app updates.

### Tasks

- [ ] Complete `apps/admin/` Next.js App Router app:
  - [ ] Tailwind + shadcn/ui
  - [ ] Brand colors via CSS vars
  - [ ] Single-secret auth — no user accounts, no login page, just `?secret=XYZ` or an env var bearer token
- [ ] Routes:
  - [ ] `/` — overview dashboard (paired devices count, active entitlements, push events today)
  - [ ] `/config` — limit multiplier editor
  - [ ] `/push-log` — last 1000 events viewer
  - [ ] `/devices` — paired device listing (reads from D1)
- [ ] Limit multiplier editor:
  - [ ] Current multiplier display (1.0, 2.0, custom)
  - [ ] Promo presets: "Spring Break 2x", "Off-peak 2x", "Disable (1.0x)"
  - [ ] Schedule picker (enable multiplier between dates)
  - [ ] Saves to KV `HOWLALERT_CONFIG` with key `limit_multiplier`
- [ ] Worker exposes `GET /config` → returns current multiplier (cached)
- [ ] Client apps (macOS + iOS) fetch config on launch + every 6h
- [ ] `PaceCalculator` accepts optional multiplier parameter, defaults to 1.0
- [ ] Deploy to Cloudflare Pages → `howlalert-admin.pages.dev` (or `admin.howlalert.app` if DNS)
- [ ] Commit: `feat(admin+worker+kit): remote config + limit multiplier`
- [ ] Push to `main`

### Done when

- Log into admin → change multiplier to 2.0 → Mac + iPhone pace math reflects within 6h (or immediately on launch)
- Push log shows recent events with timestamps, destinations, kinds
- Device listing shows paired Macs + iPhones with last-seen timestamps

---

# Phase 13 — Live Activity + Dynamic Island

**Goal:** Pace bar visible on iPhone Lock Screen + Dynamic Island during an active session.

### Tasks

- [ ] Live Activity target in iOS app
- [ ] Activity attributes: `cloudkitUserId`, `startedAt`, `provider`, `macName`
- [ ] Activity content state: `usagePercent`, `paceState`, `modelMix`, `expiresAt`
- [ ] ActivityKit updates driven by incoming push events (server-pushed updates)
- [ ] Lock Screen presentation:
  - [ ] Crit bar across the full width
  - [ ] Pace label
  - [ ] Mac name (multi-Mac attribution)
- [ ] Dynamic Island:
  - [ ] Compact leading: wolf icon
  - [ ] Compact trailing: `%`
  - [ ] Minimal: thin colored bar
  - [ ] Expanded: full crit bar + pace + model mix
- [ ] Auto-start when first push in a session arrives (not already running)
- [ ] Auto-dismiss after 15 min of no new events
- [ ] Manual dismiss via long-press → end activity
- [ ] Commit: `feat(ios): live activity + dynamic island`
- [ ] Push to `main`

### Done when

- Fire a push from Mac → Live Activity auto-starts on Lock Screen
- Dynamic Island shows correct state during active session
- Activity dismisses after idle timeout

---

# Phase 14 — Widgets (iOS + macOS)

**Goal:** Glanceable pace on Home Screen, Lock Screen, and macOS desktop.

### Tasks

- [ ] iOS Widget Extension target
- [ ] Widget families:
  - [ ] `systemSmall` — just crit bar + percent
  - [ ] `systemMedium` — crit bar + pace label + Mac name
  - [ ] `accessoryCircular` (Lock Screen)
  - [ ] `accessoryRectangular` (Lock Screen)
  - [ ] `accessoryInline` (Lock Screen top bar)
- [ ] Widget data source: reads latest `UsageSnapshot` from CloudKit private DB via shared App Group
- [ ] Timeline refresh: every 15 min (plus WidgetCenter reload on new push event)
- [ ] macOS Widget (desktop widget):
  - [ ] `systemSmall` + `systemMedium`
  - [ ] Reads from same App Group container as menu bar app
- [ ] Widget configuration intent: pick provider (Claude / Gemini / Both), pick window (Session / Weekly)
- [ ] Commit: `feat(ios+macos): widget kit integration`
- [ ] Push to `main`

### Done when

- Home Screen widget installed, updates on each new push
- Lock Screen accessory widget renders correctly in all sizes
- macOS desktop widget available in Notification Center / Desktop

---

# Phase 15 — Historical pace charts

**Goal:** iOS Dashboard shows where you've been, not just where you are.

### Tasks

- [ ] Swift Charts integration in iOS Dashboard
- [ ] Charts:
  - [ ] 7-day stacked bar chart — tokens per day per model
  - [ ] 30-day trend line — percent-of-weekly-limit per week
  - [ ] Current week heatmap — 7 days × 24 hours, intensity = tokens consumed
- [ ] Data source: `UsageEvent` records in CloudKit (already written since MVP 1 Phase 5)
- [ ] Per-model breakdown bar chart
- [ ] Export CSV button → shares CSV via share sheet
- [ ] Also on macOS: a "History" tab in the Settings window (not popover — popover stays minimal)
- [ ] Commit: `feat(ios+macos): historical pace charts + csv export`
- [ ] Push to `main`

### Done when

- Dashboard shows at least 7 days of data for a real user
- CSV export opens cleanly in Numbers / Excel
- Charts update reactively as new events arrive

---

## Post-MVP 2

Bump version to `v2.0.0`. Ship via normal release process (MVP 1 Phase 9 pipeline handles it).

Next up (not committed): **MVP 3+** backlog in `PLAN.md` §1 MVP 3+ column — Codex / Cursor / Copilot providers, team tier, Shortcuts actions, Focus filter integration, Anthropic API direct, Linux support.
