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

enum ComponentPage: String, CaseIterable, Identifiable {
    case button
    case iconButton
    case wordmark
    case chip
    case segmentedControl
    case durationPicker
    case optionCard
    case textField
    case listRow
    case sectionHeader
    case comparisonTable
    case sourceIcon
    case statusTag
    case articleThumb
    case articleRow
    case queueRow
    case prepProgress
    case sessionBar
    case scrubber
    case playerControls
    case miniPlayer
    case navBar
    case tabBar
    case stepIndicator
    case notice
    case sheet

    enum Section: CaseIterable {
        case actions
        case selection
        case formsAndLists
        case articles
        case listening
        case navigationAndFeedback

        var title: String {
            switch self {
            case .actions: "Actions"
            case .selection: "Selection"
            case .formsAndLists: "Forms and lists"
            case .articles: "Articles"
            case .listening: "Listening"
            case .navigationAndFeedback: "Navigation and feedback"
            }
        }
    }

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .button: "Button"
        case .iconButton: "IconButton"
        case .wordmark: "Wordmark"
        case .chip: "Chip"
        case .segmentedControl: "SegmentedControl"
        case .durationPicker: "DurationPicker"
        case .optionCard: "OptionCard"
        case .textField: "TextField"
        case .listRow: "ListRow"
        case .sectionHeader: "SectionHeader"
        case .comparisonTable: "ComparisonTable"
        case .sourceIcon: "SourceIcon"
        case .statusTag: "StatusTag"
        case .articleThumb: "ArticleThumb"
        case .articleRow: "ArticleRow"
        case .queueRow: "QueueRow"
        case .prepProgress: "PrepProgress"
        case .sessionBar: "SessionBar"
        case .scrubber: "Scrubber"
        case .playerControls: "PlayerControls"
        case .miniPlayer: "MiniPlayer"
        case .navBar: "NavBar"
        case .tabBar: "TabBar"
        case .stepIndicator: "StepIndicator"
        case .notice: "Notice"
        case .sheet: "Sheet"
        }
    }

    var section: Section {
        switch self {
        case .button, .iconButton, .wordmark: .actions
        case .chip, .segmentedControl, .durationPicker, .optionCard: .selection
        case .textField, .listRow, .sectionHeader, .comparisonTable: .formsAndLists
        case .sourceIcon, .statusTag, .articleThumb, .articleRow, .queueRow, .prepProgress: .articles
        case .sessionBar, .scrubber, .playerControls, .miniPlayer: .listening
        case .navBar, .tabBar, .stepIndicator, .notice, .sheet: .navigationAndFeedback
        }
    }

    @MainActor @ViewBuilder var content: some View {
        switch self {
        case .button: ButtonPage()
        case .iconButton: IconButtonPage()
        case .wordmark: Specimen(label: "Wordmark") { LaterWordmark() }
        case .chip: ChipPage()
        case .segmentedControl: SegmentedControlPage()
        case .durationPicker: DurationPickerPage()
        case .optionCard: OptionCardPage()
        case .textField: TextFieldPage()
        case .listRow: ListRowPage()
        case .sectionHeader: SectionHeaderPage()
        case .comparisonTable: ComparisonTablePage()
        case .sourceIcon: SourceIconPage()
        case .statusTag: StatusTagPage()
        case .articleThumb: ArticleThumbPage()
        case .articleRow: ArticleRowPage()
        case .queueRow: QueueRowPage()
        case .prepProgress: PrepProgressPage()
        case .sessionBar: SessionBarPage()
        case .scrubber: ScrubberPage()
        case .playerControls: PlayerControlsPage()
        case .miniPlayer: MiniPlayerPage()
        case .navBar: NavBarPage()
        case .tabBar: TabBarPage()
        case .stepIndicator: StepIndicatorPage()
        case .notice: NoticePage()
        case .sheet: SheetPage()
        }
    }
}
