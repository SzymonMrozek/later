import LaterColor
import LaterRadius
import LaterSize
import LaterSpacing
import LaterStroke
import LaterTypography
import SwiftUI

/// `ComparisonTable` from design/Later.canvas: plans side by side, one row per feature.
/// The highlighted column is the plan on offer: its heading takes the accent and its values read as ink.
public struct LaterComparisonTable: View {
    public struct Column: Hashable, Sendable {
        public let title: String
        public let isHighlighted: Bool

        public init(_ title: String, isHighlighted: Bool = false) {
            self.title = title
            self.isHighlighted = isHighlighted
        }
    }

    public struct Row: Hashable, Sendable {
        public let label: String
        /// One value per column, in column order.
        public let values: [String]

        public init(_ label: String, values: [String]) {
            self.label = label
            self.values = values
        }
    }

    private let title: String
    private let columns: [Column]
    private let rows: [Row]

    public init(title: String, columns: [Column], rows: [Row]) {
        self.title = title
        self.columns = columns
        self.rows = rows
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: LaterRadius.lg, style: .continuous)
        VStack(spacing: LaterSpacing.none) {
            header
            ForEach(rows, id: \.self) { row in
                Rectangle()
                    .fill(LaterColor.Control.hairline)
                    .frame(height: LaterStroke.default)
                line(row)
            }
        }
        .background(LaterColor.Ground.surface)
        .clipShape(shape)
        .overlay(shape.strokeBorder(LaterColor.Control.line, lineWidth: LaterStroke.default))
    }

    private var header: some View {
        HStack(spacing: LaterSpacing.none) {
            Text(title)
                .foregroundStyle(LaterColor.Text.inkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(columns, id: \.self) { column in
                Text(column.title)
                    .foregroundStyle(column.isHighlighted ? LaterColor.Accent.base : LaterColor.Text.ink)
                    .frame(width: LaterSize.tableColumn, alignment: .leading)
            }
        }
        .font(.laterUI(.footnote, weight: .semibold))
        .padding(.horizontal, LaterSpacing.four)
        .padding(.vertical, LaterSpacing.three)
        .background(LaterColor.Ground.bgGrouped)
        .accessibilityElement(children: .combine)
    }

    private func line(_ row: Row) -> some View {
        HStack(spacing: LaterSpacing.none) {
            Text(row.label)
                .foregroundStyle(LaterColor.Text.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(Array(zip(columns, row.values)), id: \.0) { column, value in
                Text(value)
                    .foregroundStyle(column.isHighlighted ? LaterColor.Text.ink : LaterColor.Text.inkMuted)
                    .frame(width: LaterSize.tableColumn, alignment: .leading)
            }
        }
        .font(.laterUI(.body))
        .padding(.horizontal, LaterSpacing.four)
        .padding(.vertical, LaterSpacing.three)
        .accessibilityElement(children: .combine)
    }
}
