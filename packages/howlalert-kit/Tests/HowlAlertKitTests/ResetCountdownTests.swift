import Testing
@testable import HowlAlertKit

@Suite("ResetCountdown.format")
struct ResetCountdownTests {
    @Test("renders Reset! when window is over")
    func reset() {
        #expect(ResetCountdown.format(remaining: 0) == "Reset!")
        #expect(ResetCountdown.format(remaining: -5) == "Reset!")
    }

    @Test("renders seconds in final minute")
    func seconds() {
        #expect(ResetCountdown.format(remaining: 5) == "5s")
        #expect(ResetCountdown.format(remaining: 59) == "59s")
    }

    @Test("renders minutes between 1m and 60m")
    func minutes() {
        #expect(ResetCountdown.format(remaining: 60) == "1m")
        #expect(ResetCountdown.format(remaining: 47 * 60) == "47m")
        #expect(ResetCountdown.format(remaining: 59 * 60) == "59m")
    }

    @Test("renders hours and minutes above 60m")
    func hoursAndMinutes() {
        #expect(ResetCountdown.format(remaining: 60 * 60) == "1h 0m")
        #expect(ResetCountdown.format(remaining: 2 * 3600 + 13 * 60) == "2h 13m")
        #expect(ResetCountdown.format(remaining: 4 * 3600 + 59 * 60) == "4h 59m")
    }
}
