@testable import BuildConfiguration
import Foundation
import Testing

struct BuildConfigurationTests {
    @Test func readsTheAPIBaseURL() throws {
        let configuration =
            try #require(BuildConfiguration(infoDictionary: ["LaterAPIBaseURL": "http://localhost:4123"]))
        #expect(configuration.apiBaseURL == URL(string: "http://localhost:4123"))
    }

    @Test(arguments: [
        [:],
        ["LaterAPIBaseURL": ""],
        ["LaterAPIBaseURL": "$(LATER_API_BASE_URL)"],
        ["LaterAPIBaseURL": "ftp://example.com"],
        ["LaterAPIBaseURL": 42],
    ] as [[String: any Sendable]])
    func rejectsAMissingOrInvalidURL(infoDictionary: [String: any Sendable]) {
        #expect(BuildConfiguration(infoDictionary: infoDictionary) == nil)
    }
}
