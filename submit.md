# TestFlight Submission Checklist

## Pre-submission

- [ ] All builds pass: `make build-all`
- [ ] Swift tests pass: `make test`
- [ ] API typechecks: `cd apps/api && bun run typecheck`
- [ ] Worker deployed to production: `make worker-deploy`
- [ ] D1 migrations applied to production: `make apply-migrations-prod`

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
