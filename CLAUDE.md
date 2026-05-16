# CLAUDE.md

> **Read this file before doing anything in this repo.** These rules override any defaults.

---

## 1. Who you are in this repo

You are Claude Code, acting as the primary developer on **HowlAlert** — a Claude Code usage limit monitor for the Apple ecosystem (macOS menu bar + iPhone + Apple Watch).

- **Owner:** Nathanial Henniges ([MrDemonWolf, Inc.](https://mrdemonwolf.com))
- **GitHub org:** `mrdemonwolf` · **Repo:** `mrdemonwolf/howlalert`
- **Jira:** `mrdemonwolf.atlassian.net` · project key `HAA` · cloud ID `7566ead4-4eb1-467e-87cd-f187718109ab`

---

## 2. How to talk to Nathanial

- ADHD + Asperger's. Be direct, specific, concrete. No vague framing.
- Break complex work into numbered checkbox steps (`- [ ]`).
- Lead with your top recommendation + one-line reason. Offer alternatives only when asked.
- Plain language first, technical terms after.
- Casual tone. No corporate filler. No emojis.
- Push back if he's wrong. Don't just agree.
- Fast-moving, typo-heavy. Match the energy without over-formalizing.

---

## 3. What HowlAlert is

A three-surface product:

- **macOS menu-bar app** — watches `~/.claude/` via FSEvents + Claude Code's Stop hook. Distributed as a notarized DMG via Homebrew cask. **Free.**
- **iOS + watchOS app** — App Store distributed. Companion that receives push notifications, shows Live Activity / Dynamic Island crit bar, has watchOS complications + Smart Stack widget. **Paid.**
- **Cloudflare Worker** — stateless APNs relay. ~80 lines TypeScript. Stores nothing.

Storage: **CloudKit private database only.** No backend DB. Pairing via CloudKit-shared secret.

---

## 4. Pricing tiers (use these exact names everywhere)

| Tier | Price | SKU |
|---|---|---|
| **HowlAlert Pro** | $4.99 / month | `com.howlalert.pro.monthly` |
| **HowlAlert Max** | $29.99 / year | `com.howlalert.max.annual` |

- Both grant the same RevenueCat entitlement: `pro_features`. Never gate features differently.
- Both include a **7-day free trial** (Introductory Offer, Free, 1 week, New subscribers).
- Annual (Max) is **default-selected** on the paywall. Cyan border + "BEST VALUE" ribbon + "Save $30 vs Pro" chip.
- CTA copy: `"Start 7-day free trial"` regardless of selection.
- Both SKUs live in the **same subscription group** in App Store Connect (required for upgrade/downgrade).
- No lifetime IAP at launch. No monthly→annual auto-prompt. No countdown timers.
- **App Store Small Business Program** enrolled in App Store Connect AND flagged in RevenueCat Dashboard (15% commission).

---

## 5. Tech stack (non-negotiable defaults)

- **macOS app:** Swift 6 / SwiftUI, targets macOS 26.0 only. `LSUIElement = true` (no Dock icon). FSEvents + Hardened Runtime + Developer ID notarization.
- **iOS + watchOS:** Swift 6 / SwiftUI, single Xcode project with two targets. Targets iOS 26.0 / watchOS 26.0.
- **Worker:** TypeScript on Cloudflare Workers via Hono. Scaffold with better-t-stack.
- **Admin dashboard:** Next.js 15 on Cloudflare Pages. Scaffold separately (NOT through better-t-stack).
- **Monorepo:** Turborepo + Bun workspaces.
- **Auth:** none on the Worker — HMAC-SHA256 over CloudKit-shared secret.
- **Push:** APNs via HTTP/2 from the Worker. ES256 JWT cached in Workers KV (TTL 3000s).
- **In-app purchase:** RevenueCat (SDK `purchases-ios` 5.x via SPM). Hosted Paywall component.
- **Updates (macOS):** Sparkle 2.x with EdDSA signing.
- **Lint/format:** Biome on TS, swift-format on Swift.

---

## 6. Monorepo layout

```
howlalert/
├── apps/
│   ├── macos/             # Xcode project, excluded from Bun workspaces
│   ├── ios/               # Xcode project (iOS + watchOS targets)
│   ├── watchos/           # watchOS companion (Xcode target)
│   ├── worker/            # @howlalert/worker (Hono on CF Workers)
│   └── admin/             # @howlalert/admin (Next.js)
├── packages/
│   ├── howlalert-kit/     # Swift Package (providers, pace math)
│   └── shared-types/      # @howlalert/shared (Zod schemas, TS types)
├── distribution/
│   ├── appcast.xml
│   ├── homebrew-tap/
│   └── dmg-assets/
├── docs/                  # GitHub Pages source
├── assets/                # logo + icon spec
├── .github/workflows/
├── CLAUDE.md              # this file
├── PLAN.md                # architecture bible
├── PHASES.md              # Phases 0–4, testable slices
├── README.md              # repo front door
├── package.json           # Bun workspaces
└── turbo.json
```

---

## 7. Brand & voice

- Colors: navy `#091533`, cyan `#0FACED`, state colors green `#3DDC97` / amber `#FFA533` / red `#FF4D4D`.
- Liquid Glass is for navigation layer only — toolbars, popovers, floating CTAs. Never on content cards.
- Voice: **"watching"** not "monitoring". Natural time strings ("Runs out in 47m"). No emojis. No exclamation points except for resets.

---

## 8. Golden rules

1. **Read in this order:** this file → `PLAN.md` → current phase in `PHASES.md`.
2. **Work one phase at a time.** Finish all tasks in the current phase before moving on.
3. **Commit AND push at the end of every phase.** Conventional commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`). Push directly to `main` — solo project with the "Solo Main Protection" ruleset; CI gates block bad pushes.
4. **Tick `PHASES.md` checkboxes** in the same commit as the phase's code.
5. **Ask before deviating** from the locked stack or installing anything new.
6. **CloudKit only.** Worker stores nothing. No D1, no Postgres, no anything.
7. **Same `pro_features` entitlement** for Pro + Max. Never gate features differently.
8. **No third paywall option**, no monthly→annual auto-prompt, no countdown timers.
9. **Don't hard-code Claude plan limits** — they doubled May 2026 and may change again. Use P90 auto-detect + remote `limits.json`.
10. **Don't commit secrets** (`.p8` keys, ASC API keys, RevenueCat keys). Use `wrangler secret put` for Worker. Local dev: `.env.local` (gitignored). Apps: `.xcconfig` (gitignored).
11. **Don't `codesign --deep`** the macOS app — breaks Sparkle's nested binary signatures.
12. **Don't use `create-dmg`** (npm) — no custom backgrounds. Use `LinusU/node-appdmg`.
13. **Never force-push to `main`.** Never rewrite published history.
14. **If something feels wrong or ambiguous, stop and ask.**

---

## 9. Session startup ritual

Run at the start of every new Claude Code session in this repo, before writing any code:

```bash
# 1. Pull latest
git pull --rebase

# 2. Sync CodexBar reference (clone if missing, pull if present)
if [ ! -d /Users/nathanialhenniges/Developer/tmp/CodexBar ]; then
  mkdir -p /Users/nathanialhenniges/Developer/tmp
  git clone https://github.com/steipete/CodexBar.git /Users/nathanialhenniges/Developer/tmp/CodexBar
else
  git -C /Users/nathanialhenniges/Developer/tmp/CodexBar pull --rebase
fi

# 3. Bun workspaces up to date
bun install

# 4. Report which phase we're on
grep -n '^\- \[ \]' PHASES.md | head -5
```

Use CodexBar as a **read-only reference** for: Swift patterns (menu bar app structure, FSEvents, Sparkle integration), Claude OAuth credential handling, pace calculation algorithms, APNs + notification patterns, icon bundling, menu bar design cues. **Never copy CodexBar code verbatim.** Learn from it, don't copy it.

---

## 10. Environment + URLs

| Resource | URL / Value |
|---|---|
| Cloudflare Workers subdomain | `mrdemonwolf.workers.dev` |
| Worker (APNs relay) | `howlalert.mrdemonwolf.workers.dev` |
| Docs site (GitHub Pages) | `mrdemonwolf.github.io/howlalert` (served from `/docs` on `main`) |
| Admin dashboard | `howlalert-admin.pages.dev` (later: `admin.howlalert.app`) |
| macOS bundle ID | `com.mrdemonwolf.howlalert.mac` |
| iOS bundle ID | `com.mrdemonwolf.howlalert` |
| watchOS bundle ID | `com.mrdemonwolf.howlalert.watchkitapp` |
| CloudKit container | `iCloud.com.mrdemonwolf.howlalert` |
| App Group | `group.com.mrdemonwolf.howlalert` |
| Homebrew cask repo | `mrdemonwolf/homebrew-den` |
| App Store SKU (Pro) | `com.howlalert.pro.monthly` |
| App Store SKU (Max) | `com.howlalert.max.annual` |
| RevenueCat entitlement | `pro_features` |

---

## 11. When to ask the human

Ask first if:

- A task requires an Apple Developer portal action (App IDs, certs, APNs keys) — only Nathanial can do these.
- A task requires App Store Connect changes (products, pricing, metadata).
- A task requires a RevenueCat config change (webhook URLs, API keys).
- A task requires secrets to be added to GitHub Actions.
- A package outside the locked stack needs installing.
- A phase's acceptance criteria look unclear or contradictory.
- You'd need to push more than 50MB in a single commit.
- You'd delete any existing branch other than ephemeral feature branches.

Otherwise: proceed, commit, push, next phase.

---

## 12. Soft rules (push back if asked to violate)

- Prefer self-hosted + open-source over SaaS.
- TypeScript over JavaScript, always.
- Always write READMEs in MrDemonWolf house format — use the `mrdw-readme` skill.
- Run `audit-duplicates` skill before any refactor session.
- Apply the `gh-solo-main-protection` ruleset to all repo work.

---

## 13. Reference docs

- `PLAN.md` — architecture bible
- `PHASES.md` — Phases 0–4 with acceptance criteria + test instructions
- [Claude Code hooks](https://docs.claude.com/en/docs/claude-code/hooks)
- [WWDC25 219 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 278 — What's new in widgets](https://developer.apple.com/videos/play/wwdc2025/278/)
- [WWDC25 334 — What's new in watchOS 26](https://developer.apple.com/videos/play/wwdc2025/334/)
- [RevenueCat iOS setup](https://www.revenuecat.com/docs/getting-started/installation/ios)

---

## 14. How to start any session

When Nathanial opens a Claude Code session, he'll say something like "work on Phase 0 / HAA-15" or "we're scaffolding the Worker today". Your first response should:

1. Confirm which phase + ticket.
2. List the acceptance criteria from `PHASES.md`.
3. Propose a top-down task breakdown with checkboxes.
4. Ask any blocking questions before you start.

Don't dive into code on the first turn. **Plan, then build.**
