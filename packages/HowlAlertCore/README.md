# HowlAlertCore

Pure, testable usage engine — turns Claude Code's `~/.claude` JSONL transcripts
into the 5-hour-window snapshot the apps render. No UI, no I/O side effects
beyond reading text; imported by `apps/desktop` (and later `apps/mobile`).

- Platforms: **macOS 26 / iOS 26 / watchOS 26** only.
- Patterns for JSONL parsing/dedupe studied from CodexBar (MIT) — reimplemented,
  not copied. The 5-hour window math and P90 limit detection are net-new
  (CodexBar scrapes those from Anthropic's API/CLI; HowlAlert derives them from
  local transcripts).

## Pieces

- `UsageEvent` — one assistant turn's token usage.
- `ClaudeTranscriptParser` — JSONL line → `UsageEvent`; dedupe by
  `messageId:requestId` (last chunk wins; parent beats subagent).
- `FiveHourWindow` — first-activity-anchored 5h blocks, gap-split > 5h.
- `PlanLimitEstimator` + `Percentile` — P90 of completed-window totals; remote
  `limits.json` override; config-supplied fallback (no hard-coded limit).
- `UsageEngine.snapshot(...)` → `UsageSnapshot` (used %, resets-at, state,
  burn-rate run-out projection).

## Test

```bash
cd packages/HowlAlertCore && swift test
```

See HAA-123. Live file watching = HAA-121; UI binding + Demo Mode = HAA-124.
