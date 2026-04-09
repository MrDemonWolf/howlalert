.PHONY: help \
        build-mac build-ios build-watch build-all \
        test-kit test open-xcode xcodegen update-deps \
        dev build typecheck deploy clean ci

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

# ── JS (Turborepo via Bun) ───────────────────────────────────────

dev: ## Start all JS services (worker + admin + docs)
	bun run dev

build: ## Build all JS apps
	bun run build

typecheck: ## Typecheck all JS apps
	bun run typecheck

deploy: ## Deploy all JS apps
	bun run deploy

# ── CI ──────────────────────────────────────────────────────────

ci: typecheck build test-kit ## Run CI checks

# ── Cleanup ─────────────────────────────────────────────────────

clean: ## Clean build artifacts
	cd packages/HowlAlertKit && swift package clean
	bun run clean
	rm -rf node_modules
