# HowlAlert — Compliance Audit (Apple + Anthropic)

> Audit date 2026-05-30. Covers Apple developer rules (App Store Review Guidelines,
> HIG, notarization/privacy) and Anthropic/Claude Terms of Service. **Not legal
> advice** — the trademark item below should be run past counsel before launch.

## TL;DR verdict

- **Anthropic ToS — core mechanism is compliant.** HowlAlert reads the user's
  *own local* `~/.claude` transcript files and uses Claude Code's *documented*
  hooks feature. It never connects to Anthropic's Services, so the restrictions
  on scraping / automated access / reverse-engineering / rate-limit circumvention
  **do not attach**. ✅
- **One real Anthropic risk: trademark use of "Claude / Claude Code."** Consumer
  Terms: *"You may not use our name, logos, or trademarks without our prior
  written consent."* `CLAUDE` is a registered mark (USPTO Reg. #7645254). → add a
  non-affiliation disclaimer, keep "Claude Code" strictly descriptive (never in
  the app name/logo, never Anthropic logos), and consider requesting written
  permission. ⚠️ **Action required.**
- **Apple — desktop (notarized DMG) has a few hygiene gaps**; the **mobile App
  Store app (not built yet) has a bake-in checklist** (IAP disclosures, privacy
  manifest, account deletion, metadata/trademark). No blockers in current code.

---

## 1. Anthropic / Claude Terms of Service

