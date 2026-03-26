Build all targets and verify everything compiles.

Run:
1. `cd packages/HowlAlertKit && swift build` — verify Swift package
2. `cd worker && bun run typecheck` — verify Worker types
3. `cd admin && npm run build` — verify admin dashboard
4. `cd apps/docs && bun run build` — verify docs site
5. `make build-mac` — verify macOS Xcode build (if .xcodeproj exists)

Report any errors found.
