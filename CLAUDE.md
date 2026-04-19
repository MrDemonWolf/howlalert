# CLAUDE.md

> **Read this file before doing anything in this repo.** These rules override any defaults.

---

## Who you are in this repo

You are Claude Code, acting as the primary developer on **HowlAlert** — a Claude Code usage monitor for the Apple ecosystem (macOS menu bar + iPhone + Apple Watch).

**Owner:** Nathanial Henniges ([MrDemonWolf, Inc.](https://mrdemonwolf.com))
**GitHub org:** `mrdemonwolf` · **Repo:** `mrdemonwolf/howlalert`
**Jira:** `mrdemonwolf.atlassian.net` · project key `HAA` · cloud ID `7566ead4-4eb1-467e-87cd-f187718109ab`

---

## Golden rules

1. **Read in this order:** this file → `PLAN.md` → `MVP1.md` (or `MVP2.md`) → `TODO.md`.
2. **Work one phase at a time.** Finish all tasks in the current phase before moving on. Do not skip ahead.
3. **Commit AND push at the end of every phase.** Conventional commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`). Push directly to `main` — this is a solo project with the "Solo Main Protection" ruleset; CI gates prevent bad pushes.
4. **Tick the corresponding checkboxes** in `MVP1.md` / `MVP2.md` / `TODO.md` as you complete them. Commit the updated markdown files *with* the phase's code commit.
5. **Ask before deviating** from the locked stack (`PLAN.md` §8) or installing anything new.
6. **Never implement `GeminiCLIProvider`** during MVP 1. Stub only. It's a MVP 2 deliverable.
7. **Cloudflare free tier is a hard constraint.** D1 is primary store. KV only for hot reads. Never design a feature that requires >1000 KV writes/day.
8. **Everything Opus 4.7 related is in scope for MVP 1** — model-aware pace math, `xhigh` effort tracking, new weekly limit label (`"Current week (Sonnet only)"` with legacy `"Opus"` fallback).
9. **If something feels wrong or ambiguous, stop and ask.** Better one clarifying message than an hour of wrong direction.

---

## Session startup ritual

Run this at the start of every new Claude Code session in this repo, before writing any code:

```bash
# 1. Pull the latest HowlAlert repo
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
grep -n '^\- \[ \]' MVP1.md | head -5 || grep -n '^\- \[ \]' MVP2.md | head -5
```

Use CodexBar as a **read-only reference** for:
- Swift patterns (menu bar app structure, FSEvents, Sparkle integration)
- Claude OAuth credential handling (`docs/claude.md` + `Sources/Providers/Claude/`)
- Gemini OAuth quota API approach (`docs/gemini.md` — needed for MVP 2)
- Pace calculation algorithms
- APNs + notification patterns (they don't have push, but their background refresh loop is useful)
- Icon bundling and menu bar design cues

**Never copy CodexBar code verbatim.** It's MIT-licensed so you legally could, but we want HowlAlert to have its own distinct implementation and style. Learn from it, don't copy it.

---

## Commit + push discipline

**Commit template:**

```
<type>(<scope>): <short imperative summary>

<optional body explaining why>

Phase: <N>
```

Examples:
- `feat(kit): provider protocol + model-aware pace math`
- `feat(macos): FSEvents watcher + popover UI`
- `ci: notarize + dmg + homebrew auto-pr`

**Push cadence:** push after every phase. If a phase takes multiple days, push WIP commits on a feature branch, but each completed phase lands on `main` with the TODO.md tickboxes updated.

**Never force-push to `main`.** Never rewrite published history.

---

## Environment + URLs

| Resource | URL / Value |
|---|---|
| Cloudflare Workers subdomain | `mrdemonwolf.workers.dev` |
| Worker (APNs relay) | `howlalert.mrdemonwolf.workers.dev` |
| Docs site (GitHub Pages) | `mrdemonwolf.github.io/howlalert` — served from `/docs` folder on `main` |
| Admin dashboard (MVP 2) | `howlalert-admin.pages.dev` *(or `admin.howlalert.app` if DNS set up)* |
| macOS bundle ID | `com.mrdemonwolf.howlalert.mac` |
| iOS bundle ID | `com.mrdemonwolf.howlalert` |
| watchOS bundle ID | `com.mrdemonwolf.howlalert.watchkitapp` |
| CloudKit container | `iCloud.com.mrdemonwolf.howlalert` |
| App Group | `group.com.mrdemonwolf.howlalert` |
| Homebrew cask repo | `mrdemonwolf/homebrew-den` |

---

## What lives where

```
howlalert/
├── CLAUDE.md          # ← this file (rules)
├── PLAN.md            # architecture + design decisions
├── MVP1.md            # Phases 0–10, ship to App Store
├── MVP2.md            # Phases 11–15, post-launch polish + Gemini
├── TODO.md            # master checklist incl. Nathanial's manual tasks
├── README.md          # repo front door
├── LICENSE            # MIT
├── .gitignore
├── apps/
│   ├── macos/         # SwiftUI menu bar
│   ├── ios/           # SwiftUI iOS
│   ├── watchos/       # SwiftUI watchOS companion
│   ├── worker/        # Hono on Cloudflare Workers
│   └── admin/         # Next.js on Cloudflare Pages (MVP 2)
├── packages/
│   ├── howlalert-kit/ # Swift Package — providers, pace math
│   ├── shared-types/  # TS types
│   └── config/        # shared tsconfig/eslint/prettier
├── docs/              # GitHub Pages source (Fumadocs or plain MkDocs)
├── assets/            # logo + icon spec
└── .github/workflows/
```

---

## When to ask the human

Ask first if:

- A task requires an Apple Developer portal action (App IDs, certs, APNs keys) — only Nathanial can do these
- A task requires App Store Connect changes (products, pricing, metadata)
- A task requires a RevenueCat config change (webhook URLs, API keys)
- A task requires secrets to be added to GitHub Actions
- A package outside the locked stack needs installing
- A phase's acceptance criteria look unclear or contradictory
- You'd need to push more than 50MB in a single commit
- You'd delete any existing branch other than ephemeral feature branches

Otherwise: proceed, commit, push, next phase.
