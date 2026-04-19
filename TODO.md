# TODO — Nathanial's side

> **This file tracks what only you can do.** Claude Code handles the code (via `MVP1.md` and `MVP2.md`).
> Work top-to-bottom. Tick as you go. Most blockers are in BLOCK 1 — knock those out first.

<p align="center">
  <img src="./assets/logo.svg" alt="HowlAlert" width="120" />
</p>

---

## 🎯 Ship target

**MVP 1** = macOS menu bar + iPhone + Apple Watch, Claude Code only, shipped to App Store + Homebrew.
Then **MVP 2** adds Gemini CLI, admin dashboard, widgets, Live Activity, charts.

One primary provider: **Claude Code**. Gemini slot stubbed in MVP 1, filled in MVP 2.

---

## 🟥 BLOCK 1 — Do these FIRST (you only, Claude Code can't)

These gate everything. Knock them out before you kick off Phase 0.

### Apple Developer

- [ ] Verify Apple Developer membership is paid + active for the year
- [ ] Enrolled in Apple Small Business Program (15% commission) — already in, just confirm
- [ ] App Store Connect access working from your dev machine
- [ ] Create 3 App IDs in the Developer portal:
  - [ ] `com.mrdemonwolf.howlalert.mac` (Developer ID, not App Store)
  - [ ] `com.mrdemonwolf.howlalert` (iOS + App Store)
  - [ ] `com.mrdemonwolf.howlalert.watchkitapp` (watchOS companion)
- [ ] Enable entitlements on all three: Push Notifications, iCloud (CloudKit), App Groups
- [ ] Create shared **App Group**: `group.com.mrdemonwolf.howlalert`
- [ ] Create shared **CloudKit container**: `iCloud.com.mrdemonwolf.howlalert`
- [ ] Generate **APNs Auth Key** (.p8) → save Key ID + Team ID
  - [ ] Save .p8 in 1Password secure note AND on an encrypted volume
- [ ] Generate **Developer ID Application** certificate (macOS signing)

### App Store Connect

- [ ] Create iOS app record: `HowlAlert` — primary language English, bundle `com.mrdemonwolf.howlalert`
- [ ] Create watchOS app entry (linked to iOS as companion)
- [ ] Add In-App Purchase products:
  - [ ] `howlalert_pro_monthly` — $3.99 — Auto-Renewable Subscription (Group: `HowlAlert Pro`)
  - [ ] `howlalert_pro_yearly` — $35.99 — same group
  - [ ] 7-day free trial as Introductory Offer on both
- [ ] Tax + banking info complete (required before any purchase is possible)
- [ ] Privacy Policy URL live at `https://mrdemonwolf.com/howlalert/privacy`
- [ ] Terms of Service URL live at `https://mrdemonwolf.com/howlalert/terms`
- [ ] Support URL live at `https://mrdemonwolf.github.io/howlalert/support` (or `howlalert.app/support`)

### Third-party accounts

- [ ] RevenueCat account + project `howlalert` provisioned
  - [ ] Connect App Store Connect shared secret + In-App Purchase Key
  - [ ] Add both subscription products to `pro` entitlement
  - [ ] Create offering `default` with monthly + yearly packages
  - [ ] Save Public API Key for iOS SDK
  - [ ] Webhook URL pointed at `https://howlalert.mrdemonwolf.workers.dev/webhooks/revenuecat` (set up after Phase 1)
- [ ] Cloudflare account (you have one)
  - [ ] D1 database: `howlalert-entitlements`
  - [ ] KV namespaces: `HOWLALERT_CONFIG`, `HOWLALERT_DEVICE_TOKENS`, `HOWLALERT_PUSH_LOG`
  - [ ] Worker will deploy to `howlalert.mrdemonwolf.workers.dev` — no custom DNS needed
- [ ] GitHub repo `mrdemonwolf/howlalert` exists + has "Solo Main Protection" ruleset applied
- [ ] GitHub Pages enabled in repo Settings: source `/docs` on `main` → will serve at `mrdemonwolf.github.io/howlalert`
- [ ] GitHub Actions secrets:
  - [ ] `APPLE_ID` (your Apple ID email)
  - [ ] `APPLE_APP_SPECIFIC_PASSWORD`
  - [ ] `APPLE_TEAM_ID`
  - [ ] `DEVELOPER_ID_P12_BASE64` + `DEVELOPER_ID_P12_PASSWORD`
  - [ ] `HOMEBREW_DEN_DISPATCH_TOKEN` (PAT with `repo` scope for `mrdemonwolf/homebrew-den`)
  - [ ] `CLOUDFLARE_API_TOKEN` (Workers + Pages scope)

### Stuff on your Mac

- [ ] Xcode 16 or newer installed
- [ ] Command line tools: `xcode-select --install`
- [ ] Bun: `curl -fsSL https://bun.sh/install | bash`
- [ ] Wrangler: `bun add -g wrangler && wrangler login`
- [ ] Homebrew tap `mrdemonwolf/homebrew-den` exists (you use it for wolfwave — verify)
- [ ] `/Users/nathanialhenniges/Developer/tmp/` directory exists (Claude Code will clone CodexBar here)

