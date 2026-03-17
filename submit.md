# TestFlight Submission Checklist

## Cloudflare Setup

Complete these steps before your first deployment. Skip if already configured.

### KV & D1

- [ ] Create KV namespace:
  ```sh
  wrangler kv:namespace create HOWLALERT_DEVICES
  ```
- [ ] Create D1 database:
  ```sh
  wrangler d1 create howlalert-db
  ```
- [ ] Update `apps/api/wrangler.toml` with the KV namespace ID and D1 database ID returned by the commands above

### APNs Secrets

- [ ] Set APNs Key ID:
  ```sh
  wrangler secret put APNS_KEY_ID
  ```
- [ ] Set APNs Team ID:
  ```sh
  wrangler secret put APNS_TEAM_ID
  ```
- [ ] Set APNs private key (paste the `.p8` contents):
  ```sh
  wrangler secret put APNS_PRIVATE_KEY
  ```
- [ ] Set APNs bundle ID:
  ```sh
  wrangler secret put APNS_BUNDLE_ID
  ```

### Deploy & Verify

- [ ] Apply D1 migrations to production: `make apply-migrations-prod`
- [ ] Deploy worker: `make worker-deploy`
- [ ] Verify health endpoint:
  ```sh
  curl https://your-worker.workers.dev/status
  ```

## Xcode Project Setup

- [x] App Group entitlement `group.com.mrdemonwolf.howlalert` added
- [ ] Create WidgetKit extension target for watchOS complications:
  1. File → New → Target → Widget Extension (watchOS)
  2. Name: `HowlAlertComplication`
  3. Bundle ID: `com.mrdemonwolf.howlalert.watchkitapp.complication`
  4. Add `HowlAlertKit` local package dependency to the new target
  5. Move `WatchComplication.swift` and `WatchRingView.swift` to the extension target
  6. Add App Group `group.com.mrdemonwolf.howlalert` to the extension's entitlements

## CI Workflows

- [x] GitHub Actions CI configured (`make ci`)
- [x] Typecheck, docs build, swift test all passing

## Pre-submission

- [ ] All builds pass: `make build-all`
- [ ] Swift tests pass: `make test`
- [ ] API typechecks: `cd apps/api && bun run typecheck`
- [ ] Worker deployed to production (see [Cloudflare Setup](#cloudflare-setup))
- [ ] D1 migrations applied to production (see [Cloudflare Setup](#cloudflare-setup))

## App Store Connect

- [ ] App Information filled (name, subtitle, category)
- [ ] Privacy Policy URL set (`https://howlalert.dev/docs/legal/privacy-policy`)
- [ ] App Privacy questionnaire completed (device token + usage data, linked to identity)
- [ ] Age Ratings configured (all None → 4+)
- [ ] App Accessibility features declared in review notes

## Build & Upload

- [ ] Increment version and build number in Xcode (target → General → Version/Build)
- [ ] Archive iOS build: **Product → Archive** in Xcode, select `howlalert (iOS)` scheme
- [ ] Archive macOS build: **Product → Archive** in Xcode, select `howlalert (macOS)` scheme
- [ ] Upload both archives to App Store Connect via **Xcode Organizer → Distribute App**
- [ ] Wait for processing (5–15 minutes; check App Store Connect → TestFlight)

## TestFlight

- [ ] Select builds in **TestFlight** tab for each platform
- [ ] Fill in **Test Information**: what to test, feedback email, test notes
- [ ] Add internal testers group (no review required)
- [ ] Submit for **Beta App Review** if external testers are needed (1–2 day review)

## Post-upload

- [ ] Verify TestFlight builds appear on test devices
- [ ] Test push notification flow end-to-end (trigger threshold → verify APNs delivery)
- [ ] Test threshold alerting for daily cost, token count, and session count types
- [ ] Verify watchOS companion installs correctly via Watch app pairing
- [ ] Verify macOS menu bar icon and usage widget display correctly
