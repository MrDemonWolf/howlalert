Run all tests across the monorepo.

Run:
1. `cd packages/HowlAlertKit && swift test` — HowlAlertKit unit tests
2. `cd worker && bun run typecheck` — Worker type checking
3. `cd admin && npm run lint` — Admin linting

Report test results and any failures.
