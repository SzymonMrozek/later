import LaterColor
import LaterGlass
import LaterRadius
import LaterShadow
import LaterSize
import LaterSpacing
import LaterStroke
import LaterTypography
import SwiftUI

enum TokenPage: String, CaseIterable, Identifiable {
    case color
    case typography
    case spacing
    case radius
    case size
    case strokeAndShadow
    case glass

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .color: "Color"
        case .typography: "Typography"
        case .spacing: "Spacing"
        case .radius: "Radius"
        case .size: "Size"
        case .strokeAndShadow: "Stroke and shadow"
        case .glass: "Glass"
        }
    }

    @ViewBuilder var content: some View {
        switch self {
        case .color: ColorTokens()
        case .typography: TypographyTokens()
        case .spacing: NumberTokens(tokens: Self.spacingTokens) { value in
                Rectangle().fill(LaterColor.Accent.base).frame(width: max(value, 1), height: 16)
            }
        case .radius: NumberTokens(tokens: Self.radiusTokens) { value in
                RoundedRectangle(cornerRadius: min(value, 28), style: .continuous)
                    .fill(LaterColor.Accent.soft)
                    .stroke(LaterColor.Accent.base, lineWidth: LaterStroke.default)
                    .frame(width: 56, height: 56)
            }
        case .size: NumberTokens(tokens: Self.sizeTokens) { value in
                Rectangle().fill(LaterColor.Accent.base).frame(width: min(value, 220), height: 10)
            }
        case .strokeAndShadow: StrokeAndShadowTokens()
        case .glass: GlassTokens()
        }
    }

    private static let spacingTokens: [(String, CGFloat)] = [
        ("space.none", LaterSpacing.none), ("space.half", LaterSpacing.half), ("space.1", LaterSpacing.one),
        ("space.2", LaterSpacing.two), ("space.3", LaterSpacing.three), ("space.4", LaterSpacing.four),
        ("space.5", LaterSpacing.five), ("space.6", LaterSpacing.six), ("space.8", LaterSpacing.eight),
    ]

    private static let radiusTokens: [(String, CGFloat)] = [
        ("radius.xs", LaterRadius.xs), ("radius.sm", LaterRadius.sm), ("radius.md", LaterRadius.md),
        ("radius.lg", LaterRadius.lg), ("radius.sheet", LaterRadius.sheet), ("radius.pill", LaterRadius.pill),
    ]

    private static let sizeTokens: [(String, CGFloat)] = [
        ("size.tap", LaterSize.tap), ("size.buttonLarge", LaterSize.buttonLarge),
        ("size.playButton", LaterSize.playButton), ("size.row", LaterSize.row), ("size.favicon", LaterSize.favicon),
        ("size.thumbSmall", LaterSize.thumbSmall), ("size.thumbMedium", LaterSize.thumbMedium),
        ("size.thumbLarge", LaterSize.thumbLarge), ("size.hero", LaterSize.hero), ("size.track", LaterSize.track),
        ("size.sessionBar", LaterSize.sessionBar), ("size.stripe", LaterSize.stripe), ("size.dot", LaterSize.dot),
        ("size.dotActive", LaterSize.dotActive), ("size.grabberWidth", LaterSize.grabberWidth),
        ("size.grabberHeight", LaterSize.grabberHeight), ("size.tableColumn", LaterSize.tableColumn),
    ]
}

private struct ColorTokens: View {
    private let groups: [(String, [(String, Color)])] = [
        ("color.ground", [
            ("bg", LaterColor.Ground.bg), ("bgGrouped", LaterColor.Ground.bgGrouped),
            ("surface", LaterColor.Ground.surface),
        ]),
        ("color.control", [
            ("fill", LaterColor.Control.fill), ("fillPlaceholder", LaterColor.Control.fillPlaceholder),
            ("fillSelected", LaterColor.Control.fillSelected), ("line", LaterColor.Control.line),
            ("lineDashed", LaterColor.Control.lineDashed), ("hairline", LaterColor.Control.hairline),
        ]),
        ("color.text", [
            ("ink", LaterColor.Text.ink), ("inkMuted", LaterColor.Text.inkMuted),
            ("inkFaint", LaterColor.Text.inkFaint), ("onInk", LaterColor.Text.onInk),
        ]),
        ("color.accent", [
            ("base", LaterColor.Accent.base), ("on", LaterColor.Accent.on), ("soft", LaterColor.Accent.soft),
            ("queue2", LaterColor.Accent.queue2), ("queue3", LaterColor.Accent.queue3),
            ("focus", LaterColor.Accent.focus),
        ]),
        ("color.status", [
            ("positive", LaterColor.Status.positive), ("positiveSoft", LaterColor.Status.positiveSoft),
            ("warning", LaterColor.Status.warning), ("warningSoft", LaterColor.Status.warningSoft),
            ("danger", LaterColor.Status.danger),
        ]),
        ("color.glass", [
            ("base", LaterColor.Glass.base), ("stroke", LaterColor.Glass.stroke),
            ("selected", LaterColor.Glass.selected),
        ]),
        ("color.overlay", [
            ("clear", LaterColor.Overlay.clear), ("scrim", LaterColor.Overlay.scrim),
            ("shadowControl", LaterColor.Overlay.shadowControl), ("shadowFloat", LaterColor.Overlay.shadowFloat),
            ("shadowGlass", LaterColor.Overlay.shadowGlass),
        ]),
    ]

