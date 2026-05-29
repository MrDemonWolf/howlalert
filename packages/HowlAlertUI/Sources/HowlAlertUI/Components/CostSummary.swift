import SwiftUI

public struct CostStat: Identifiable, Sendable {
    public let id = UUID()
    public let label: String
    public let value: String
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

/// 2×2 cost / stat grid.
public struct CostSummary: View {
    private let stats: [CostStat]

    public init(_ stats: [CostStat]) { self.stats = stats }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HowlSpacing.s3) {
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: HowlSpacing.s1) {
                    Text(stat.value)
                        .font(HowlTypography.numeric(size: 18, weight: .semibold))
                        .foregroundStyle(HowlColor.ink100)
                    Text(stat.label)
                        .font(HowlTypography.micro)
                        .foregroundStyle(HowlColor.ink500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HowlSpacing.s3)
                .background(HowlColor.navy800, in: RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous))
            }
        }
    }
}
