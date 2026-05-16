# PLAN.md — HowlAlert Architecture Bible

> Architecture, contracts, and design decisions. Read after `CLAUDE.md`, before opening a phase in `PHASES.md`.

---

## 1. Product surfaces

| Surface | Distribution | Cost | Role |
|---|---|---|---|
| macOS menu-bar | Notarized DMG via Homebrew cask `mrdemonwolf/homebrew-den` | Free | Watches `~/.claude/`, computes usage, fires local + push notifications. |
| iOS app | App Store | Paid (HowlAlert Pro / Max) | Companion dashboard, push receiver, Live Activity, Dynamic Island, paywall host. |
| watchOS app | Bundled with iOS | Paid (entitlement passes through) | Complications, Smart Stack widget, glanceable usage. |
| Cloudflare Worker | `howlalert.mrdemonwolf.workers.dev` | Free tier | Stateless APNs relay. ~80 lines TS. Stores nothing. |

There is **no backend database.** All user state lives in CloudKit. The admin dashboard (`apps/admin`) is post-launch and reads from RevenueCat + Cloudflare analytics, not from any custom DB.

---

## 2. Storage model

- **CloudKit private database** is the source of truth for user state (pairings, preferences, history).
- **Pairing secret:** iPhone writes a shared secret into CloudKit on first launch. Mac reads it on next launch.
- **HMAC:** every Worker request is HMAC-SHA256 over the body, keyed by that shared secret. Worker verifies the HMAC, fires the APNs push, returns. No persistence.
- **No D1, no KV, no Durable Objects** except a single KV namespace dedicated to caching the APNs ES256 JWT (TTL 3000s).

---

## 3. Push pipeline

```
macOS app
  └─ threshold crossed (80% / 95% / reset)
      └─ POST howlalert.mrdemonwolf.workers.dev/push
          headers: X-HowlAlert-HMAC = HMAC_SHA256(body, sharedSecret)
          body: { deviceToken, payload }

Worker
  └─ verify HMAC
  └─ load APNs ES256 JWT from KV (mint + cache if expired)
  └─ HTTP/2 POST api.push.apple.com /3/device/<token>
  └─ return upstream status to client
```

- ES256 JWT: signed with APNs `.p8` key (loaded from `wrangler secret put APNS_KEY`). Cached in KV under `apns:jwt` with `expirationTtl: 3000`.
- Live Activity updates from the Worker are server-side throttled to **once every 2–5 minutes** during sustained usage to avoid APNs spam.

---

## 4. 5-hour window math

Claude Code's usage window is 5 hours from the first request, floored to the UTC hour.

```
windowStart = floor(firstRequestTime, hour)  // UTC
windowEnd   = windowStart + 5h
percent     = currentUsage / planLimit
```

- `planLimit` is **auto-detected via P90** over the last 30 days of completed windows. Never hard-coded.
- Fallback: remote `limits.json` published by the menu-bar app's update channel, used when local history is <7 windows.
- Edge cases (tested in `packages/howlalert-kit/Tests/`):
  - Window crosses midnight UTC.
  - First request inside an existing window (resume).
  - DST transitions (always UTC, never local).

---

## 5. Stop hook contract

Claude Code's Stop hook invokes our binary with the JSON event on stdin. Contract:

