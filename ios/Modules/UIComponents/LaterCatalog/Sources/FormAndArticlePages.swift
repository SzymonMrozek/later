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

struct TextFieldPage: View {
    @State private var email = ""
    @State private var query = ""

    var body: some View {
        Specimen(label: "Default") {
            LaterTextField(text: $email, prompt: "you@example.com", variant: .labeled("Email"))
        }
        Specimen(label: "Search") {
            LaterTextField(text: $query, prompt: "Search titles and text", variant: .search)
        }
    }
}

struct ListRowPage: View {
    @State private var wifiOnly = true

    var body: some View {
        Specimen(label: "In a system inset grouped list, with the system toggle") {
            List {
                LaterListRow("Languages", value: "Polish, English")
                LaterListRow("Voice", value: "Neural")
                Toggle("Download on Wi‑Fi only", isOn: $wifiOnly)
                    .font(.laterUI(.bodyLarge))
            }
            .listStyle(.insetGrouped)
            .scrollDisabled(true)
            .frame(height: 220)
        }
    }
}

struct SectionHeaderPage: View {
    var body: some View {
        Specimen(label: "With action") { LaterSectionHeader("In this session · 19 min", actionTitle: "Edit") {} }
        Specimen(label: "Plain") { LaterSectionHeader("Saved this week") }
    }
}

struct ComparisonTablePage: View {
    var body: some View {
        Specimen(label: "Plans") {
            LaterComparisonTable(
                title: "Plan",
                columns: [.init("Free"), .init("Later+", isHighlighted: true)],
                rows: [
                    .init("Summaries", values: ["[LIMIT]", "unlimited"]),
                    .init("Full articles", values: ["[LIMIT]", "unlimited"]),
                    .init("Voice", values: ["system", "neural"]),
                    .init("Offline", values: ["—", "yes"]),
                ]
            )
        }
    }
}

struct SourceIconPage: View {
    var body: some View {
        Specimen(label: "Letter tile") {
            HStack {
                LaterSourceIcon(source: "medium.com")
                LaterSourceIcon(source: "www.nytimes.com")
                LaterSourceIcon(source: "arstechnica.com")
            }
        }
        Specimen(label: "Favicon") {
            LaterSourceIcon(source: "later", favicon: Image(systemName: "globe"))
        }
    }
}

struct StatusTagPage: View {
    var body: some View {
        Specimen(label: "Accent · Positive · Neutral · Warning") {
            HStack {
                LaterStatusTag("in progress", variant: .accent)
                LaterStatusTag("offline", variant: .positive)
                LaterStatusTag("new", variant: .neutral)
                LaterStatusTag("partial", variant: .warning)
            }
        }
    }
}

struct ArticleThumbPage: View {
    var body: some View {
        Specimen(label: "Small · Medium · Large, placeholder") {
            HStack(alignment: .top) {
                ForEach([LaterArticleThumb.Size.small, .medium, .large], id: \.self) { size in
                    LaterArticleThumb(image: nil, size: size)
                }
            }
        }
        Specimen(label: "Large: image · favicon fallback") {
            HStack {
                LaterArticleThumb(image: PhotoSample.image, size: .large)
                LaterArticleThumb(image: nil, favicon: Image(systemName: "globe"), size: .large)
            }
        }
        Specimen(label: "Hero") { LaterArticleThumb(image: PhotoSample.image, size: .hero) }
        Specimen(label: "Hero, placeholder") { LaterArticleThumb(image: nil, size: .hero) }
    }
}

struct ArticleRowPage: View {
    var body: some View {
        Specimen(label: "Preparing") {
            LaterArticleRow(
                title: "The hidden cost of always-on notifications",
                source: "medium.com",
                details: "summary 3 min · full 24 min",
                status: LaterStatusTag("in progress", variant: .accent)
            )
        }
        Specimen(label: "Offline, with image") {
            LaterArticleRow(
                title: "Why cities are quietly getting cooler at night",
                source: "theatlantic.com",
                details: "summary 4 min · full 18 min",
                image: PhotoSample.image,
                status: LaterStatusTag("offline", variant: .positive)
            )
        }
        Specimen(label: "No status") {
            LaterArticleRow(
                title: "A short history of the semicolon",
                source: "www.newyorker.com",
                details: "summary 2 min · full 9 min"
            )
        }
    }
}

struct QueueRowPage: View {
    var body: some View {
        Specimen(label: "Positions 0, 1, 2") {
            LaterQueueRow(
                title: "Why cities are quietly getting cooler at night",
                form: "Summary • 3m",
                language: "PL",
                position: 0,
                image: PhotoSample.image
            )
            LaterQueueRow(
                title: "The hidden cost of always-on notifications",
                form: "Full • 12m",
                language: "PL",
                position: 1
            )
            LaterQueueRow(title: "A short history of the semicolon", form: "Summary • 4m", language: "EN", position: 2)
        }
    }
}

struct PrepProgressPage: View {
    var body: some View {
        Specimen(label: "Done · Running · Pending") {
            LaterPrepProgress(steps: [
                .init("Text fetched", state: .done),
                .init("Translating to Polish", state: .running),
                .init("Recording the voice", state: .pending),
            ])
        }
    }
}
