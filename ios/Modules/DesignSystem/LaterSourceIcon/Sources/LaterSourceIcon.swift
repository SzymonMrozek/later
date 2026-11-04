import LaterColor
import LaterRadius
import LaterSize
import LaterTypography
import SwiftUI

/// `SourceIcon` from design/Later.canvas: the site's favicon, or its first letter on a grey tile.
public struct LaterSourceIcon: View {
    private let source: String
    private let favicon: Image?

    /// - Parameters:
    ///   - source: The site's name or domain, such as "medium.com".
    ///   - favicon: The fetched favicon, or nil to show the letter tile.
    public init(source: String, favicon: Image? = nil) {
        self.source = source
        self.favicon = favicon
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: LaterRadius.xs, style: .continuous)
        Group {
            if let favicon {
                favicon
                    .resizable()
                    .scaledToFill()
            } else {
                Text(Self.monogram(for: source))
                    .font(.laterUI(.tag, weight: .bold))
                    .foregroundStyle(LaterColor.Text.ink)
            }
        }
        .frame(width: LaterSize.favicon, height: LaterSize.favicon)
        .background(LaterColor.Control.fillPlaceholder)
        .clipShape(shape)
        .accessibilityHidden(true)
    }

    /// The letter for a site without a favicon: the first letter of its name, skipping "www.".
    nonisolated static func monogram(for source: String) -> String {
        let name = source.lowercased().hasPrefix("www.") ? source.dropFirst(4) : Substring(source)
        guard let letter = name.first(where: { $0.isLetter || $0.isNumber }) else {
            return "?"
        }
        return letter.uppercased()
    }
}
