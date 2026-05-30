import Foundation
import Testing
@testable import HowlAlertCore

@Suite("ClaudeConfig")
struct ClaudeConfigTests {
    func makeDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("howl-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    @Test func appendsProjectsToConfigDirEnv() throws {
        let base = try makeDir()
        let projects = base.appendingPathComponent("projects", isDirectory: true)
        try FileManager.default.createDirectory(at: projects, withIntermediateDirectories: true)
        let fakeHome = try makeDir() // no .claude inside

        let roots = ClaudeConfig.discoverTranscriptRoots(
            environment: ["CLAUDE_CONFIG_DIR": base.path],
            homeDirectory: fakeHome
        )
        #expect(roots.map(\.path) == [projects.standardizedFileURL.path])
    }

    @Test func skipsNonExistentRoots() throws {
        let fakeHome = try makeDir() // empty home → no claude dirs
        let roots = ClaudeConfig.discoverTranscriptRoots(environment: [:], homeDirectory: fakeHome)
        #expect(roots.isEmpty)
    }

    @Test func findsDotClaudeProjectsInHome() throws {
        let home = try makeDir()
        let projects = home.appendingPathComponent(".claude/projects", isDirectory: true)
        try FileManager.default.createDirectory(at: projects, withIntermediateDirectories: true)
        let roots = ClaudeConfig.discoverTranscriptRoots(environment: [:], homeDirectory: home)
        #expect(roots.contains { $0.path == projects.standardizedFileURL.path })
    }
}
