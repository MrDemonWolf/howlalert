import Testing
@testable import HowlAlertCore

@Suite("ClaudeSettingsHook")
struct ClaudeSettingsHookTests {
    let cmd = "/Applications/HowlAlert.app/Contents/Helpers/howlalert-hook"

    @Test func registerIntoEmptySettings() throws {
        let out = ClaudeSettingsHook.register(.object([:]), command: cmd)
        #expect(ClaudeSettingsHook.isRegistered(out, command: cmd))
        let stop = out.objectValue?["hooks"]?.objectValue?["Stop"]?.arrayValue
        #expect(stop?.count == 1)
    }

    @Test func registerIsIdempotent() throws {
        let once = ClaudeSettingsHook.register(.object([:]), command: cmd)
        let twice = ClaudeSettingsHook.register(once, command: cmd)
        #expect(once == twice)
        let stop = twice.objectValue?["hooks"]?.objectValue?["Stop"]?.arrayValue
        #expect(stop?.count == 1)
    }

    @Test func unregisterRemovesOurCommand() throws {
        let added = ClaudeSettingsHook.register(.object([:]), command: cmd)
        let removed = ClaudeSettingsHook.unregister(added, command: cmd)
        #expect(!ClaudeSettingsHook.isRegistered(removed, command: cmd))
        // Empty hooks object should be cleaned away entirely.
        #expect(removed == .object([:]))
    }

    @Test func registerPreservesOtherTopLevelKeys() throws {
        let settings = JSONValue.object([
            "model": .string("opus"),
            "permissions": .object(["allow": .array([.string("Bash")])]),
        ])
        let out = ClaudeSettingsHook.register(settings, command: cmd)
        #expect(out.objectValue?["model"]?.stringValue == "opus")
        #expect(out.objectValue?["permissions"] != nil)
        #expect(ClaudeSettingsHook.isRegistered(out, command: cmd))
    }

    @Test func preservesOtherStopHooksAndOtherEvents() throws {
        let other = "/usr/local/bin/some-other-hook"
        let settings = JSONValue.object([
            "hooks": .object([
                "Stop": .array([
                    .object(["hooks": .array([.object(["type": .string("command"), "command": .string(other)])])])
                ]),
                "PreToolUse": .array([
                    .object(["hooks": .array([.object(["type": .string("command"), "command": .string("/x")])])])
                ]),
            ])
        ])
        let out = ClaudeSettingsHook.register(settings, command: cmd)
        #expect(ClaudeSettingsHook.isRegistered(out, command: cmd))
        #expect(ClaudeSettingsHook.isRegistered(out, command: other))

        let back = ClaudeSettingsHook.unregister(out, command: cmd)
        #expect(!ClaudeSettingsHook.isRegistered(back, command: cmd))
        // The unrelated Stop hook and the PreToolUse event survive.
        #expect(ClaudeSettingsHook.isRegistered(back, command: other))
        #expect(back.objectValue?["hooks"]?.objectValue?["PreToolUse"] != nil)
    }

    @Test func unregisterMissingIsNoOp() throws {
        let settings = JSONValue.object(["model": .string("opus")])
        let out = ClaudeSettingsHook.unregister(settings, command: cmd)
        #expect(out == settings)
    }

    @Test func parseEmptyTextIsEmptyObject() throws {
        #expect(try JSONValue.parse("") == .object([:]))
        #expect(try JSONValue.parse("   \n ") == .object([:]))
    }

    @Test func roundTripThroughTextPreservesRegistration() throws {
        let added = ClaudeSettingsHook.register(.object(["model": .string("opus")]), command: cmd)
        let text = try added.serialized()
        let reparsed = try JSONValue.parse(text)
        #expect(reparsed == added)
        #expect(ClaudeSettingsHook.isRegistered(reparsed, command: cmd))
    }

    @Test func intsStayInts() throws {
        // An int must survive serialize → parse as an int, not become 5.0.
        let v = JSONValue.object(["n": .int(5)])
        let round = try JSONValue.parse(v.serialized())
        #expect(round == .object(["n": .int(5)]))
        #expect(!(try v.serialized()).contains("5.0"))
    }
}
