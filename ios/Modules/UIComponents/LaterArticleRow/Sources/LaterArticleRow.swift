import LaterArticleThumb
import LaterColor
import LaterSourceIcon
import LaterSpacing
import LaterStatusTag
import LaterTypography
import SwiftUI

/// `ArticleRow` from design/Later.canvas: a library row with the lead image, source, title,
/// both lengths and the article's state.
public struct LaterArticleRow: View {
    private let title: String
    private let source: String
    private let details: String
    private let image: Image?
    private let favicon: Image?
    private let status: LaterStatusTag?

    /// - Parameters:
    ///   - details: The lengths, such as "summary 3 min · full 24 min".
    public init(
        title: String,
        source: String,
        details: String,
        image: Image? = nil,
        favicon: Image? = nil,
        status: LaterStatusTag? = nil
    ) {
        self.title = title
        self.source = source
        self.details = details
        self.image = image
        self.favicon = favicon
        self.status = status
    }

    public var body: some View {
        HStack(alignment: .top, spacing: LaterSpacing.three) {
            LaterArticleThumb(image: image, favicon: favicon, size: .large)
            VStack(alignment: .leading, spacing: LaterSpacing.one) {
                HStack(spacing: LaterSpacing.two) {
                    LaterSourceIcon(source: source, favicon: favicon)
                    Text(source)
                        .font(.laterUI(.caption))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                        .lineLimit(1)
                }
                Text(title)
                    .font(.laterArticle(.title))
                    .foregroundStyle(LaterColor.Text.ink)
                    .lineLimit(3)
                HStack(spacing: LaterSpacing.two) {
                    Text(details)
                        .font(.laterUI(.footnote))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                    status
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}