Sources: [Consumer Terms of Service](https://www.anthropic.com/legal/consumer-terms),
[Usage Policy](https://www.anthropic.com/legal/aup),
[Claude Code hooks docs](https://code.claude.com/docs/en/hooks-guide).
(API/Commercial Terms don't apply — HowlAlert uses no API key.)

Consumer Terms §"Restrictions" — you may not: (C) reverse engineer/decompile the
**Services** or discover source/algorithms; (D) access the **Services** through
automated/non-human means; (E) use data mining/robots/extraction methods; (F)
build a competing product or train a competing model; and you may not circumvent
rate limits. Plus: *"You may not use our name, logos, or trademarks without our
prior written consent."*

| Concern | Clause | HowlAlert | Verdict |
|---|---|---|---|
| Reverse-engineering Claude | (C) | Reads local JSONL Claude Code wrote to disk; doesn't touch Anthropic source/algorithms | ✅ clear |
| Automated access to Services | (D) | **Never connects to Anthropic.** No API, no web scrape (unlike CodexBar, which scrapes the API). Local files only | ✅ clear |
| Data mining / extraction | (E) | Targets "the Services" (Anthropic servers). Reading your own local disk ≠ scraping a service | ✅ clear |
| Competing product / model | (F) | A usage meter, not an AI model or competitor | ✅ clear |
| Circumventing rate limits | Usage Policy | Displays usage to help users *stay within* limits; bypasses nothing | ✅ clear |
| Using Claude outputs | Ownership | Reads token counts/metadata; transcript content never leaves the device, never redistributed | ✅ clear |
| **Trademark "Claude"** | name/logo clause | Uses "Claude Code" in UI + marketing; `CLAUDE` is registered | ⚠️ **action** |

**Why the restrictions don't attach:** (C)–(F) and the rate-limit clause all bind
behavior against *"the Services"* (Anthropic's API/apps/site). HowlAlert performs
zero network calls to Anthropic — it parses files already on the user's machine
and registers an officially-supported hook. The user, not HowlAlert, is the party
to those terms, and the user isn't breaching them by viewing their own usage.

**Trademark — required actions (not legal advice):**
1. Add a prominent **"Not affiliated with or endorsed by Anthropic. Claude and
   Claude Code are trademarks of Anthropic, PBC."** disclaimer (About screen,
   website footer, App Store description). *(Disclaimer shipped to the desktop
   About tab — see below.)*
2. Keep "Claude Code" **descriptive only** ("usage monitor for Claude Code").
   Never put "Claude" in the app **name**, icon, or logo; never use Anthropic's
   wolf-free wordmark/logo.
3. Rely on **nominative fair use** (truthful reference to state compatibility),
   but because the contract says "no use without written consent," **email
   Anthropic for written permission / brand sign-off before launch.**
4. Have counsel review #1–#3 before App Store submission and DMG release.

---

## 2. Apple — desktop app (`apps/desktop`, Developer ID + notarized DMG, Homebrew)

Not App Store-distributed, so App Store *Review* Guidelines don't gate it, but
Gatekeeper/notarization rules and basic legal hygiene do.

| Item | Status | Action |
|---|---|---|
| Hardened Runtime | ✅ `ENABLE_HARDENED_RUNTIME = YES` | — |
| Notarization / Developer ID | planned (HAA-125) | Don't `codesign --deep` (breaks Sparkle); notarize the DMG |
| App Sandbox | off (no `ENABLE_APP_SANDBOX`) | Correct — needed to read `~/.claude` for a non-MAS app. Document the choice |
| Reads `~/.claude` | ✅ home root (not a TCC-protected folder like Desktop/Documents) → no entitlement/prompt needed | If ever sandboxed/MAS: needs user-selected-file access + security-scoped bookmark |
| Local notifications | ✅ runtime authorization requested | — |
| Writes `~/.claude/settings.json` | ✅ opt-in toggle, backup + atomic write, refuses malformed | — |
| **`PrivacyInfo.xcprivacy`** | ❌ none | Not required for notarized DMG, but add before any MAS build; `UserDefaults` is a "required-reason API" |
| **LICENSE** | ❌ none (CLAUDE.md notes "TBD") | Choose + add (paid app → likely proprietary/all-rights-reserved, *decision needed*) |
| **Privacy policy + EULA** | ❌ none in product/docs | Publish a privacy policy (reads transcripts locally; sends push; CloudKit). Link from app + site |
| `LSUIElement`, version/copyright keys | verify in generated Info.plist | Confirm `LSUIElement=YES`, `CFBundleShortVersionString`, `NSHumanReadableCopyright` |

## 3. Apple — mobile app (`apps/mobile`, **not built yet** — bake in before submission)

App Store Review Guidelines that will apply to the paid iOS/watchOS app:

- **3.1.1 / 3.1.2 In-App Purchase** — Pro/Max subscriptions must use IAP
  (RevenueCat → StoreKit ✅ planned). The paywall **must** show: subscription
  title, length, price per period, "auto-renews unless cancelled," and functional
  links to **Terms (EULA)** and **Privacy Policy**. CTA "Start 7-day free trial"
  with clear auto-renew terms. (Matches CLAUDE.md pricing rules.)
- **5.1.1(v) Account Deletion** — if the app creates an account (pairing /
  better-auth), it must offer **in-app account deletion**, not just disable.
- **5.1.1 / 5.1.2 Privacy** — accurate privacy nutrition labels +
  `PrivacyInfo.xcprivacy`. Declare: device token (Identifiers, linked to push),
  pairing HMAC. State transcript content stays on-device (not collected).
- **5.2.1 / 5.2.5 Intellectual Property** — same "Claude" trademark concern in
  app **name/subtitle/keywords/screenshots**. Use "for Claude Code"
  descriptively + disclaimer; Apple can reject for third-party marks used to
  imply affiliation.
- **2.1 / 2.3** — accurate metadata; demo/Demo-Mode acceptable for review.
- **4.x** — native Swift (✅), no private APIs.

## 4. HIG / brand (both platforms)

- Liquid Glass on navigation layer only (✅ `PopoverShell` glass; content cards
  solid navy). Menu-bar conventions (✅). No emojis in product UI (✅). Native
  controls in Settings (✅). AA contrast tokens (✅ `ink-500 = #9AA9C5`).

---

## 5. Prioritized actions

**Do before launch (Blocker-ish):**
- [ ] Non-affiliation + trademark disclaimer — About screen ✅ (shipped), website, App Store description.
- [ ] Email Anthropic for written brand permission / sign-off on "for Claude Code" usage.
- [ ] Choose + add a `LICENSE`. *(Decision: proprietary vs source-available.)*
- [ ] Publish a privacy policy + EULA; link from app + site.

**Before mobile App Store submission:**
- [ ] Paywall IAP disclosures (3.1.2) + Terms/Privacy links.
- [ ] In-app account deletion (5.1.1(v)) if accounts exist.
- [ ] `PrivacyInfo.xcprivacy` + accurate privacy nutrition labels.
- [ ] Trademark-safe App Store metadata (5.2.5).

**Hygiene / verify:**
- [ ] Confirm `LSUIElement`, version, copyright keys in the generated Info.plist.
- [ ] Counsel review of the trademark approach.
- [ ] Add `PrivacyInfo.xcprivacy` to desktop if it ever ships via MAS.

> Legal disclaimer: this audit is engineering due-diligence, not legal advice.
> Confirm the trademark and privacy items with a qualified attorney.
