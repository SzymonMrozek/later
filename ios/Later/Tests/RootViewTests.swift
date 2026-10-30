@testable import Later
import Testing

@MainActor
struct RootViewTests {
    @Test func showsAppName() {
        #expect(RootView.title == "Later")
    }
}
