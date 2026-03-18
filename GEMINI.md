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
    *   **Runtime**: Cloudflare Workers (using `bun`).
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
    *   **Mechanism**: Reads Claude Code session data from `~/.claude/projects/` to track token usage and costs.

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
| `cost_usd` | REAL | Total cost for this event |
| `input_tokens` | INTEGER | Prompt tokens |
| `output_tokens` | INTEGER | Completion tokens |

### Threshold Config (KV `prefs:{userId}`)
*   **Daily Cost**: Trigger when `SUM(cost_usd)` for the current date exceeds the value.
*   **Token Count**: (Planned) Trigger on cumulative daily tokens.
*   **Session Count**: (Planned) Trigger on number of active sessions.

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
*   `make test`: Run Swift tests in the `HowlAlertKit` package.
*   `make open-xcode`: Open the project in Xcode.

### Docs
*   `make docs-dev`: Start Next.js development server with Turbopack.
*   `make docs-build`: Build the documentation site for production.

---

## CI/CD Processes

*   **API**:
    *   `ci-api.yml`: Runs on PRs to `main`. Performs `bun install`, `bun run lint`, and `bun run typecheck`.
    *   `deploy-api.yml`: Triggers on push to `main`. Deploys to Cloudflare Workers using Wrangler.
*   **Native**:
    *   `ci-native.yml`: Runs `swift test` for the `HowlAlertKit` package.
*   **Docs**:
    *   `ci-docs.yml`: Validates the build.
    *   `deploy-docs.yml`: Deploys to GitHub Pages or designated hosting.

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
