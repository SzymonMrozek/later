import LaterColor
import LaterRadius
import LaterSize
import LaterTypography
import SwiftUI

/// `ArticleThumb/*` from design/Later.canvas: the article's lead image. Without one it shows the
/// site's favicon large on a grey tile, or a photo symbol when there's no favicon either.
public struct LaterArticleThumb: View {
    public enum Size: CaseIterable, Sendable {
        /// The mini player.
        case small
        /// Queue rows.
        case medium
        /// Library rows.
        case large
        /// The reader and the form choice, full width.
        case hero
    }

    private let image: Image?
    private let favicon: Image?
    private let size: Size

    public init(image: Image?, favicon: Image? = nil, size: Size) {
        self.image = image
        self.favicon = favicon
        self.size = size
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        Rectangle()
            .fill(LaterColor.Control.fillPlaceholder)
            .frame(width: side, height: side ?? LaterSize.hero)
            .frame(maxWidth: side == nil ? .infinity : nil)
            .overlay { content }
            .clipShape(shape)
            .accessibilityHidden(true)
    }

    @ViewBuilder private var content: some View {
        if let image {
            image
                .resizable()
                .scaledToFill()
        } else if let favicon {
            favicon
                .resizable()
                .scaledToFit()
                .frame(width: (side ?? LaterSize.thumbLarge) * 0.4)
        } else {
            Image(systemName: "photo")
                .font(placeholderFont)
                .foregroundStyle(LaterColor.Text.inkFaint)
        }
    }

    private var side: CGFloat? {
        switch size {
        case .small: LaterSize.thumbSmall
        case .medium: LaterSize.thumbMedium
        case .large: LaterSize.thumbLarge
        case .hero: nil
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: LaterRadius.sm
        case .medium, .large: LaterRadius.md
        case .hero: LaterRadius.lg
        }
    }

    private var placeholderFont: Font {
        switch size {
        case .small: .laterUI(.footnote, weight: .semibold)
        case .medium: .laterUI(.body, weight: .semibold)
        case .large: .laterUI(.bodyLarge, weight: .semibold)
        case .hero: .laterUI(.title, weight: .semibold)
        }
    }
}
