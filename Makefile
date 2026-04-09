.PHONY: dev build build-all build-macos build-ios test-kit package-macos clean deploy-worker deploy-admin

# ── JS/TS ────────────────────────────────────────────────────────────────────

dev:
	bun dev

build:
	bun run build

build-all: build build-macos build-ios

# ── Xcode ────────────────────────────────────────────────────────────────────

build-macos:
	xcodebuild \
		-project howlalert.xcodeproj \
		-scheme "HowlAlert macOS" \
		-configuration Release \
		-destination "platform=macOS" \
		CODE_SIGNING_ALLOWED=NO \
		| xcbeautify || true

build-ios:
	xcodebuild \
		-project howlalert.xcodeproj \
		-scheme "HowlAlert iOS" \
		-configuration Release \
		-destination "generic/platform=iOS Simulator" \
		CODE_SIGNING_ALLOWED=NO \
		| xcbeautify || true

# ── Swift Package ────────────────────────────────────────────────────────────

test-kit:
	swift test --package-path packages/howlalert-kit

# ── Distribution ─────────────────────────────────────────────────────────────

# TODO HAA-62: implement notarization + DMG packaging
package-macos:
	@echo "package-macos not yet implemented (see HAA-62)"

# ── Deploy ───────────────────────────────────────────────────────────────────

deploy-worker:
	bun run deploy --filter=@howlalert/worker

deploy-admin:
	bun run deploy --filter=@howlalert/admin

# ── Cleanup ──────────────────────────────────────────────────────────────────

clean:
	turbo run clean
	swift package --package-path packages/howlalert-kit clean
