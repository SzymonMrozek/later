import LaterArticleThumb
import LaterColor
import LaterRadius
import LaterSize
import LaterSpacing
import LaterTypography
import SwiftUI

/// `QueueRow` from design/Later.canvas: an item in a listening session. Its stripe has the same
/// color as its segment in the session bar.
public struct LaterQueueRow: View {
    private let title: String
    private let form: String
    private let language: String
    private let position: Int
    private let image: Image?
    private let showsHandle: Bool

    /// - Parameters:
    ///   - form: The form and its length, such as "Summary • 3m".
    ///   - language: The language it plays in, such as "PL".
    ///   - position: Its place in the session, from 0, which picks its color.
    public init(
        title: String,
        form: String,
        language: String,
        position: Int,
        image: Image? = nil,
        showsHandle: Bool = true
    ) {
        self.title = title
        self.form = form
        self.language = language
        self.position = position
        self.image = image
        self.showsHandle = showsHandle
    }

    public var body: some View {
        HStack(spacing: LaterSpacing.three) {
            RoundedRectangle(cornerRadius: LaterRadius.xs, style: .continuous)
                .fill(LaterColor.Accent.session(position))
                .frame(width: LaterSize.stripe, height: LaterSize.thumbMedium)
            LaterArticleThumb(image: image, size: .medium)
            VStack(alignment: .leading, spacing: LaterSpacing.one) {
                Text(title)
                    .font(.laterArticle(.title))
                    .foregroundStyle(LaterColor.Text.ink)
                    .lineLimit(2)
                HStack(spacing: LaterSpacing.two) {
                    Text(form)
                        .font(.laterUI(.tag, weight: .semibold))
                        .foregroundStyle(LaterColor.Accent.base)
                        .padding(.horizontal, LaterSpacing.two)
                        .padding(.vertical, LaterSpacing.half)
                        .background(LaterColor.Accent.soft, in: Capsule())
                    Text(language)
                        .font(.laterUI(.caption, weight: .medium))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if showsHandle {
                Image(systemName: "line.3.horizontal")
                    .font(.laterUI(.body, weight: .semibold))
                    .foregroundStyle(LaterColor.Text.inkMuted)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
