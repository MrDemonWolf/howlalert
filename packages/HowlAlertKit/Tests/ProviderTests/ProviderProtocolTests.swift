// ProviderProtocolTests — Verify provider protocol conformance
// © 2026 MrDemonWolf, Inc.

import Testing
import Foundation
@testable import Providers
@testable import Models

@Suite("UsageProvider Protocol")
struct ProviderProtocolTests {
    @Test("ClaudeCodeProvider conforms and has correct identity")
    func claudeProvider() {
        let provider = ClaudeCodeProvider()
        #expect(provider.id == "claude-code")
        #expect(provider.displayName == "Claude Code")
        #expect(provider.sessionPath.path.contains(".claude/projects"))
    }

    @Test("GeminiCLIProvider throws notImplemented")
    func geminiStub() {
        let provider = GeminiCLIProvider()
        #expect(provider.id == "gemini-cli")
        #expect(provider.displayName == "Gemini CLI")

        let fakeURL = URL(fileURLWithPath: "/tmp/fake.jsonl")
        #expect(throws: ProviderError.self) {
            try provider.parseSnapshot(from: fakeURL)
        }
    }
}
