import Foundation
import HowlAlertCore

// HowlAlert Stop-hook handler.
//
// Wire into Claude Code's Stop hook (~/.claude/settings.json):
//
//   "hooks": {
//     "Stop": [
//       { "hooks": [ { "type": "command", "command": "/path/to/howlalert-hook" } ] }
//     ]
//   }
//
// Claude passes hook JSON on stdin; we don't need it — just nudge the running
// app to refresh its usage snapshot now (instead of waiting on FSEvents).
HowlSignal.post()
