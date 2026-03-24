# HowlAlert — Project Guide

HowlAlert is a cost and usage monitoring system for Claude Code, providing multi-platform alerts (macOS, iOS, watchOS) when daily spending thresholds are exceeded.

## Project Structure

This is a monorepo with three independent applications. No workspace tooling (npm/bun workspaces) is used; each app manages its own dependencies.

```text
/
├── apps/
│   ├── api/       Cloudflare Worker (Hono + D1 + KV)
│   ├── docs/      Next.js 15 documentation site (Fumadocs)
│   └── native/    SwiftUI multiplatform app (iOS, macOS, watchOS)
├── .github/       CI/CD workflows for each app
└── Makefile       Root orchestration for all components
```

### Core Architecture

1.  **API (`apps/api`)**:
    *   **Runtime**: Cloudflare Workers (using `bun`) with `nodejs_compat` enabled.
    *   **Framework**: Hono 4.x with `{ Bindings: Env }` pattern.
    *   **Storage**:
        *   **D1 (`DB`)**: Relational event history (`usage_events` table).
        *   **KV (`HOWLALERT_DEVICES`)**: Device registrations (`device:{userId}:{token}`) and User Preferences (`prefs:{userId}`).
    *   **Notifications**: Direct integration with Apple Push Notification service (APNs) using HTTP/2 and JWT authentication.
    *   **Auth**: Apple Identity Token verification.
        *   **Production**: Full RS256 JWT validation against Apple's JWKS (cached in KV for 24h).
        *   **Development**: Simple `dev_user_{token_prefix}` logic for easier testing.

2.  **Native (`apps/native`)**:
    *   **Language**: Swift 6.0+, SwiftUI.
    *   **Targets**: macOS (MenuBar app), iOS, watchOS.
    *   **Library**: `HowlAlertKit` (Local SPM package) contains all networking, parsing, and business logic.
    *   **Mechanism**:
        *   **macOS**: Reads Claude Code session data from `~/.claude/stats-cache.json` to track token usage and costs.
        *   **Hooks**: `HookEventParser` is designed to parse usage events from stdin, potentially for integration as a Claude Code hook.
    *   **Security**: Uses Keychain for secure token storage and App Groups (`group.com.mrdemonwolf.howlalert`) for sharing preferences between targets (App, Widget, Complication).
    *   **Extensions**: Includes a WidgetKit extension for watchOS complications.

3.  **Docs (`apps/docs`)**:
    *   **Framework**: Next.js 15 + React 19.
    *   **Engine**: Fumadocs for MDX-based documentation.

---

## Data Models (API)

### Usage Event (`usage_events` table)
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | TEXT | Primary Key (UUID) |
| `user_id` | TEXT | Apple `sub` claim |
| `session_id` | TEXT | Unique session identifier from Claude |
| `timestamp` | TEXT | ISO8601 event time |
| `model` | TEXT | Claude model name |
| `input_tokens` | INTEGER | Prompt tokens |
| `output_tokens` | INTEGER | Completion tokens |
| `cache_read_tokens` | INTEGER | Context caching read tokens |
| `cache_write_tokens` | INTEGER | Context caching write tokens |
| `cost_usd` | REAL | Total cost for this event |
| `created_at` | TEXT | Record creation timestamp (DB default) |

### Threshold Config (KV `prefs:{userId}`)
*   **Daily Cost**: Trigger when `SUM(cost_usd)` for the current date exceeds the value. (**Implemented**)
*   **Token Count**: Trigger on cumulative daily tokens. (**Planned/Native Only**)
*   **Session Count**: Trigger on number of active sessions. (**Planned/Native Only**)

---

## Building and Running

The root `Makefile` is the primary entry point for development commands.

### API (Cloudflare Worker)
*   `make worker-dev`: Start local Wrangler development server (Hono + D1 local).
*   `make worker-deploy`: Deploy to Cloudflare production.
*   `make apply-migrations`: Apply D1 database migrations locally.
*   `make apply-migrations-prod`: Apply D1 database migrations to production.
*   `cd apps/api && bun run typecheck`: Run TypeScript compiler check.

### Native (Apple Platforms)
*   `make build-mac`: Build the macOS MenuBar application.
*   `make build-ios`: Build for iOS Simulator.
*   `make build-watch`: Build for watchOS Simulator.
*   `make build-all`: Build all three Apple targets.
*   `make test`: Run Swift tests in the `HowlAlertKit` package.
*   `make open-xcode`: Open the project in Xcode.
*   `make update-deps`: Update Swift package dependencies.
*   `make clean`: Clean build artifacts for Xcode and SPM.

### Docs
*   `make docs-dev`: Start Next.js development server with Turbopack.
*   `make docs-build`: Build the documentation site for production.

### Full CI/CD
*   `make ci`: Run all CI checks (API typecheck + docs build + Swift tests).
*   `make prod-build`: Full production build (all Apple targets + worker deploy + docs build).

---

## Key Features & Modes

### Demo Mode
For Apple App Store review, a **Demo Mode** can be toggled in `PreferencesView`. When enabled:
*   The dashboard loads static data from `DemoData.swift`.
*   The macOS MenuBar extra shows a synthetic "Active Claude Session".
*   Network requests to the API are bypassed or mocked.

### APNs Integration
The API worker sends push notifications to all registered `deviceToken`s for a `userId` when a threshold is breached. It handles `410 Gone` (stale tokens) by automatically deregistering devices.

---

## Development Conventions

### Code Style
*   **Indentation**: **Tabs** (size 4) for all source code (TS, Swift, CSS). **Spaces** (size 2) for configuration files (JSON, YAML, MDX).
*   **Line Endings**: LF (Unix-style).
*   **TypeScript**: Strict mode enabled. Avoid `any` types; prefer strong typing for API responses and environment bindings.
*   **Swift**: Follow modern Swift concurrency patterns (`async/await`). Maintain clear separation between `HowlAlertKit` (logic) and SwiftUI Views.

### Infrastructure
*   **Migrations**: Always create a new `.sql` file in `apps/api/migrations/` for schema changes.
*   **KV Naming**:
    *   `device:{userId}:{token}`: Device registration metadata.
    *   `prefs:{userId}`: User-specific alert thresholds.
    *   `apple_public_keys`: Cached JWKS from Apple (TTL 24h).
