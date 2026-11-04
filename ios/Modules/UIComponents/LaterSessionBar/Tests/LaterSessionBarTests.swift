@testable import LaterSessionBar
import Testing

struct LaterSessionBarTests {
    typealias Segment = LaterSessionBar.Segment

    @Test func leavesFreeTimeAfterTheItems() {
        let segments = LaterSessionBar.layout(lengths: [3, 12, 4], available: 20)
        #expect(segments == [
            Segment(position: 0, fraction: 0.15),
            Segment(position: 1, fraction: 0.6),
            Segment(position: 2, fraction: 0.2),
            Segment(position: nil, fraction: 0.05),
        ])
    }

    @Test func fillsTheBarWhenTheSessionIsLonger() {
        let segments = LaterSessionBar.layout(lengths: [20, 20], available: 30)
        #expect(segments == [Segment(position: 0, fraction: 0.5), Segment(position: 1, fraction: 0.5)])
    }

    @Test func skipsEmptyItemsButKeepsPositions() {
        let segments = LaterSessionBar.layout(lengths: [5, 0, 5], available: 10)
        #expect(segments.map(\.position) == [0, 2])
    }

    @Test func isEmptyWithNothingToShow() {
        #expect(LaterSessionBar.layout(lengths: [], available: 0).isEmpty)
        #expect(LaterSessionBar.layout(lengths: [], available: 20) == [Segment(position: nil, fraction: 1)])
    }
}
