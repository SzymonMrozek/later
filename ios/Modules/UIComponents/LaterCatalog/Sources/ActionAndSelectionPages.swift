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

struct ButtonPage: View {
    var body: some View {
        Specimen(label: "Primary") { LaterButton("Listen · 19 min", systemImage: "play.fill") {} }
        Specimen(label: "Secondary") { LaterButton("Add to queue", variant: .secondary) {} }
        Specimen(label: "Ink") { LaterButton("Continue with Apple", systemImage: "apple.logo", variant: .ink) {} }
        Specimen(label: "Quiet") { LaterButton("Try without an account", variant: .quiet) {} }
        Specimen(label: "Destructive") { LaterButton("Delete account and data", variant: .destructive) {} }
        Specimen(label: "Disabled") { LaterButton("Listen · 19 min") {}.disabled(true) }
        Specimen(label: "Loading") {
            LaterButton("Continue with Apple", systemImage: "apple.logo", variant: .ink, isLoading: true) {}
            LaterButton("Try without an account", variant: .quiet, isLoading: true) {}
        }
    }
}

struct IconButtonPage: View {
    var body: some View {
        Specimen(label: "Glass") {
            HStack {
                LaterIconButton("Close", systemImage: "xmark") {}
                LaterIconButton("Back", systemImage: "chevron.left") {}
                LaterIconButton("More", systemImage: "ellipsis") {}
            }
        }
        Specimen(label: "Glass over content") {
            HStack {
                LaterIconButton("Close", systemImage: "xmark") {}
                Spacer()
                LaterIconButton("More", systemImage: "ellipsis") {}
            }
            .padding(12)
            .background(PhotoSample.image.resizable())
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        Specimen(label: "Tonal") { LaterIconButton("Add", systemImage: "plus", variant: .tonal) {} }
    }
}

struct ChipPage: View {
    @State private var selected: Set<String> = ["Science"]

    var body: some View {
        Specimen(label: "Default and Selected · tap to toggle") {
            HStack {
                ForEach(["All", "Science", "City"], id: \.self) { title in
                    LaterChip(title, variant: selected.contains(title) ? .selected : .default) {
                        selected.formSymmetricDifference([title])
                    }
                }
            }
        }
        Specimen(label: "Language") {
            HStack {
                LaterChip("Polish", variant: .language(isMain: true)) {}
                LaterChip("English", variant: .language(isMain: false)) {}
            }
        }
        Specimen(label: "Add") { LaterChip("Add", variant: .add) {} }
    }
}

struct SegmentedControlPage: View {
    @State private var speed = 1.25

    var body: some View {
        Specimen(label: "Speed presets") {
            LaterSegmentedControl(selection: $speed, options: [1.0, 1.1, 1.25, 1.5]) { speed in
                speed.formatted(.number.precision(.fractionLength(speed == 1.25 ? 2 : 1))) + "×"
            }
        }
    }
}

struct DurationPickerPage: View {
    @State private var minutes = 20

    var body: some View {
        Specimen(label: "Selected: \(minutes) min") {
            LaterDurationPicker(minutes: $minutes)
        }
    }
}

struct OptionCardPage: View {
    @State private var isSummary = true

    var body: some View {
        Specimen(label: "Default and Selected · tap to choose") {
            LaterOptionCard(
                title: "Summary",
                subtitle: "key points, numbers, caveats",
                minutes: 3,
                isSelected: isSummary
            ) { isSummary = true }
            LaterOptionCard(
                title: "Full article",
                subtitle: "the whole text, translated",
                minutes: 12,
                isSelected: !isSummary
            ) { isSummary = false }
        }
    }
}
