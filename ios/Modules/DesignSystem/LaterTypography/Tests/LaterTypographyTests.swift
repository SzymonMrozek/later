@testable import LaterTypography
import SwiftUI
import Testing
import UIKit

struct LaterTypographyTests {
    @Test(arguments: [LaterTypography.uiFamily, LaterTypography.articleFamily])
    func registersBundledFamily(_ family: String) {
        LaterFonts.register()
        #expect(UIFont.familyNames.contains(family))
    }

    @Test func mapsUIStylesToDynamicType() {
        #expect(LaterTypography.UI.display.textStyle == .largeTitle)
        #expect(LaterTypography.UI.body.textStyle == .subheadline)
        #expect(LaterTypography.UI.bodyLarge.textStyle == .callout)
        #expect(LaterTypography.UI.tag.textStyle == .caption2)
    }

    @Test func mapsArticleStylesToDynamicType() {
        #expect(LaterTypography.Article.h1.textStyle == .title)
        #expect(LaterTypography.Article.title.textStyle == .body)
        #expect(LaterTypography.Article.spoken.textStyle == .title3)
    }

    @Test func headlineIsSemiboldByDefault() {
        #expect(Font.TextStyle.headline.weight == .semibold)
        #expect(Font.TextStyle.body.weight == .regular)
    }
}
