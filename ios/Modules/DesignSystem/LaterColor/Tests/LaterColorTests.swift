@testable import LaterColor
import SwiftUI
import Testing
import UIKit

struct LaterColorTests {
    @Test func parsesOpaqueHex() {
        #expect(RGBA(rgb: 0x2449D8) == RGBA(rgba: 0x2449_D8FF))
        let accent = RGBA(rgb: 0x2449D8)
        #expect(accent.red == 0x24 / 255.0)
        #expect(accent.green == 0x49 / 255.0)
        #expect(accent.blue == 0xD8 / 255.0)
        #expect(accent.alpha == 1)
    }

    @Test func parsesAlphaHex() {
        #expect(RGBA(rgba: 0xFFFF_FFB8).alpha == 0xB8 / 255.0)
    }

    @Test func resolvesLightAndDark() {
        let accent = UIColor(LaterColor.Accent.base)
        #expect(hex(accent, .light) == 0x2449D8)
        #expect(hex(accent, .dark) == 0x7B95FF)
    }

    @Test func cyclesSessionColors() {
        let expected = [0x2449D8, 0x7C93EA, 0xBAC6F4, 0x2449D8]
        let actual = (0 ..< 4).map { hex(UIColor(LaterColor.Accent.session($0)), .light) }
        #expect(actual == expected)
        #expect(hex(UIColor(LaterColor.Accent.session(-1)), .light) == 0xBAC6F4)
    }

    private func hex(_ color: UIColor, _ style: UIUserInterfaceStyle) -> Int {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
            .getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue].reduce(0) { $0 << 8 | Int(($1 * 255).rounded()) }
    }
}
