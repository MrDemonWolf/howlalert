# HowlAlert — Design System Spec

> Readable reference for the HowlAlert design system. Two sources of truth:
> - **Visual** — `apps/docs/design-bundle/` (`design-system.html` + `section-b…h-*.html`). The mocks are canonical for layout/look.
> - **Code** — `packages/HowlAlertUI/Sources/HowlAlertUI/` (Swift tokens + components). Imported by `apps/desktop` and (later) `apps/mobile`.
>
> This `.md` mirrors those — if a value here disagrees with the Swift token or the HTML mock, the token/mock wins; fix this doc. Generated from `design-system.html` + the token files (2026-05-31).

---

## Color

All hex verified against `design-system.html :root` and `Tokens/HowlColor.swift`.

### Brand
| Token | Hex |
|---|---|
| `navy` | `#091533` |
| `cyan` | `#0FACED` |
| `green` | `#3DDC97` |

### Surfaces — navy ramp
| Token | Hex |
|---|---|
| `navy900` | `#060E24` |
| `navy800` | `#091533` |
| `navy700` | `#0E1F47` |
| `navy600` | `#16294F` |

### Ink (text)
| Token | Hex | Note |
|---|---|---|
| `ink100` | `#F5F8FF` | primary text |
| `ink300` | `#C7D2E6` | secondary text |
| `ink500` | `#9AA9C5` | muted — **AA-audited; never revert to `#6A7A99`** |

### State
| Token | Hex | Meaning |
|---|---|---|
| `stateFresh` | `#3DDC97` | just reset / plenty left |
| `stateWarn` | `#FFA533` | getting low |
| `stateCrit` | `#FF4D4D` | almost out |

`HowlState` → color: `fresh → green`, `normal → cyan`, `warn → amber`, `crit → red`.

### Accent + theme + glass
| Token | Hex / value |
|---|---|
| `cyan300` | `#5BC8F5` |
| `cyan100` | `#B8E6FB` |
| `cyanDeep` | `#0B86C2` |
| `lightInk500` | `#6A7A99` (light-theme variant only — **not** the dark `ink500`) |
| `lightSurface` | `#F5F8FF` |
| `glassNavy` | `#0B1A3A` @ 55% opacity |

---

## Spacing (`HowlSpacing`, pt)

4-pt step, `--space-1…10`.

| Token | pt | | Token | pt |
|---|---|---|---|---|
| `s1` | 4 | | `s6` | 24 |
| `s2` | 8 | | `s7` | 28 |
| `s3` | 12 | | `s8` | 32 |
| `s4` | 16 | | `s9` | 36 |
| `s5` | 20 | | `s10` | 40 |

Sub-token values (e.g. 2pt micro-gaps) appear in dense rows by design — not every literal maps to a token.

## Corner radius (`HowlRadius`, pt)

| Token | pt |
|---|---|
| `sm` | 6 |
| `md` | 10 |
| `lg` | 16 |
| `xl` | 24 |
| `pill` | 9999 (capsule) |

## Typography (`HowlTypography`)

SF Pro. 7-step semantic ramp for headings/labels; **numbers use `numeric(size:weight:)`** (tabular digits) so countdowns/percentages don't jitter.

| Token | size pt | weight |
|---|---|---|
| `display` | 34 | bold |
| `title` | 28 | semibold |
| `headline` | 20 | semibold |
| `body` | 16 | regular |
| `callout` | 14 | medium |
| `caption` | 12 | regular |
| `micro` | 10 | medium |
| `numeric(size:weight:)` | caller | `.semibold` default, `.monospacedDigit()` |

**Important — dense pixel ramp.** The HTML mocks use a denser native-macOS ramp than the 7-step enum (9 / 10 / 11 / 12 / 13 / 14 / 15 / 16 / 17 / 18 / 22 / 28 / 34 / 40 px; 13px dominant). The enum is for big semantic text; data-dense rows correctly use explicit `numeric(size:)` / `.system(size:)` matching the mock pixels. Those literals are faithful, not drift.

## Motion (`HowlMotion`)

"The wolf exhaling, not jumping."

| Token | Animation |
|---|---|
| `state` | `spring(response: 0.4, dampingFraction: 0.8)` — state changes |
| `bar` | `easeInOut(0.3)` — progress fills |
| `pulse` | `easeInOut(0.9).repeatForever(autoreverses:)` — last-minute / crit attention |
| `hover` | `easeOut(0.15)` — glass / hover micro-interaction |

---

## Liquid Glass

Unconditional (macOS 26 / iOS 26 / watchOS 26 only — no `@available` guards, no `.ultraThinMaterial` fallback). **Navigation layer only** — toolbars, popovers, floating CTAs. **Never on content cards** (those stay solid navy). Applied via `HowlGlass.howlGlass(_:in:)` + `HowlGlassGroup`.

## Components (`Components/*.swift`)

20 SwiftUI views, each mapping to a mock section. `PopoverData` is the data model (not a view).

| Component | Renders |
|---|---|
| `WolfMark` | brand wolf mark (full / glyph) |
| `UsageMeter` | depleting horizontal bar (h=8) + optional white pace marker — **not a ring** |
| `TwoBarMeter` | dual stacked bars |
| `CritBar` | large critical-state number + bar |
| `UsageRow` | label + trailing numeric value, state-colored |
| `ModelRow` | per-model usage row + sparkline |
| `PaceChip` | "racing the limit" pace pill (capsule) |
| `ResetCountdown` | reset time label; pulses last minute, glows on fresh |
| `StateIcon` | state SF Symbol (caller-sized) |
| `EmptyState` | icon + title + message (32pt decorative glyph) |
| `NotificationCard` | local-notification preview card |
| `MenuActionRow` | menu-bar action button (hover + ⌘ shortcut + tooltip) |
| `SettingsRow` | settings list row |
| `PopoverTabBar` | Overview / 5-Hour / Weekly / Models text-label tabs |
| `DetailedPopover` | full popover (header + tab panel + actions + footer) — data-driven via `PopoverData` |
| `PairingCard` | device-pairing code card (22pt mono code) |
| `PricingToggle` | Pro / Max paywall toggle |
| `CostSummary` | cost rollup |
| `HowlButtons` | primary / secondary / glass button styles |
| `HowlGlass` | `howlGlass` modifier + `HowlGlassGroup` |

## Voice & brand rules

- **"watching"**, never "monitoring" / "keeping tabs" preferred.
- Natural time strings ("Runs out in 47m"), not raw timestamps.
- **No emojis** in product UI. No exclamation points except resets.
- Non-affiliation: "Claude" / "Claude Code" used descriptively only; HowlAlert is independent of Anthropic.
