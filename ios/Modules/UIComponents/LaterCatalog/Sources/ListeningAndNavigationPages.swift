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

struct SessionBarPage: View {
    var body: some View {
        Specimen(label: "3 + 12 + 4 min of 20") { LaterSessionBar(lengths: [3, 12, 4], available: 20) }
        Specimen(label: "3 + 12 + 4 min of 30") { LaterSessionBar(lengths: [3, 12, 4], available: 30) }
        Specimen(label: "Over: 20 + 15 min of 30") { LaterSessionBar(lengths: [20, 15], available: 30) }
    }
}

struct ScrubberPage: View {
    @State private var elapsed: TimeInterval = 760

    var body: some View {
        Specimen(label: "Drag to seek") {
            LaterScrubber(elapsed: elapsed, duration: 1280) { elapsed = $0 }
        }
    }
}

struct PlayerControlsPage: View {
    @State private var isPlaying = true

    var body: some View {
        Specimen(label: "Tap play to toggle") {
            LaterPlayerControls(isPlaying: isPlaying, onSkipBack: {}, onPlayPause: { isPlaying.toggle() }, onNext: {})
                .frame(maxWidth: .infinity)
        }
    }
}

struct MiniPlayerPage: View {
    @State private var isPlaying = true

    var body: some View {
        Specimen(label: "On the background") {
            LaterMiniPlayer(
                title: "The hidden cost of always-on notifications",
                subtitle: "Session · 12:40 left",
                isPlaying: isPlaying,
                onOpen: {},
                onPlayPause: { isPlaying.toggle() }
            )
        }
        Specimen(label: "Over content") {
            LaterMiniPlayer(
                title: "Why cities are quietly getting cooler at night",
                subtitle: "Session · 4:10 left",
                image: PhotoSample.image,
                isPlaying: isPlaying,
                onOpen: {},
                onPlayPause: { isPlaying.toggle() }
            )
            .padding(12)
            .background(PhotoSample.image.resizable())
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct NavBarPage: View {
    var body: some View {
        Specimen(label: "Kicker, title and two buttons") {
            LaterNavBar(
                title: "2 of 3",
                kicker: "Session",
                leading: LaterIconButton("Close", systemImage: "chevron.down") {},
                trailing: LaterIconButton("More", systemImage: "ellipsis") {}
            )
        }
        Specimen(label: "Leading only") {
            LaterNavBar(title: "Queue", leading: LaterIconButton("Back", systemImage: "chevron.left") {})
        }
    }
}

private enum SampleTab: Hashable {
    case now
    case library
    case settings
}

struct TabBarPage: View {
    @State private var tab = SampleTab.now

    var body: some View {
        Specimen(label: "Tap to switch") {
            LaterTabBar(selection: $tab, items: [
                .init(.now, title: "Now", systemImage: "clock", selectedSystemImage: "clock.fill"),
                .init(.library, title: "Library", systemImage: "book", selectedSystemImage: "book.fill"),
                .init(.settings, title: "Settings", systemImage: "slider.horizontal.3"),
            ])
        }
    }
}

struct StepIndicatorPage: View {
    @State private var step = 0

    var body: some View {
        Specimen(label: "Tap to advance") {
            LaterStepIndicator(count: 3, current: step)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture { step = (step + 1) % 3 }
        }
    }
}

struct NoticePage: View {
    var body: some View {
        Specimen(label: "Info") {
            LaterNotice(
                "Summary · 3 points",
                message: "Green roofs give off heat faster after dark, so the streets below cool sooner.",
                variant: .info,
                systemImage: "text.alignleft"
            )
        }
        Specimen(label: "Warning") {
            LaterNotice(
                "Only the beginning was fetched",
                message: """
                The rest of the article is behind a login. We have 4 paragraphs, so a summary would be incomplete.
                """,
                variant: .warning
            )
        }
    }
}

struct SheetPage: View {
    @State private var isPresented = false
    @State private var categories: Set<String> = ["Science"]

    var body: some View {
        Specimen(label: "Presented as a system sheet") {
            LaterButton("Show sheet", variant: .secondary) { isPresented = true }
        }
        .sheet(isPresented: $isPresented) {
            LaterSheet("Categories", actionTitle: "Cancel", action: { isPresented = false }, content: {
                HStack {
                    ForEach(["Science", "City"], id: \.self) { title in
                        LaterChip(title, variant: categories.contains(title) ? .selected : .default) {
                            categories.formSymmetricDifference([title])
                        }
                    }
                    LaterChip("Add", variant: .add) {}
                }
                LaterButton("Save") { isPresented = false }
            })
            .presentationDetents([.height(240)])
            .laterSheetPresentation()
        }
    }
}
