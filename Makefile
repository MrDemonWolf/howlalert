# HowlAlert Makefile
# Usage: make help

SCHEME_MAC    := HowlAlert-Mac
SCHEME_IOS    := HowlAlert-iOS
SCHEME_WATCH  := HowlAlert-Watch
PROJECT       := apps/native/HowlAlert.xcodeproj
WORKER_DIR    := apps/api
DOCS_DIR      := apps/docs

.PHONY: help build-mac build-ios build-watch build-all clean test \
        update-deps open-xcode worker-dev worker-deploy \
        docs-dev docs-build generate-project prod-build ci

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

generate-project: ## Generate Xcode project from project.yml
	cd apps/native && xcodegen generate

build-mac: generate-project ## Build macOS target
	xcodebuild -project $(PROJECT) -scheme $(SCHEME_MAC) \
		-destination 'platform=macOS' build | xcbeautify || true

build-ios: generate-project ## Build iOS target
	xcodebuild -project $(PROJECT) -scheme $(SCHEME_IOS) \
		-destination 'generic/platform=iOS Simulator' build | xcbeautify || true

build-watch: generate-project ## Build watchOS target
	xcodebuild -project $(PROJECT) -scheme $(SCHEME_WATCH) \
		-destination 'generic/platform=watchOS Simulator' build | xcbeautify || true

build-all: build-mac build-ios build-watch ## Build all Apple targets

test: generate-project ## Run Swift package tests
	cd apps/native/HowlAlertKit && swift test

clean: ## Clean build artifacts
	xcodebuild clean -project $(PROJECT) || true
	cd apps/native/HowlAlertKit && swift package clean
	rm -rf .build apps/native/.build

update-deps: ## Update Swift package dependencies
	cd apps/native/HowlAlertKit && swift package update

open-xcode: generate-project ## Open project in Xcode
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
	cd apps/native/HowlAlertKit && swift test
