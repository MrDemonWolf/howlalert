# HowlAlert Desktop (macOS menu bar)

Xcode project — SwiftUI menu bar app (`LSUIElement = true`, no Dock icon).
Watches `~/.claude/` via FSEvents + Claude Code's Stop hook. Free; distributed
as a notarized DMG via Homebrew cask.

- Targets **macOS 26.0+** only — Liquid Glass is unconditional (no `@available`
  guards, no `.ultraThinMaterial` fallback).
- Imports `packages/HowlAlertUI` via a local Swift Package reference.

See HAA-77.
