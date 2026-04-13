# HowlAlert v2.0 — Build Targets
# © 2026 MrDemonWolf, Inc.

.PHONY: dev-worker dev-docs build-kit build-macos build-ios test-kit \
        deploy-worker deploy-docs notarize-macos install clean

# ── Development ──────────────────────────────────────────
dev-worker:
	bun run dev:server

dev-docs:
	bun run dev:docs

# ── Swift ────────────────────────────────────────────────
build-kit:
	cd packages/HowlAlertKit && swift build

test-kit:
	cd packages/HowlAlertKit && swift test

# ── Xcode ────────────────────────────────────────────────
build-macos:
	xcodebuild -project apps/macos/HowlAlert.xcodeproj \
		-scheme HowlAlert -configuration Release \
		-arch arm64 \
		$(if $(ARCHIVE),archive -archivePath build/HowlAlert.xcarchive,build)

build-ios:
	xcodebuild -project apps/ios/HowlAlert.xcodeproj \
		-scheme HowlAlert -configuration Release \
		-destination 'generic/platform=iOS' \
		$(if $(ARCHIVE),archive -archivePath build/HowlAlert-iOS.xcarchive,build)

# ── Deploy ───────────────────────────────────────────────
deploy-worker:
	cd apps/server && bun run deploy

deploy-docs:
	cd apps/docs && bun run build

notarize-macos:
	xcrun notarytool submit build/HowlAlert.dmg \
		--apple-id "$(APPLE_ID)" \
		--password "$(APPLE_APP_SPECIFIC_PASSWORD)" \
		--team-id "$(APPLE_TEAM_ID)" \
		--wait
	xcrun stapler staple build/HowlAlert.dmg

# ── Utilities ────────────────────────────────────────────
install:
	bun install

clean:
	rm -rf build/ .turbo node_modules
	cd packages/HowlAlertKit && swift package clean
