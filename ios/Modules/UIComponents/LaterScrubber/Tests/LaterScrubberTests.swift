import Foundation
@testable import LaterScrubber
import Testing

struct LaterScrubberTests {
    @Test(arguments: [
        (0.0, "0:00"),
        (59.9, "0:59"),
        (760, "12:40"),
        (3723, "1:02:03"),
        (-5, "0:00"),
    ])
    func formatsTime(interval: TimeInterval, expected: String) {
        #expect(LaterScrubber.time(interval) == expected)
    }

    @Test func formatsRemainingWithMinusSign() {
        #expect(LaterScrubber.remaining(760, of: 1280) == "\u{2212}8:40")
        #expect(LaterScrubber.remaining(2000, of: 1280) == "\u{2212}0:00")
    }

    @Test func clampsProgress() {
        #expect(LaterScrubber.progress(elapsed: 30, duration: 120) == 0.25)
        #expect(LaterScrubber.progress(elapsed: 200, duration: 120) == 1)
        #expect(LaterScrubber.progress(elapsed: -1, duration: 120) == 0)
        #expect(LaterScrubber.progress(elapsed: 10, duration: 0) == 0)
    }
}
