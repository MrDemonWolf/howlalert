<p align="center">
  <img src="assets/howlalert-wolf-brand.svg" alt="HowlAlert" width="120" height="120">
</p>

# howlalert

This project was created with [Better-T-Stack](https://github.com/AmanVarshney01/create-better-t-stack), a modern TypeScript stack that combines Next.js, Hono, TRPC, and more.

## Features

- **TypeScript** - For type safety and improved developer experience
- **Next.js** - Full-stack React framework
- **TailwindCSS** - Utility-first CSS for rapid UI development
- **Shared UI package** - shadcn/ui primitives live in `packages/ui`
- **Hono** - Lightweight, performant server framework
- **tRPC** - End-to-end type-safe APIs
- **Bun** - Runtime environment
- **Drizzle** - TypeScript-first ORM
- **PostgreSQL** - Database engine
- **Authentication** - Better-Auth
- **Turborepo** - Optimized monorepo build system

## Getting Started

First, install the dependencies:

```bash
bun install
```

## Database Setup

This project uses PostgreSQL with Drizzle ORM.

1. Make sure you have a PostgreSQL database set up.
2. Update your `apps/server/.env` file with your PostgreSQL connection details.

3. Apply the schema to your database:

```bash
bun run db:push
```

Then, run the development server:

```bash
bun run dev
```

Open [http://localhost:3001](http://localhost:3001) in your browser to see the web application.
The API is running at [http://localhost:3000](http://localhost:3000).

## UI Customization

React web apps in this stack share shadcn/ui primitives through `packages/ui`.

- Change design tokens and global styles in `packages/ui/src/styles/globals.css`
- Update shared primitives in `packages/ui/src/components/*`
- Adjust shadcn aliases or style config in `packages/ui/components.json` and `apps/web/components.json`

### Add more shared components

Run this from the project root to add more primitives to the shared UI package:

```bash
npx shadcn@latest add accordion dialog popover sheet table -c packages/ui
```

Import shared components like this:

```tsx
import { Button } from "@howlalert/ui/components/button";
```

### Add app-specific blocks

If you want to add app-specific blocks instead of shared primitives, run the shadcn CLI from `apps/web`.

## Project Structure

```
howlalert/
├── apps/
│   ├── web/         # Frontend application (Next.js)
│   └── server/      # Backend API (Hono, TRPC)
├── packages/
│   ├── ui/          # Shared shadcn/ui components and styles
│   ├── api/         # API layer / business logic
│   ├── auth/        # Authentication configuration & logic
│   └── db/          # Database schema & queries
```

## Available Scripts

- `bun run dev`: Start all applications in development mode
- `bun run build`: Build all applications
- `bun run dev:web`: Start only the web application
- `bun run dev:server`: Start only the server
- `bun run check-types`: Check TypeScript types across all apps
- `bun run db:push`: Push schema changes to database
- `bun run db:generate`: Generate database client/types
- `bun run db:migrate`: Run database migrations
- `bun run db:studio`: Open database studio UI

## License

HowlAlert is free software, licensed under the **GNU General Public License v3.0**
(see [LICENSE](LICENSE)). Copyright © 2026 MrDemonWolf, Inc.

**Apple App Store / Mac App Store additional permission (GPLv3 §7).** As an
additional permission under section 7 of the GPLv3, MrDemonWolf, Inc. grants
permission to convey the Program (or a work based on it) through the Apple App
Store and/or Mac App Store, notwithstanding the additional terms imposed by
Apple's Usage Rules / App Store terms that would otherwise be incompatible with
the GPLv3. This permission applies to verbatim copies and to copies whose only
modifications are those reasonably necessary for App Store distribution.

**Trademarks are NOT licensed.** The names "HowlAlert" and "MrDemonWolf," the
wolf mark, and associated logos are trademarks of MrDemonWolf, Inc. and are **not**
licensed under the GPL. Forks and redistributions must use a different name and
logo (you may state your build is "based on HowlAlert").

**Not affiliated with Anthropic.** "Claude" and "Claude Code" are trademarks of
Anthropic, PBC, used here only descriptively to state compatibility. HowlAlert is
not affiliated with, endorsed by, or sponsored by Anthropic.

**Legal:** [Privacy Policy](https://mrdemonwolf.github.io/howlalert/docs/legal/privacy) · [EULA](https://mrdemonwolf.github.io/howlalert/docs/legal/eula) · [Disclaimer](https://mrdemonwolf.github.io/howlalert/docs/legal/disclaimer). Internal compliance audit: [COMPLIANCE.md](COMPLIANCE.md).