---

## 🟧 BLOCK 2 — Kick off MVP 1

Once BLOCK 1 is done, in a fresh Claude Code session at the repo root:

> Read `CLAUDE.md`. Then read `PLAN.md`. Then read `MVP1.md`. Run the session startup ritual from `CLAUDE.md`. Execute Phase 0 in full. Tick the checkboxes in `MVP1.md` as you complete them. Commit AND push at phase end. Stop at Phase 0 completion. Do not continue to Phase 1 yet.

Then repeat that pattern for each subsequent phase:

> Read the current `MVP1.md`. Run Phase 1. Tick checkboxes. Commit and push.

When you feel confident, you can let Claude Code rip through multiple phases:

> Run Phase 1 through Phase 3 in sequence. Commit and push after each. Stop if anything requires my input.

---

## 🟧 BLOCK 3 — Monitor MVP 1 progress

Just keep an eye on:

- [ ] Phase 0 shipped — empty repo builds
- [ ] Phase 1 shipped — Worker live
- [ ] Phase 2 shipped — Swift Package tested
- [ ] Phase 3 shipped — Mac menu bar works
- [ ] Phase 4 shipped — iOS pairing works
- [ ] Phase 5 shipped — push pipeline end-to-end
- [ ] Phase 6 shipped — Watch complications
- [ ] Phase 7 shipped — RevenueCat + entitlement sync
- [ ] Phase 8 shipped — Demo Mode + App Review prep
- [ ] Phase 9 shipped — DMG + Homebrew cask
- [ ] Phase 10 shipped — TestFlight submitted

---

## 🟦 BLOCK 4 — Launch day checklist

Day of App Store approval:

- [ ] Mastodon post (with demo video)
- [ ] X / Twitter post
- [ ] Bluesky post
- [ ] Product Hunt submission (schedule for Tuesday 12:01am PT)
- [ ] Hacker News "Show HN" post ready — don't post same day as PH
- [ ] r/ClaudeAI post
- [ ] r/macapps post
- [ ] Landing page live at `howlalert.app`
- [ ] Demo video recorded (≤60s: JSONL write → phone banner → watch)
- [ ] Press kit in `assets/press/`: logo PNG, screenshots, 1-liner, 3-line pitch
- [ ] Email signature updated
- [ ] Pin repo on GitHub profile
- [ ] Save a dated snapshot of release build to `~/Archive/howlalert/v1.0.0/`

---

## 🟨 BLOCK 5 — Kick off MVP 2

Wait 14 days post-launch. Then:

> Read `CLAUDE.md`. Then read `MVP2.md`. Run the session startup ritual. Run Phase 11 — Gemini CLI provider. Use CodexBar at `/Users/nathanialhenniges/Developer/tmp/CodexBar` as reference. Tick checkboxes, commit, push.

Phase checkboxes:

- [ ] Phase 11 shipped — Gemini CLI provider
- [ ] Phase 12 shipped — Admin dashboard + remote limit multiplier
- [ ] Phase 13 shipped — Live Activity + Dynamic Island
- [ ] Phase 14 shipped — Widgets
- [ ] Phase 15 shipped — Historical pace charts
- [ ] Tag `v2.0.0` and publish via normal release pipeline

---

## 🟩 BLOCK 6 — Designer friend handoff

They own (from the existing `DESIGN_BRIEF.html`):

- [ ] App Store screenshots (you shoot raw from builds; designer frames + captions)
- [ ] Landing page hero image
- [ ] Product Hunt gallery images
- [ ] Short demo GIF
- [ ] App icon refinement (current wolf logo is the starting point — see `assets/logo.svg`)

---

## 🧰 References

| Thing | Where |
|---|---|
| Rules for Claude Code | `CLAUDE.md` |
| Architecture | `PLAN.md` |
| MVP 1 phases | `MVP1.md` |
| MVP 2 phases | `MVP2.md` |
| Logo | `assets/logo.svg`, `assets/logo-dark.svg`, `assets/logo-light.svg` |
| iOS icon spec | `assets/icon.json` |
| Reference repo layout | `github.com/mrdemonwolf/fangdash` |
| Reference usage monitor | `github.com/steipete/CodexBar` (cloned locally to `/Users/nathanialhenniges/Developer/tmp/CodexBar`) |
| Worker URL | `https://howlalert.mrdemonwolf.workers.dev` |
| Docs URL | `https://mrdemonwolf.github.io/howlalert` |
| CloudKit container | `iCloud.com.mrdemonwolf.howlalert` |
| App Group | `group.com.mrdemonwolf.howlalert` |
| Jira | HAA @ mrdemonwolf.atlassian.net, Cloud ID `7566ead4-4eb1-467e-87cd-f187718109ab` |
