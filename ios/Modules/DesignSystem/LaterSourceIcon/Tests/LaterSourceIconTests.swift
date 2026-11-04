@testable import LaterSourceIcon
import Testing

struct LaterSourceIconTests {
    @Test(arguments: [
        ("medium.com", "M"),
        ("www.nytimes.com", "N"),
        ("WWW.Wired.com", "W"),
        ("  arstechnica.com", "A"),
        ("9to5mac.com", "9"),
        ("żywność.pl", "Ż"),
        ("", "?"),
        ("—", "?"),
    ])
    func monogram(source: String, expected: String) {
        #expect(LaterSourceIcon.monogram(for: source) == expected)
    }
}
