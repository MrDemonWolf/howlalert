# Manual Steps Required Before Ship

These cannot be automated — they require portal access and real credentials.

## 1. Apple Developer Portal

- [ ] Create App IDs for all three bundle IDs:
  - `com.mrdemonwolf.howlalert` (iOS)
  - `com.mrdemonwolf.howlalert.watchkitapp` (watchOS)
  - `com.mrdemonwolf.howlalert.mac` (macOS)
- [ ] Enable capabilities: Push Notifications, CloudKit, App Groups on each
- [ ] Generate APNs Authentication Key (.p8) — one key covers all three apps
- [ ] Note the Key ID and Team ID
- [ ] Create provisioning profiles for each target

## 2. App Store Connect

- [ ] Create app record for HowlAlert (iOS + watchOS)
- [ ] Set up subscription products:
  - `com.howlalert.monthly` — $3.99/month, 7-day trial
  - `com.howlalert.annual` — $35.99/year, 7-day trial
- [ ] Create subscription group "HowlAlert Pro"
- [ ] Complete tax and banking setup for MrDemonWolf, Inc.
- [ ] Add sandbox tester account for App Review
- [ ] Fill in App Privacy (see MARKETING_JIRA.md HAA-M8)

## 3. RevenueCat

- [ ] Create project "HowlAlert"
- [ ] Upload APNs .p8 key
- [ ] Create entitlement "pro"
- [ ] Create offering "default" with monthly + annual packages
- [ ] Set webhook URL to `https://howlalert-worker.workers.dev/entitlement/sync`
- [ ] Set webhook auth header to match REVENUECAT_WEBHOOK_SECRET
- [ ] Note the RevenueCat API key for iOS SDK initialization

## 4. Cloudflare

- [ ] Create D1 database "howlalert-db"
- [ ] Create KV namespaces: HOWLALERT_DEVICES, HOWLALERT_PUSH_LOG
- [ ] Update wrangler.toml with real IDs
- [ ] Set secrets:
  ```bash
  wrangler secret put APNS_TEAM_ID
  wrangler secret put APNS_KEY_ID
  wrangler secret put APNS_SIGNING_KEY  # paste .p8 contents
  wrangler secret put REVENUECAT_WEBHOOK_SECRET
  wrangler secret put ADMIN_SECRET
  ```
- [ ] Run initial D1 migration: `bun run db:push`
- [ ] Deploy: `make deploy-worker`

## 5. GitHub

- [ ] Enable GitHub Pages on the repo (source: GitHub Actions)
- [ ] Enable GitHub Actions
- [ ] Set repository secrets for release workflow:
  - `APPLE_ID`
  - `APPLE_APP_SPECIFIC_PASSWORD`
  - `APPLE_TEAM_ID`
  - `CERTIFICATE_BASE64`
  - `CERTIFICATE_PASSWORD`
  - `KEYCHAIN_PASSWORD`
  - `HOMEBREW_DEN_TOKEN`
  - `SPARKLE_PRIVATE_KEY`
- [ ] Create initial Cask in mrdemonwolf/homebrew-den (copy HOMEBREW_CASK.rb)

## 6. Sparkle

- [ ] Generate EdDSA key pair: `./bin/generate_keys`
- [ ] Store public key in macOS Info.plist (SUPublicEDKey)
- [ ] Store private key in 1Password + GitHub secret SPARKLE_PRIVATE_KEY

## 7. First Release

- [ ] `git tag v0.1.0-beta && git push --tags`
- [ ] Verify GitHub Action builds + notarizes + uploads DMG
- [ ] Verify homebrew-den gets auto-PR
- [ ] Merge the PR
- [ ] Test: `brew install --cask mrdemonwolf/den/howlalert`
- [ ] Archive iOS+watchOS in Xcode → upload to ASC → TestFlight
- [ ] Submit for App Store review with Demo Mode notes
