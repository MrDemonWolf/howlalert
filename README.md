<p align="center">
  <img src="./assets/logo.svg" alt="HowlAlert" width="160" />
</p>

<h1 align="center">HowlAlert</h1>

<p align="center">
  <b>Claude Code usage monitor for the Apple ecosystem.</b><br/>
  Never hit a rate limit mid-session again.
</p>

<p align="center">
  <a href="https://mrdemonwolf.github.io/howlalert">Docs</a> ·
  <a href="https://howlalert.app">Website</a> ·
  <a href="./PLAN.md">Architecture</a> ·
  <a href="./TODO.md">Build checklist</a>
</p>

---

## What it does

HowlAlert watches your local Claude Code session files on macOS, calculates token burn pace, and pushes real-time alerts to your iPhone and Apple Watch when you're approaching a rate limit — or when Claude finishes replying.

- 🐺 **macOS menu bar app** — tiny wolf icon, live crit bar, zero Dock presence
- 📱 **iPhone app** — dashboard, history, Demo Mode, paywall
- ⌚ **Apple Watch** — complications + notification view
- 🔔 **Cross-device push** — JSONL write on Mac → banner on your phone in under 5 seconds
- 📊 **Pace tracking** — "X% in debt · runs out in 2h" so you slow down *before* the wall

## Supported providers

| Provider | MVP 1 | MVP 2 |
|---|---|---|
| Claude Code | ✅ Full | ✅ |
| Gemini CLI | 🔒 Protocol stub | ✅ Full |

Provider protocol designed once in MVP 1. Gemini slots in MVP 2 without a refactor.

## Architecture at a glance

```
 ┌──────────────┐       ┌───────────────────┐       ┌──────────┐
 │ macOS app    │──────▶│ Cloudflare Worker │──────▶│   APNs   │
 │ (FSEvents +  │       │ (stateless relay) │       └─────┬────┘
 │  JSONL tail) │       └─────────┬─────────┘             │
 └──────┬───────┘                 │                       ▼
        │                         │               ┌──────────────┐
        │ CloudKit private DB     │               │  iPhone app  │
        └────────────────────────▶│               │   (banner +  │
                                  │               │   dashboard) │
                                  │               └──────┬───────┘
                                  ▼                      │
                           ┌────────────┐                ▼
                           │    D1      │         ┌──────────────┐
                           │entitlements│         │ Apple Watch  │
                           └────────────┘         │(complication)│
                                                  └──────────────┘
```

No user accounts. No backend user data store. CloudKit + APNs only.

## For Claude Code

If you're Claude Code reading this repo: **start with [`CLAUDE.md`](./CLAUDE.md).**

## Built by

[MrDemonWolf, Inc.](https://mrdemonwolf.com) — web dev and hosting, Beloit, WI.

## License

MIT — see [`LICENSE`](./LICENSE).
