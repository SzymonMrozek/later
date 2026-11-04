import CoreText
import SwiftUI

/// The `type.*` tokens from design/Later.canvas. Each style scales with a Dynamic Type text style.
///
/// `UI` styles are Instrument Sans and cover everything except the article itself. `Article` styles
/// are Source Serif 4 and are only for article titles and article text. Weight belongs to the text,
/// so styles take one; leaving it out uses the style's own weight.
public enum LaterTypography {
    public enum UI: CaseIterable, Sendable {
        case display
        case title
        case titleSmall
        case numeral
        case headline
        case bodyLarge
        case body
        case callout
        case footnote
        case caption
        case eyebrow
        case tag

        var textStyle: Font.TextStyle {
            switch self {
            case .display: .largeTitle
            case .title, .numeral: .title
            case .titleSmall: .title2
            case .headline: .headline
            case .bodyLarge: .callout
            case .body, .callout: .subheadline
            case .footnote: .footnote
            case .caption, .eyebrow: .caption
            case .tag: .caption2
            }
        }
    }

    public enum Article: CaseIterable, Sendable {
        case h1
        case h2
        case spoken
        case title
        case body

        var textStyle: Font.TextStyle {
            switch self {
            case .h1: .title
            case .h2: .title2
            case .spoken: .title3
            case .title, .body: .body
            }
        }
    }

    nonisolated static let uiFamily = "Instrument Sans"
    nonisolated static let articleFamily = "Source Serif 4"
}

public extension Font {
    /// Instrument Sans in a UI style, for everything that isn't the article's own title or text.
    static func laterUI(_ style: LaterTypography.UI, weight: Font.Weight? = nil) -> Font {
        LaterFonts.register()
        let font = Font.custom(LaterTypography.uiFamily, size: style.textStyle.size, relativeTo: style.textStyle)
        return font.weight(weight ?? style.textStyle.weight)
    }

    /// Source Serif 4 in an article style, only for article titles and article text.
    static func laterArticle(_ style: LaterTypography.Article, weight: Font.Weight? = nil) -> Font {
        LaterFonts.register()
        let font = Font.custom(LaterTypography.articleFamily, size: style.textStyle.size, relativeTo: style.textStyle)
        return font.weight(weight ?? style.textStyle.weight)
    }
}

extension Font.TextStyle {
    /// The point size at the default Dynamic Type size (Large); the font scales from here.
    var size: CGFloat {
        switch self {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }

    var weight: Font.Weight {
        self == .headline ? .semibold : .regular
    }
}

/// Registers the bundled fonts with the process the first time a style is used, so callers
/// never set fonts up themselves.
enum LaterFonts {
    static let files = ["InstrumentSans", "SourceSerif4"]

    static func register() {
        _ = registration
    }

    private static let registration: Void = {
        for file in files {
            guard let url = Bundle.module.url(forResource: file, withExtension: "ttf") else {
                assertionFailure("Missing font \(file).ttf in LaterTypography's resources")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()
}