- **Input:** JSON on stdin (see [Claude Code hooks](https://docs.claude.com/en/docs/claude-code/hooks)).
- **Output:** exit 0 in <5s. Any non-zero exit blocks Claude Code's next step — we do not want this.
- **Side effects:** append to local SQLite history, broadcast to menu-bar app via Unix domain socket in App Group dir.
- Hook binary is bundled inside `HowlAlert.app/Contents/MacOS/HowlAlertHook` and installed to `~/.claude/hooks/` by the menu-bar app on first launch.

---

## 6. Claude Desktop input detection

Two paths, primary first:

1. **MCP server (`HowlAlert.mcpb`)** — preferred. Ships a `notify(title, body, urgency)` tool. When Claude Desktop invokes it, the MCP server POSTs to `http://127.0.0.1:NNNN/event` on the loopback. Port `NNNN` is randomly chosen by the menu-bar app at install and stored in the App Group container; the MCP server reads it on every call.
2. **Accessibility fallback** — `AXObserver` with `AXManualAccessibility = true`. **Do not** set `AXEnhancedUserInterface`. Opt-in only; gated behind a permission flow in Settings.

Phase 3 ships both.

---

## 7. RevenueCat integration

- **App User ID = CloudKit user record ID.** Call `Purchases.shared.logIn(cloudKitUserRecordID)` on every app launch after CloudKit pairing completes. This is required so that owner / beta / press lifetime grants work across reinstalls and devices.
- Both SKUs (`com.howlalert.pro.monthly`, `com.howlalert.max.annual`) live in the same App Store Connect subscription group.
- 7-day free trial = Introductory Offer (Free, 1 week, New subscribers). RevenueCat reads this automatically.
- Paywall is built in RevenueCat Dashboard's Paywall Editor (Hosted Paywall component) → remotely configurable, no app update needed for copy changes.
- Eligibility: call `checkTrialOrIntroDiscountEligibility` before showing the CTA.
- **Small Business Program** enrolled in App Store Connect AND flagged in RevenueCat Dashboard.
- Owner / beta / press: grant lifetime `pro_features` entitlement via RevenueCat Dashboard → Customers → find App User ID → Grant Entitlement → "Never expires".

---

## 8. Brand system

- **Colors:** navy `#091533` (bg), cyan `#0FACED` (accent), green `#3DDC97` (idle), amber `#FFA533` (warn), red `#FF4D4D` (crit).
- **Typography:** SF Pro everywhere. Match Apple system styles — no custom fonts.
- **Liquid Glass** is for navigation surfaces only — toolbars, popovers, floating CTAs, paywall background. Never on content cards.
- **Voice:** "watching" not "monitoring". Natural time strings ("Runs out in 47m"). No emojis. No exclamation points except for the `reset` notification.
- **Menu-bar icon states:** idle (cyan outline), warn (amber filled), crit (red filled). Each is a separate template PNG bundled in the app.

---

## 9. Hard rules (never violate)

- Don't hard-code Claude plan limits. P90 auto-detect + remote `limits.json`.
- Don't store user data on the Worker.
- Don't gate features differently between Pro and Max — same entitlement.
- Don't add a third paywall option. Pro monthly + Max annual + 7-day trial.
- Don't write tests after the fact for the 5h window math or JSONL parser — write them alongside.
- Don't commit `.p8` keys, ASC API keys, RevenueCat keys.
- Don't use `--deep` with `codesign` on the macOS app (breaks Sparkle).
- Don't use `create-dmg` (npm) — use `LinusU/node-appdmg`.

## 10. Soft rules (push back if asked to violate)

- Self-hosted + open-source over SaaS.
- TypeScript over JavaScript.
- READMEs in MrDemonWolf house format via the `mrdw-readme` skill.
- Run `audit-duplicates` before refactors.
- Apply `gh-solo-main-protection` ruleset to all repo work.

---

## 11. Reference URLs

- [Claude Code hooks](https://docs.claude.com/en/docs/claude-code/hooks)
- [WWDC25 219 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 278 — What's new in widgets](https://developer.apple.com/videos/play/wwdc2025/278/)
- [WWDC25 334 — What's new in watchOS 26](https://developer.apple.com/videos/play/wwdc2025/334/)
- [RevenueCat iOS setup](https://www.revenuecat.com/docs/getting-started/installation/ios)
- [Sparkle 2.x docs](https://sparkle-project.org/documentation/)
- [APNs HTTP/2 reference](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)
- [CloudKit private database](https://developer.apple.com/documentation/cloudkit/ckdatabase)
