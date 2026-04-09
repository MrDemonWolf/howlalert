.PHONY: help build-mac build-ios build-watch build-all test clean \
       worker-dev worker-deploy worker-typecheck \
       docs-dev docs-build \
       admin-dev admin-build admin-deploy \
       test-kit ci open-xcode update-deps

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ── Native (Swift) ──────────────────────────────────────────────

SCHEME     = howlalert
XCPROJECT  = howlalert.xcodeproj

build-mac: ## Build macOS app
	xcodebuild -project $(XCPROJECT) -scheme $(SCHEME) \
		-destination 'platform=macOS' build

build-ios: ## Build iOS app (Simulator)
	xcodebuild -project $(XCPROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

build-watch: ## Build watchOS app (Simulator)
	xcodebuild -project $(XCPROJECT) -scheme $(SCHEME) \
		-destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build

build-all: build-mac build-ios build-watch ## Build all native targets

test-kit: ## Run HowlAlertKit Swift tests
	cd packages/HowlAlertKit && swift test

test: test-kit ## Run all tests

open-xcode: ## Open Xcode project
	open $(XCPROJECT)

xcodegen: ## Regenerate Xcode project from project.yml
	xcodegen generate

update-deps: ## Update Swift package dependencies
	cd packages/HowlAlertKit && swift package update

# ── Cloudflare Worker ───────────────────────────────────────────

worker-dev: ## Run Worker locally
	cd worker && bun run dev

worker-deploy: ## Deploy Worker to production
	cd worker && bun run deploy

worker-typecheck: ## Typecheck Worker
	cd worker && bun run typecheck

# ── Docs (Fumadocs) ────────────────────────────────────────────

docs-dev: ## Run docs dev server
	cd apps/docs && bun run dev

docs-build: ## Build docs site
	cd apps/docs && bun run build

# ── Admin Dashboard ─────────────────────────────────────────────

admin-dev: ## Run admin dev server (port 3001)
	cd admin && npm run dev -- -p 3001

admin-build: ## Build admin dashboard
	cd admin && npm run build

admin-deploy: ## Deploy admin to Cloudflare Pages
	cd admin && npx @cloudflare/next-on-pages && wrangler pages deploy .vercel/output/static

# ── CI ──────────────────────────────────────────────────────────

ci: worker-typecheck docs-build test-kit ## Run CI checks

# ── Cleanup ─────────────────────────────────────────────────────

clean: ## Clean build artifacts
	cd packages/HowlAlertKit && swift package clean
	rm -rf worker/node_modules admin/node_modules apps/docs/node_modules