    var body: some View {
        ForEach(groups, id: \.0) { group, colors in
            Specimen(label: group) {
                ForEach(colors, id: \.0) { name, color in
                    HStack(spacing: 12) {
                        swatch(color, scheme: .light)
                        swatch(color, scheme: .dark)
                        Text(name)
                            .font(.laterUI(.body))
                            .foregroundStyle(LaterColor.Text.ink)
                    }
                }
            }
        }
    }

    /// The color as it resolves in `scheme`, on that scheme's background, whatever the catalog's appearance.
    private func swatch(_ color: Color, scheme: ColorScheme) -> some View {
        RoundedRectangle(cornerRadius: LaterRadius.sm, style: .continuous)
            .fill(color)
            .frame(width: 44, height: 32)
            .padding(4)
            .background(LaterColor.Ground.bg, in: RoundedRectangle(cornerRadius: LaterRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LaterRadius.md, style: .continuous)
                    .stroke(LaterColor.Control.line, lineWidth: LaterStroke.default)
            )
            .environment(\.colorScheme, scheme)
    }
}

private struct TypographyTokens: View {
    var body: some View {
        Specimen(label: "type.ui · Instrument Sans") {
            ForEach(LaterTypography.UI.allCases, id: \.self) { style in
                VStack(alignment: .leading, spacing: 2) {
                    Text("How much time do you have?")
                        .font(.laterUI(style))
                        .foregroundStyle(LaterColor.Text.ink)
                    Text(verbatim: "\(style)")
                        .font(.laterUI(.caption))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
            }
        }
        Specimen(label: "Weights") {
            ForEach([Font.Weight.regular, .medium, .semibold, .bold], id: \.self) { weight in
                Text("Listen · 19 min")
                    .font(.laterUI(.headline, weight: weight))
                    .foregroundStyle(LaterColor.Text.ink)
            }
        }
        Specimen(label: "type.article · Source Serif 4") {
            ForEach(LaterTypography.Article.allCases, id: \.self) { style in
                VStack(alignment: .leading, spacing: 2) {
                    Text("Why cities are quietly getting cooler at night")
                        .font(.laterArticle(style))
                        .foregroundStyle(LaterColor.Text.ink)
                    Text(verbatim: "\(style)")
                        .font(.laterUI(.caption))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
            }
        }
    }
}

private struct NumberTokens<Sample: View>: View {
    let tokens: [(String, CGFloat)]
    @ViewBuilder let sample: (CGFloat) -> Sample

    var body: some View {
        ForEach(tokens, id: \.0) { name, value in
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.laterUI(.body, weight: .medium))
                    Text(value, format: .number)
                        .font(.laterUI(.caption))
                        .foregroundStyle(LaterColor.Text.inkMuted)
                }
                .foregroundStyle(LaterColor.Text.ink)
                .frame(width: 140, alignment: .leading)
                sample(value)
            }
        }
    }
}

private struct StrokeAndShadowTokens: View {
    var body: some View {
        Specimen(label: "stroke") {
            HStack(spacing: 16) {
                shape.stroke(LaterColor.Control.line, lineWidth: LaterStroke.default)
                    .frame(width: 96, height: 56)
                    .overlay { caption("default") }
                shape.stroke(LaterColor.Accent.base, lineWidth: LaterStroke.selected)
                    .frame(width: 96, height: 56)
                    .overlay { caption("selected") }
                shape.stroke(
                    LaterColor.Control.lineDashed,
                    style: StrokeStyle(lineWidth: LaterStroke.default, dash: LaterStroke.dash)
                )
                .frame(width: 96, height: 56)
                .overlay { caption("dash") }
            }
        }
        Specimen(label: "shadow") {
            HStack(spacing: 20) {
                let shadows = [("control", LaterShadow.control), ("float", .float), ("glass", .glass)]
                ForEach(shadows, id: \.0) { name, shadow in
                    shape.fill(LaterColor.Ground.surface)
                        .laterShadow(shadow)
                        .frame(width: 88, height: 56)
                        .overlay { caption(name) }
                }
            }
            .padding(.vertical, 12)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: LaterRadius.lg, style: .continuous)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.laterUI(.caption, weight: .medium))
            .foregroundStyle(LaterColor.Text.inkMuted)
    }
}

private struct GlassTokens: View {
    var body: some View {
        Specimen(label: "laterGlass · system Liquid Glass on iOS 26, color.glass.* before") {
            ZStack {
                PhotoSample.image
                    .resizable()
                    .frame(height: 160)
                HStack(spacing: 16) {
                    Text("Capsule")
                        .font(.laterUI(.callout, weight: .medium))
                        .foregroundStyle(LaterColor.Text.ink)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .laterGlass(in: Capsule())
                    Image(systemName: "pause.fill")
                        .font(.laterUI(.titleSmall, weight: .semibold))
                        .foregroundStyle(LaterColor.Text.ink)
                        .frame(width: 54, height: 54)
                        .laterGlass(in: Circle(), isInteractive: true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: LaterRadius.lg, style: .continuous))
        }
    }
}
