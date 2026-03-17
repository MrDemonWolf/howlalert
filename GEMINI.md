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
└── Makefile       Root orchestration for all components
```

### Core Architecture

1.  **API (`apps/api`)**:
    *   **Runtime**: Cloudflare Workers (using `bun`).
    *   **Framework**: Hono 4.x.
    *   **Storage**: D1 (Relational history) and KV (Device registrations & preferences).
    *   **Notifications**: Direct integration with Apple Push Notification service (APNs) using JWT authentication.
    *   **Auth**: Apple Identity Token verification (RS256).

2.  **Native (`apps/native`)**:
    *   **Language**: Swift 6.0+, SwiftUI.
    *   **Targets**: macOS (MenuBar app), iOS, watchOS.
    *   **Library**: `HowlAlertKit` (Local SPM package) contains all networking, parsing, and business logic.
    *   **Mechanism**: Reads Claude Code session data from `~/.claude/projects/` to track token usage and costs.

3.  **Docs (`apps/docs`)**:
    *   **Framework**: Next.js 15 + React 19.
    *   **Engine**: Fumadocs for MDX-based documentation.

---

## Building and Running

The root `Makefile` is the primary entry point for development commands.

### API (Cloudflare Worker)
*   `make worker-dev`: Start local Wrangler development server (Hono + D1 local).
*   `make worker-deploy`: Deploy to Cloudflare production.
*   `make apply-migrations`: Apply D1 database migrations locally.
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

## Development Conventions

### Code Style
*   **Indentation**: **Tabs** (size 4) for all source code (TS, Swift, CSS). **Spaces** (size 2) for configuration files (JSON, YAML, MDX).
*   **Line Endings**: LF (Unix-style).
*   **TypeScript**: Strict mode enabled. Avoid `any` types; prefer strong typing for API responses and environment bindings.
*   **Swift**: Follow modern Swift concurrency patterns (`async/await`). Maintain clear separation between `HowlAlertKit` (logic) and SwiftUI Views.

### Testing
*   **Logic**: All core parsing and networking logic must reside in `HowlAlertKit` and be covered by Swift tests (`make test`).
*   **API**: Test endpoints locally using `wrangler dev` before deploying.

### Infrastructure
*   **Migrations**: Always create a new `.sql` file in `apps/api/migrations/` for schema changes.
*   **KV Naming**:
    *   `device:{userId}:{token}`: Device registration metadata.
    *   `prefs:{userId}`: User-specific alert thresholds.
