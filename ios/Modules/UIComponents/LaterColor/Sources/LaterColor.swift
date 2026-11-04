import SwiftUI
import UIKit

/// The `color.*` tokens from design/Later.canvas. Every color adapts to light and dark mode.
public enum LaterColor {
    public enum Ground {
        public static let bg = Color(light: 0xFFFFFF, dark: 0x0E1014)
        public static let bgGrouped = Color(light: 0xF7F8FA, dark: 0x0E1014)
        public static let surface = Color(light: 0xFFFFFF, dark: 0x1A1D23)
    }

    public enum Control {
        public static let fill = Color(light: 0xF2F3F6, dark: 0x252932)
        public static let fillPlaceholder = Color(light: 0xE6E8EC, dark: 0x2C313B)
        public static let fillSelected = Color(light: 0xFFFFFF, dark: 0x3A3F4B)
        public static let line = Color(light: 0xE3E5EA, dark: 0x343944)
        public static let lineDashed = Color(light: 0xC9CCD4, dark: 0x4A505C)
        public static let hairline = Color(light: 0xEEEFF2, dark: 0x22262E)
    }

    public enum Text {
        public static let ink = Color(light: 0x111318, dark: 0xF1F2F5)
        public static let inkMuted = Color(light: 0x5B6070, dark: 0xA2A7B4)
        public static let inkFaint = Color(light: 0x6E7381, dark: 0x858A98)
        public static let onInk = Color(light: 0xFFFFFF, dark: 0x111318)
    }

    public enum Accent {
        public static let base = Color(light: 0x2449D8, dark: 0x7B95FF)
        public static let on = Color(light: 0xFFFFFF, dark: 0x0E1014)
        public static let soft = Color(light: 0xEEF1FD, dark: 0x1B2547)
        public static let queue2 = Color(light: 0x7C93EA, dark: 0x5873DD)
        public static let queue3 = Color(light: 0xBAC6F4, dark: 0x34427A)
        public static let focus = base

        /// The color of the item at `index` in a listening session: `base`, `queue2`, `queue3`, then again.
        public static func session(_ index: Int) -> Color {
            sessionColors[index.positiveRemainder(dividingBy: sessionColors.count)]
        }

        private static let sessionColors = [base, queue2, queue3]
    }

    public enum Status {
        public static let positive = Color(light: 0x0B6B5D, dark: 0x52C7AC)
        public static let positiveSoft = Color(light: 0xE6F3EF, dark: 0x11302A)
        public static let warning = Color(light: 0xA3420F, dark: 0xF2A46E)
        public static let warningSoft = Color(light: 0xFBF1EA, dark: 0x35210F)
        public static let danger = Color(light: 0xB4361E, dark: 0xFF8B72)
    }

    /// Liquid Glass drawn without the system material, for iOS before 26.
    public enum Glass {
        public static let base = Color(lightRGBA: 0xFFFF_FFB8, darkRGBA: 0x262A_33B8)
        public static let stroke = Color(lightRGBA: 0x1113_1814, darkRGBA: 0xFFFF_FF1F)
        public static let selected = Color(lightRGBA: 0x1113_1810, darkRGBA: 0xFFFF_FF1A)
    }

    public enum Overlay {
        public static let clear = Color(lightRGBA: 0xFFFF_FF00, darkRGBA: 0x0000_0000)
        public static let scrim = Color(lightRGBA: 0x1113_186B, darkRGBA: 0x0000_009E)
        public static let shadowControl = Color(lightRGBA: 0x1113_181F, darkRGBA: 0x0000_0080)
        public static let shadowFloat = Color(lightRGBA: 0x1113_182E, darkRGBA: 0x0000_008C)
        public static let shadowGlass = Color(lightRGBA: 0x1113_181A, darkRGBA: 0x0000_0066)
    }
}

/// One sRGB color, parsed from the canvas's `#RRGGBB` or `#RRGGBBAA` hex.
struct RGBA: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(rgb: UInt32) {
        self.init(rgba: rgb << 8 | 0xFF)
    }

    init(rgba: UInt32) {
        red = Double(rgba >> 24 & 0xFF) / 255
        green = Double(rgba >> 16 & 0xFF) / 255
        blue = Double(rgba >> 8 & 0xFF) / 255
        alpha = Double(rgba & 0xFF) / 255
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(light: RGBA(rgb: light), dark: RGBA(rgb: dark))
    }

    init(lightRGBA: UInt32, darkRGBA: UInt32) {
        self.init(light: RGBA(rgba: lightRGBA), dark: RGBA(rgba: darkRGBA))
    }

    init(light: RGBA, dark: RGBA) {
        let light = light.uiColor
        let dark = dark.uiColor
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
}

private extension Int {
    func positiveRemainder(dividingBy divisor: Int) -> Int {
        (self % divisor + divisor) % divisor
    }
}
