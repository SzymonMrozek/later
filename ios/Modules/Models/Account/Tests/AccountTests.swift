import Account
import Testing

struct AccountTests {
    @Test func onlyAGuestIsAGuest() {
        #expect(Account(id: .init(rawValue: "a"), kind: .guest).isGuest)
        #expect(!Account(id: .init(rawValue: "a"), kind: .apple(email: nil)).isGuest)
    }
}
