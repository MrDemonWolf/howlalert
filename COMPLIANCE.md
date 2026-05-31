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
  Terms §12 *"Use of our brand"* (verbatim): *"You may not, without our prior
  written permission, use our name, logos, or other trademarks in connection with
  products or services other than the Services, or in any other way that implies
  our affiliation, endorsement, or sponsorship. To seek permission, please email
  us at marketing@anthropic.com."* `CLAUDE` is a registered mark (USPTO Reg.
  #7645254). → add a non-affiliation disclaimer, keep "Claude Code" strictly
  descriptive (never in the app name/logo, never Anthropic logos), and **email
  marketing@anthropic.com for written permission.** ⚠️ **Action required.**
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

**Why the restrictions don't attach:** Consumer Terms §3 binds each "may not"
against *"our Services"* (Claude.ai/Pro/apps). HowlAlert performs zero network
calls to Anthropic — it parses files already on the user's machine and registers
an officially-supported hook. The user, not HowlAlert, is the party to those
terms, and isn't breaching them by viewing their own usage.

**Watch item:** Anthropic publicly *clarified a ban on third-party tools
accessing Claude* (The Register, 2026-02-20) and maintains
[Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms).
Those target tools that **connect to / drive the Services** — still N/A here
because HowlAlert never touches the Services — but re-check them before adding
any feature that talks to Anthropic (e.g. if you ever scrape limits from the API
like CodexBar does; CLAUDE.md explicitly says we don't).

**CodexBar precedent (researched 2026-05-30, v0.32.0).** CodexBar is **MIT**
(© Peter Steinberger), names "Claude" only as one provider in a 40-provider list
(not in its app name), ships **no** non-affiliation disclaimer, and — unlike
HowlAlert — **connects to Anthropic's API/OAuth** (the very access Anthropic
"clarified a ban on," The Register 2026-02-20). Takeaway: descriptive use of
"Claude" is common and so far untested, but precedent ≠ permission; HowlAlert's
local-only design is *more* conservative than CodexBar, and CodexBar's MIT license
is not a model for our GPLv3 choice.

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
| **LICENSE** | ✅ **GPLv3** (`LICENSE`) + Apple App-Store §7 additional permission + trademark reservation (README) | Done. Note: GPLv3 means anyone may fork/redistribute the code; brand is protected by trademark, not copyright |
| **Privacy policy + EULA + Disclaimer** | ✅ published as docs pages (`apps/docs/content/docs/legal/`), GitHub Pages → `https://mrdemonwolf.github.io/howlalert/docs/legal/{privacy,eula,disclaimer}` | Placeholders filled (MrDemonWolf, Inc., Beloit WI, WI law, legal@mrdemonwolf.com). Add the privacy URL to App Store Connect; confirm Beloit ZIP + SCC mechanism with counsel |
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
- [ ] Non-affiliation + trademark disclaimer — About screen ✅ (shipped); add to website + App Store description.
- [ ] Email marketing@anthropic.com for written brand permission / sign-off on "for Claude Code" usage.
- [x] `LICENSE` = **GPLv3** + Apple App-Store §7 additional permission + trademark reservation (README).
- [ ] Privacy policy + EULA drafted (`legal/`) — **fill placeholders + host at stable URLs**, link from app + site.
- [ ] **GPLv3 implications to confirm:** copyleft lets others redistribute the app free (brand stays yours); verify all bundled deps are GPL-compatible (Sparkle MIT ✅, RevenueCat MIT ✅); keep the server's license decision separate (AGPL if you want network copyleft).

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
