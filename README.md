# HowlAlert 🐺

**Know your Claude Code limits. Everywhere.**

HowlAlert is a real-time Claude Code usage monitor for Mac, iPhone, and Apple Watch. Push alerts before you hit the wall. A tap on your wrist when Claude finishes replying.

## Features

- Live token usage tracking across multiple Macs
- "Pace" insights: on track, in debt, or in reserve
- Dynamic Island support on iPhone
- Apple Watch complications
- "Claude is done" haptic alerts
- Zero accounts — syncs via your iCloud

## System Requirements

- macOS 15+ on Apple Silicon (M-series)
- iOS 17+
- watchOS 10+

## Pricing

- **macOS:** Free (Developer ID notarized DMG)
- **iOS:** $3.99/month or $35.99/year with 7-day free trial

## Development

```bash
bun install
make dev-worker     # Start Hono dev server
make dev-docs       # Start Fumadocs dev server
make test-kit       # Run Swift tests
```

### Required Secrets (Worker)

- `APNS_TEAM_ID` — Apple Developer Team ID
- `APNS_KEY_ID` — APNs .p8 key identifier
- `APNS_SIGNING_KEY` — APNs .p8 private key contents
- `REVENUECAT_WEBHOOK_SECRET` — RevenueCat webhook auth secret

## License

MIT — © 2026 MrDemonWolf, Inc.

---

HowlAlert by MrDemonWolf, Inc. · [Website](https://mrdemonwolf.github.io/howlalert/) · [Support](mailto:support@mrdemonwolf.com)
