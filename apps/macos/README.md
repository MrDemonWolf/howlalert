# HowlAlert Desktop (macOS menu bar)

Xcode project — SwiftUI menu bar app (`LSUIElement = true`, no Dock icon).
Watches `~/.claude/` via FSEvents + Claude Code's Stop hook. Free; distributed
as a notarized DMG via Homebrew cask.

- Targets **macOS 26.0+** only — Liquid Glass is unconditional (no `@available`
  guards, no `.ultraThinMaterial` fallback).
- Imports `packages/HowlAlertUI` via a local Swift Package reference.

## Phase 0 (HAA-119)

Scaffold only: `MenuBarExtra` (`.window` style) hosting `HowlAlertUI.DetailedPopover`
so the design system (HAA-118) can be QA'd against
`apps/docs/design-bundle/section-b-macos.html`. FSEvents / Stop hook / usage math
arrive in later tickets.

### Build & run

```bash
# build (use -scheme, NOT -target — -target won't resolve the SPM product)
xcodebuild -project HowlAlert.xcodeproj -scheme HowlAlert -configuration Debug \
  -destination 'platform=macOS' build
```

Or open `HowlAlert.xcodeproj` in Xcode 26 and run. The app lives in the menu bar
(no Dock icon); click the icon to show the popover.

### Headless pixel QA

Render `DetailedPopover` straight to a PNG via `ImageRenderer` — no menu-bar click:

```bash
APP="$(find ~/Library/Developer/Xcode/DerivedData -name HowlAlert -path '*/Debug/HowlAlert.app/Contents/MacOS/*' | head -1)"
HOWL_QA_RENDER=/tmp/popover.png "$APP"   # renders, writes PNG, exits
```

See HAA-77 / HAA-119.
