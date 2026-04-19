.PHONY: install dev build lint typecheck test swift-build swift-test xcodegen clean

install:
	bun install

dev:
	bun run dev

build:
	bun run build

lint:
	bun run lint

typecheck:
	bun run typecheck

test:
	bun run test

swift-build:
	swift build --package-path packages/howlalert-kit

swift-test:
	swift test --package-path packages/howlalert-kit

xcodegen:
	cd apps/macos && xcodegen generate
	cd apps/ios && xcodegen generate
	cd apps/watchos && xcodegen generate

clean:
	rm -rf node_modules .turbo
	find apps packages -name node_modules -type d -prune -exec rm -rf {} +
	find apps packages -name .turbo -type d -prune -exec rm -rf {} +
	rm -rf packages/howlalert-kit/.build packages/howlalert-kit/.swiftpm
