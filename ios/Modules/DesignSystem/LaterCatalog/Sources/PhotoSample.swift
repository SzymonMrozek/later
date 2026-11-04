import LaterArticleRow
import LaterArticleThumb
import LaterButton
import LaterChip
import LaterColor
import LaterComparisonTable
import LaterDurationPicker
import LaterIconButton
import LaterListRow
import LaterMiniPlayer
import LaterNavBar
import LaterNotice
import LaterOptionCard
import LaterPlayerControls
import LaterPrepProgress
import LaterQueueRow
import LaterScrubber
import LaterSectionHeader
import LaterSegmentedControl
import LaterSessionBar
import LaterSheet
import LaterSourceIcon
import LaterStatusTag
import LaterStepIndicator
import LaterTabBar
import LaterTextField
import LaterWordmark
import SwiftUI
import UIKit

/// A stand-in lead image: a gradient, so glass and images can be judged over content.
enum PhotoSample {
    @MainActor static let image: Image = {
        let colors = [LaterColor.Accent.queue3, LaterColor.Accent.base, LaterColor.Status.warning]
            .map { UIColor($0).cgColor } as CFArray
        let size = CGSize(width: 400, height: 260)
        let photo = UIGraphicsImageRenderer(size: size).image { context in
            guard let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil) else {
                return
            }
            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
        return Image(uiImage: photo)
    }()
}
