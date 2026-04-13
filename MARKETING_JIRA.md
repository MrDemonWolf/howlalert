# HowlAlert Marketing Jira Tickets

Copy these YAML blocks verbatim into Packrunner for Jira project HAA.

---

```yaml
- key: HAA-M1
  title: "App Store screenshots — iPhone 6.9\" (Pro Max)"
  labels: [marketing, assets, app-store]
  estimate: 2h
  description: |
    Generate 5 screenshots at 1320×2868 px PNG for iPhone 16 Pro Max class.
    Use Demo Mode on a real device or simulator. Device frame: Midnight iPhone 16 Pro Max.
    Captions baked into the image (not ASC text overlays) in SF Pro Display, white on navy #091533.
    
    Shot 1 — Dashboard stacked cards. Caption: "Know your Claude Code limits. Everywhere."
    Shot 2 — Dynamic Island expanded (🐺 + crit bar + runout). Caption: "Glance from the Island."
    Shot 3 — Active Macs card expanded showing 2 Macs. Caption: "Track every Mac you code on."
    Shot 4 — Lock screen with minimal push notification. Caption: "A tap before Claude cuts out."
    Shot 5 — Paywall view showing 7-day trial + monthly/annual. Caption: "Pro · $3.99/mo. Cancel anytime."
  acceptance:
    - All 5 PNGs exported at exactly 1320×2868
    - Dark mode only (navy background)
    - Uploaded to ASC iPhone 6.9" screenshot slots in order
    - Filed in repo at assets/screenshots/iphone-69/

- key: HAA-M2
  title: "App Store screenshots — iPhone 6.5\"/6.7\""
  labels: [marketing, assets, app-store]
  estimate: 1h
  description: |
    Same 5 compositions as HAA-M1, re-rendered at 1284×2778 px for iPhone 11 Pro Max / Plus sizes.
    Apple requires this size for legacy device coverage.
  acceptance:
    - All 5 PNGs at exactly 1284×2778
    - Uploaded to ASC
    - Filed at assets/screenshots/iphone-65/

- key: HAA-M3
  title: "App Store screenshots — Apple Watch"
  labels: [marketing, assets, app-store]
  estimate: 1h
  description: |
    Generate 3 screenshots at 410×502 px for Apple Watch Series 10 / Ultra 2.
    Shot 1 — Circular complication on Modular face (ring fill + wolf center)
    Shot 2 — Watch app foreground with crit bar + "Runs out in ~2h"
    Shot 3 — "Claude finished" notification on wrist
  acceptance:
    - 3 PNGs at 410×502 exactly
    - Uploaded to ASC Apple Watch slots
    - Filed at assets/screenshots/watch/

- key: HAA-M4
  title: "App Store preview video (30 sec)"
  labels: [marketing, assets, app-store]
  estimate: 3h
  description: |
    Record 15-30 sec 1080×1920 H.264 video (≤500MB per ASC limits).
    Storyboard:
    0:00-0:04 — macOS menu bar wolf icon pulsing amber (approaching limit)
    0:04-0:10 — iPhone lock screen: "🐺 85% used — runs out in ~2h"
    0:10-0:16 — Tap notification → dashboard with stacked cards + multi-Mac
    0:16-0:22 — Apple Watch complication update + haptic on "Claude finished"
    0:22-0:30 — Logo lockup: HowlAlert by MrDemonWolf, Inc. + "Download today"
    Use Demo Mode throughout (no real account data).
  acceptance:
    - Video 15-30 sec, 1080×1920, under 500MB
    - Uploaded to ASC preview slot
    - Filed at assets/preview.mp4

- key: HAA-M5
  title: "App Store Connect metadata — copy/paste ready"
  labels: [marketing, app-store, copy]
  estimate: 1h
  description: |
    App name (30 char limit): HowlAlert
    Subtitle (30 char limit): Claude Code usage monitor
    Seller: MrDemonWolf, Inc.
    Promotional text (170 chars): Your Claude Code usage, on every Apple device. Push alerts, Dynamic Island, Watch complications, multi-Mac sync. Built for developers who ship.
    Keywords (100 chars): claude,ai,tokens,usage,monitor,developer,anthropic,code,limit,watch,menu bar,sonnet,opus
    Description (paste verbatim):
    ---
    HowlAlert is the missing dashboard for Claude Code.

    Watch your token usage in real time across all your Macs. Get push notifications before you hit the wall. A tap on your wrist when Claude finishes replying. Everything syncs via your iCloud — no accounts, no logins.

    FEATURES
    • Live usage tracking across every paired Mac
    • "Pace" insights: on track, in debt, or in reserve
    • Dynamic Island support on iPhone 15 Pro and newer
    • Apple Watch complications on Modular and Infograph faces
    • "Claude is done" haptic alerts on your wrist
    • Minimal, wolf-themed interface in deep navy and cyan

    SYSTEM REQUIREMENTS
    • macOS 15 or later on Apple Silicon
    • iOS 17 or later
    • watchOS 10 or later
    • Active Anthropic Claude Code subscription

    SUBSCRIPTION
    HowlAlert Pro: $3.99/month or $35.99/year (save 25%). 7-day free trial.
    Payment charged to Apple ID at confirmation of purchase. Auto-renews unless cancelled 24 hours before period ends. Manage and cancel in Settings.

    Privacy Policy: https://mrdemonwolf.github.io/howlalert/legal/privacy
    Terms of Use (EULA): https://mrdemonwolf.github.io/howlalert/legal/terms

    © 2026 MrDemonWolf, Inc. Made in Wisconsin. 🐺
    ---
    Support URL: https://mrdemonwolf.github.io/howlalert/support
    Marketing URL: https://mrdemonwolf.github.io/howlalert/
    Privacy URL: https://mrdemonwolf.github.io/howlalert/legal/privacy
    Category: Primary = Developer Tools, Secondary = Utilities
    Age Rating: 4+
    Copyright: © 2026 MrDemonWolf, Inc.
  acceptance:
    - All fields entered in ASC exactly as above
    - Description under 4000 chars
    - Keywords under 100 chars

- key: HAA-M6
  title: "Subscription product localized names + disclosure"
  labels: [marketing, app-store, monetization]
  estimate: 30m
  description: |
    In ASC > Subscriptions, set for product com.howlalert.monthly:
      Display name: HowlAlert Pro Monthly
      Description: Real-time Claude Code monitoring with push alerts, Apple Watch complications, and multi-Mac sync. 7-day free trial.
    For com.howlalert.annual:
      Display name: HowlAlert Pro Annual
      Description: Full year of HowlAlert Pro. Save 25% vs monthly. 7-day free trial.
    
    In app description + paywall, include exactly:
    "Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is cancelled at least 24 hours before the end of the current period. Manage or cancel subscriptions in your App Store account settings."
  acceptance:
    - Both products localized in English
    - Auto-renewal disclosure shown in paywall view + app description
    - Privacy Policy + EULA links above Subscribe button

- key: HAA-M7
  title: "App Review Notes document"
  labels: [marketing, compliance, app-store]
  estimate: 1h
  description: |
    Create apps/ios/APP_REVIEW_NOTES.md with the following content verbatim:
    ---
    HowlAlert by MrDemonWolf, Inc.

    REVIEWER: You do not need a Mac to test this app. Please follow these steps:
    
    1. Open HowlAlert on the test device. On the empty state, tap "Try Demo Mode."
    2. Demo Mode runs a 60-second simulation cycling through all 4 usage states
       (on track, approaching, limit hit, reset) with fake push notifications,
       Dynamic Island Live Activity, and Apple Watch haptic feedback.
    3. To test the paywall: Settings → Subscription → Upgrade. Use sandbox tester
       account provided in ASC. The 7-day free trial will auto-start.
    4. To test Apple Watch: Demo Mode auto-enables on paired Watch. Check the
       circular complication on any watch face.
    
    PAIRING: HowlAlert uses CloudKit private database for automatic pairing
    between the user's own Apple devices. No login or account creation is required.
    The macOS companion app (distributed outside the App Store) writes usage data
    to the user's own iCloud. No data is shared with MrDemonWolf, Inc. or any third party.
    
    DATA COLLECTION: Push notification tokens only (for APNs delivery).
    RevenueCat handles subscription validation. No analytics, no tracking.
    
    Contact for questions: support@mrdemonwolf.com
    ---
  acceptance:
    - File created at apps/ios/APP_REVIEW_NOTES.md
    - Pasted verbatim into ASC App Review Notes field
    - Sandbox tester account noted in ASC with working test trial

- key: HAA-M8
  title: "App Privacy Nutrition Label (ASC)"
  labels: [marketing, compliance, app-store]
  estimate: 30m
  description: |
    In ASC > App Privacy, declare:
    
    DATA COLLECTED — Device ID
      Used for: App Functionality (push notification delivery only)
      Linked to user: No
      Used for tracking: No
    
    DATA COLLECTED — Purchase History
      Used for: App Functionality (RevenueCat subscription validation)
      Linked to user: No (pseudonymous RevenueCat appUserID = CloudKit user ID)
      Used for tracking: No
    
    ALL OTHER categories: Data Not Collected.
    
    Third parties: RevenueCat (purchase validation), Apple APNs (push delivery).
    No analytics SDKs, no crash reporting SDKs that collect PII.
  acceptance:
    - All sections completed accurately in ASC
    - No "contact info" or "identifiers" other than pseudonymous device ID
    - Ready for submission

- key: HAA-M9
  title: "App icon assets (all required sizes)"
  labels: [marketing, assets, design]
  estimate: 3h
  description: |
    Design wolf-head icon in brand cyan #0FACED on navy #091533.
    Style: bold, silhouetted, minimal, works at 16px AND 1024px.
    
    Export required sizes:
    
    iOS (in Assets.xcassets/AppIcon.appiconset):
      1024×1024 (App Store)
      180×180 (iPhone @3x)
      120×120 (iPhone @2x)
      167×167 (iPad Pro)
      152×152 (iPad @2x)
      76×76 (iPad @1x)
    
    watchOS (Assets.xcassets/AppIcon.appiconset):
      1024×1024 (App Store)
      216×216, 172×172, 100×100, 102×102, 92×92, 80×80, 55×55, 48×48, 44×44, 24×24
    
    macOS (Assets.xcassets/AppIcon.appiconset):
      1024×1024, 512×512, 256×256, 128×128, 64×64, 32×32, 16×16 (all @1x AND @2x)
    
    Menu bar symbol (template mode, monochrome):
      16×16 @1x, 32×32 @2x, 48×48 @3x — SVG source
  acceptance:
    - All sizes exported to correct Assets.xcassets locations
    - App icon looks crisp at 16px and 1024px
    - Template menu bar icon tints correctly in light/dark mode

- key: HAA-M11
  title: "Product Hunt launch assets"
  labels: [marketing, launch]
  estimate: 2h
  description: |
    Schedule launch 2 weeks after public App Store approval (Tuesday 12:01am PT = best slot).
    
    Tagline (60 chars): Your Claude Code usage, on every Apple device 🐺
    Description (260 chars):
      HowlAlert is the missing dashboard for Claude Code. Push alerts before you hit the limit, Dynamic Island support, Apple Watch complications, and multi-Mac sync — all without a single login. Made by a developer, for developers.
    
    Gallery (5 images in order):
      1. Hero shot — iPhone dashboard + Mac menu bar + Watch complication
      2. Dynamic Island Live Activity
      3. Active Macs card (multi-device pitch)
      4. Lock screen push notification
      5. Paywall with trial
    
    Topics: Developer Tools, Productivity, iOS, macOS, Apple Watch
    Makers: Nathanial Henniges (MrDemonWolf, Inc.)
  acceptance:
    - PH page drafted and scheduled
    - Hunter arranged if possible
    - 3+ makers tagged

- key: HAA-M12
  title: "Launch tweet thread (8 tweets)"
  labels: [marketing, launch, social]
  estimate: 1h
  description: |
    1/ After burning through my Claude Code Max limits mid-PR for the hundredth time, I built the tool I wished existed.
    
    Meet HowlAlert 🐺 — your Claude Code usage, on every Apple device.
    
    Launching today. Here's what it does 👇
    
    2/ [screen recording of Dynamic Island updating during a Claude session]
    Live usage tracking on iPhone Dynamic Island. Know your limits at a glance without switching apps.
    
    3/ [Watch complication GIF]
    Apple Watch complications on Modular and Infograph. A haptic tap the moment Claude finishes replying. No more polling your terminal.
    
    4/ [multi-Mac screenshot]
    Run Claude on multiple Macs? HowlAlert aggregates usage across all of them. Because Anthropic's rate limits are per-account, not per-machine — and you deserve accurate pace math.
    
    5/ [pace in-debt screenshot]
    "Pace" math tells you when you're burning too fast. "12% in debt, runs out in ~2h" hits different than a raw percentage.
    
    6/ [architecture diagram]
    Zero accounts. Zero logins. Your data stays in your own iCloud private DB. The Cloudflare Worker only relays pushes — it stores nothing.
    
    7/ $3.99/mo or $35.99/yr with a 7-day free trial.
    Requires Apple Silicon + macOS 15 / iOS 17.
    
    Download: [App Store link]
    macOS companion: [GitHub release link]
    
    8/ Built solo over 2 weeks by @MrDemonWolf. If this saves you one blown session, it paid for itself.
    
    Tag a dev who maxes out Claude 👇
  acceptance:
    - All 8 tweets drafted in Twitter scheduler
    - 3 visuals + 1 screen recording prepared
    - Scheduled for launch day 9am PT

- key: HAA-M13
  title: "r/ClaudeCode + HackerNews + r/ClaudeAI posts"
  labels: [marketing, launch, community]
  estimate: 2h
  description: |
    r/ClaudeCode title: "I built an iOS + Watch app to monitor Claude Code usage across all my Macs"
    
    HN Show HN title: "Show HN: HowlAlert – Claude Code usage monitor for iPhone, Watch, and Mac"
    
    r/ClaudeAI title: "Finally stopped hitting Claude Code limits mid-session — built a wrist-alert app"
    
    All three posts: Lead with the problem (limits hit mid-session), show the solution with a 15-sec GIF, link to landing page. NO hard pitch on price. Mention Demo Mode for people who want to try without subscribing.
    
    Reply policy: answer every top-50 comment within 6 hours of launch.
  acceptance:
    - All three posts drafted with GIF embeds ready
    - Landing page has Show HN / Reddit UTM params ready
    - Claude Discord channel post prepared separately

- key: HAA-M14
  title: "ccusage integration outreach"
  labels: [marketing, partnerships]
  estimate: 30m
  description: |
    Open GitHub issue on ryoppippi/ccusage titled: "GUI companion for mobile/watch — would you link HowlAlert?"
    
    Body:
    "Hey @ryoppippi — built HowlAlert (iOS/watchOS/macOS usage monitor for Claude Code) that complements ccusage nicely. Same JSONL parsing approach but adds push notifications, Dynamic Island, and Watch complications.
    
    Would you consider adding a 'Mobile companion' link in ccusage README pointing to HowlAlert? Happy to add reciprocal link in our docs pointing to ccusage as the CLI option. Mutual benefit — you stay the de-facto CLI, we handle the Apple-device layer.
    
    Landing: https://mrdemonwolf.github.io/howlalert/
    
    Cheers, Nathanial / MrDemonWolf, Inc."
  acceptance:
    - Issue opened respectfully
    - Reciprocal link prepared for our docs in case they say yes

- key: HAA-M15
  title: "Newsletter pitches (dev-focused)"
  labels: [marketing, launch, outreach]
  estimate: 1h
  description: |
    Email these newsletters 7 days before public App Store launch:
      - The Pragmatic Engineer (Gergely Orosz) — gergely@pragmaticengineer.com
      - iOS Dev Weekly (Dave Verwer) — hi@iosdevweekly.com
      - Swift Weekly Brief — natasha@natashatherobot.com
      - Bytes (Tyler McGinnis) — tyler@bytes.dev
      - JavaScript Weekly — peter@cooperpress.com (less relevant but large list)
    
    Pitch template:
    Subject: HowlAlert — first iOS/watchOS app for Claude Code usage
    Body:
    "Hi [name], quick pitch for the next issue.
    
    HowlAlert (launching [date]) is the first iPhone + Apple Watch app for monitoring Claude Code usage. Native Swift, no logins, syncs via iCloud. Built solo in 2 weeks over the gap that ccusage (12k GitHub stars) left wide open: mobile + watch.
    
    Would love a mention if it fits. Happy to provide early TestFlight access, exclusive screenshots, or a short written blurb you can excerpt. Pricing is $3.99/mo with a 7-day trial — so an easy 'try it' for your readers.
    
    Landing: https://mrdemonwolf.github.io/howlalert/
    
    Thanks, Nathanial / MrDemonWolf, Inc."
  acceptance:
    - 5+ emails sent 1 week before launch
    - Replies tracked in spreadsheet
```
