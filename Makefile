# HowlAlert Makefile
# Usage: make help

SCHEME        := howlalert
PROJECT       := apps/native/howlalert.xcodeproj
WORKER_DIR    := apps/api
DOCS_DIR      := apps/docs

.PHONY: help build-mac build-ios build-watch build-all clean test \
        update-deps open-xcode worker-dev worker-deploy \
        docs-dev docs-build prod-build ci

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build-mac: ## Build macOS target
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=macOS' build | xcbeautify || true

build-ios: ## Build iOS target
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'generic/platform=iOS Simulator' build | xcbeautify || true

build-watch: ## Build watchOS target
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'generic/platform=watchOS Simulator' build | xcbeautify || true

build-all: build-mac build-ios build-watch ## Build all Apple targets

test: ## Run Swift package tests
	cd apps/native/howlalert/HowlAlertKit && swift test

clean: ## Clean build artifacts
	xcodebuild clean -project $(PROJECT) || true
	cd apps/native/howlalert/HowlAlertKit && swift package clean
	rm -rf .build apps/native/.build

update-deps: ## Update Swift package dependencies
	cd apps/native/howlalert/HowlAlertKit && swift package update

open-xcode: ## Open project in Xcode
	open $(PROJECT)

worker-dev: ## Run Cloudflare Worker locally
	cd $(WORKER_DIR) && bun run dev

worker-deploy: ## Deploy Cloudflare Worker to production
	cd $(WORKER_DIR) && bun run deploy

docs-dev: ## Start docs dev server
	cd $(DOCS_DIR) && bun run dev

docs-build: ## Build docs for production
	cd $(DOCS_DIR) && bun run build

prod-build: build-all worker-deploy docs-build ## Full production build

ci: ## Run CI checks (typecheck + docs build + Swift test)
	cd $(WORKER_DIR) && bun install && bun run typecheck
	cd $(DOCS_DIR) && bun install && bun run build
	cd apps/native/howlalert/HowlAlertKit && swift test

apply-migrations: ## Apply D1 migrations to local dev database
	cd $(WORKER_DIR) && wrangler d1 migrations apply howlalert-db --local

apply-migrations-prod: ## Apply D1 migrations to production database
	cd $(WORKER_DIR) && wrangler d1 migrations apply howlalert-db --env production
