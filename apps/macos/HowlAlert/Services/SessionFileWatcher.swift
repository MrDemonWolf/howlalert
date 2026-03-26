import Foundation
import Combine
import CoreServices

/// Watches `~/.claude/projects/` for JSONL file changes using FSEvents.
///
/// The watcher monitors the directory recursively and processes only `.jsonl`
/// files. It tracks the byte offset for each file so that only newly appended
/// lines are parsed on each change notification.
@MainActor
final class SessionFileWatcher: ObservableObject {

	// MARK: - Published state

	@Published var currentSnapshot: UsageSnapshot?
	@Published var recentEvents: [JSONLEvent] = []
	@Published var sessionCount: Int = 0
	@Published var isWatching = false

	// MARK: - Private

	private var stream: FSEventStreamRef?
	private let watchPath: String
	private var fileOffsets: [String: UInt64] = [:]

	private let aggregator = UsageAggregator()
	private var cancellable: AnyCancellable?
	private var extraCancellables = Set<AnyCancellable>()

	// MARK: - Init

	init(watchPath: String = NSHomeDirectory() + "/.claude/projects") {
		self.watchPath = watchPath

		// Mirror aggregator state to our published properties
		cancellable = aggregator.$snapshot
			.receive(on: RunLoop.main)
			.assign(to: \.currentSnapshot, on: self)

		aggregator.$recentEvents
			.receive(on: RunLoop.main)
			.assign(to: \.recentEvents, on: self)
			.store(in: &extraCancellables)

		aggregator.$sessionCount
			.receive(on: RunLoop.main)
			.assign(to: \.sessionCount, on: self)
			.store(in: &extraCancellables)
	}

	deinit {
		// Stream must be stopped on whatever thread owns it; guard just in case.
		if let stream {
			FSEventStreamStop(stream)
			FSEventStreamInvalidate(stream)
			FSEventStreamRelease(stream)
		}
	}

	// MARK: - Public API

	func startWatching() {
		guard stream == nil else { return }

		// Ensure the watch directory exists
		var isDir: ObjCBool = false
		guard FileManager.default.fileExists(atPath: watchPath, isDirectory: &isDir),
			  isDir.boolValue
		else {
			return
		}

		let pathsToWatch = [watchPath] as CFArray

		var context = FSEventStreamContext()
		context.info = Unmanaged.passUnretained(self).toOpaque()

		let flags: FSEventStreamCreateFlags =
			UInt32(kFSEventStreamCreateFlagFileEvents) |
			UInt32(kFSEventStreamCreateFlagUseCFTypes)

		guard let eventStream = FSEventStreamCreate(
			nil,
			SessionFileWatcher.eventCallback,
			&context,
			pathsToWatch,
			FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
			0.3, // latency in seconds
			flags
		) else {
			return
		}

		stream = eventStream
		FSEventStreamScheduleWithRunLoop(
			eventStream,
			CFRunLoopGetMain(),
			CFRunLoopMode.defaultMode.rawValue
		)
		FSEventStreamStart(eventStream)
		isWatching = true
	}

	func stopWatching() {
		guard let eventStream = stream else { return }
		FSEventStreamStop(eventStream)
		FSEventStreamInvalidate(eventStream)
		FSEventStreamRelease(eventStream)
		stream = nil
		isWatching = false
	}

	// MARK: - FSEvents callback

	/// C-function callback required by `FSEventStreamCreate`.
	private static let eventCallback: FSEventStreamCallback = {
		(streamRef, clientCallbackInfo, numEvents, eventPaths, eventFlags, eventIds) in

		guard let info = clientCallbackInfo else { return }
		let watcher = Unmanaged<SessionFileWatcher>.fromOpaque(info)
			.takeUnretainedValue()

		guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else {
			return
		}

		for path in paths {
			guard path.hasSuffix(".jsonl") else { continue }
			Task { @MainActor in
				watcher.processFileChanges(at: path)
			}
		}
	}

	// MARK: - File processing

	/// Read only the newly appended bytes from a JSONL file and parse each line.
	private func processFileChanges(at path: String) {
		guard FileManager.default.isReadableFile(atPath: path) else { return }

		guard let handle = FileHandle(forReadingAtPath: path) else { return }
		defer { try? handle.close() }

		// Seek to the last known offset (or start of file if first encounter)
		let offset = fileOffsets[path] ?? 0
		handle.seek(toFileOffset: offset)

		let newData = handle.readDataToEndOfFile()
		guard !newData.isEmpty else { return }

		// Update stored offset
		fileOffsets[path] = offset + UInt64(newData.count)

		guard let text = String(data: newData, encoding: .utf8) else { return }

		// Track this file as a unique session
		aggregator.trackSession(fileId: path)

		let lines = text.components(separatedBy: .newlines)
		for line in lines {
			if let event = JSONLParser.parse(line: line) {
				aggregator.addEvent(event)
			}
		}
	}
}
