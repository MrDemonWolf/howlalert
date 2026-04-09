# howlalert-worker

Cloudflare Worker that serves as the stateless relay between the HowlAlert macOS app and Apple Push Notification service (APNs). It also exposes admin endpoints for config management and push log viewing.

## What this worker does

- `POST /api/push` — Receives usage data from the macOS app, signs an APNs JWT, delivers a push notification to the paired iOS/watchOS device, and appends a ring-buffer log entry.
- `GET /api/config` — Returns the current remote config (multiplier, plan limits, promo, off-peak schedule).
- `POST /api/config` — Admin-only. Updates the remote config stored in KV.
- `GET /api/push-log` — Admin-only. Returns the last 100 push log entries.
- `GET /api/push-log/stats` — Admin-only. Returns delivered/failed counts and success rate.
- `POST /api/auth/verify` — Verifies an admin token and sets an HttpOnly session cookie (24h JWT).

## Required secrets

Set each secret via the Wrangler CLI:

```sh
wrangler secret put ADMIN_AUTH_TOKEN   # shared secret for admin Bearer auth + JWT signing
wrangler secret put APNS_AUTH_KEY      # PKCS#8 PEM (.p8 file contents from Apple Developer)
wrangler secret put APNS_KEY_ID        # 10-char key ID from Apple Developer portal
wrangler secret put APNS_TEAM_ID       # 10-char team ID from Apple Developer portal
```

## KV namespace setup

```sh
# Create namespaces
wrangler kv namespace create HOWLALERT_CONFIG
wrangler kv namespace create HOWLALERT_PUSH_LOG

# Copy the returned IDs into wrangler.toml (replace REPLACE_WITH_REAL_ID)

# Preview namespaces for local dev
wrangler kv namespace create HOWLALERT_CONFIG --preview
wrangler kv namespace create HOWLALERT_PUSH_LOG --preview
```

## Local dev

```sh
# From repo root
bun install

# Start local worker (uses preview KV)
bun run dev --filter=@howlalert/worker

# Typecheck
bun run typecheck --filter=@howlalert/worker

# Tests
bun run test --filter=@howlalert/worker
```

## APNs notes

- The worker uses APNs token-based auth (`.p8` key), not certificate auth.
- The APNs JWT is signed fresh per request (valid 1h). For high-volume use, cache it in memory.
- APNs bundle ID: `com.mrdemonwolf.howlalert`
- Push log is a ring buffer capped at 100 entries stored as a single KV value.
