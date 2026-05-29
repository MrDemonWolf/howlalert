import SwiftUI

/// Two-card pricing selector. Annual (Max) is default-selected with a "BEST VALUE" ribbon
/// + save chip — per the paywall spec (no third option).
public struct PricingToggle: View {
    @Binding private var annual: Bool
    private let monthlyTitle: String
    private let monthlyPrice: String
    private let annualTitle: String
    private let annualPrice: String
    private let saveText: String

    public init(
        annual: Binding<Bool>,
        monthlyTitle: String = "HowlAlert Pro",
        monthlyPrice: String = "$4.99 / mo",
        annualTitle: String = "HowlAlert Max",
        annualPrice: String = "$29.99 / yr",
        saveText: String = "Save $30 vs Pro"
    ) {
        self._annual = annual
        self.monthlyTitle = monthlyTitle
        self.monthlyPrice = monthlyPrice
        self.annualTitle = annualTitle
        self.annualPrice = annualPrice
        self.saveText = saveText
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s3) {
            card(title: monthlyTitle, price: monthlyPrice, selected: !annual, ribbon: nil) { annual = false }
            card(title: annualTitle, price: annualPrice, selected: annual, ribbon: "BEST VALUE") { annual = true }
        }
    }

    @ViewBuilder
    private func card(title: String, price: String, selected: Bool, ribbon: String?, tap: @escaping () -> Void) -> some View {
        let border: Color = selected ? HowlColor.cyan500 : HowlColor.navy600
        VStack(alignment: .leading, spacing: HowlSpacing.s2) {
            if let ribbon {
                Text(ribbon)
                    .font(HowlTypography.micro)
                    .foregroundStyle(HowlColor.navy900)
                    .padding(.horizontal, HowlSpacing.s2)
                    .padding(.vertical, 2)
                    .background(HowlColor.cyan500, in: Capsule())
            }
            Text(title).font(HowlTypography.callout).foregroundStyle(HowlColor.ink100)
            Text(price).font(HowlTypography.numeric(size: 18, weight: .semibold)).foregroundStyle(HowlColor.ink100)
            if ribbon != nil {
                Text(saveText).font(HowlTypography.micro).foregroundStyle(HowlColor.stateFresh)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HowlSpacing.s4)
        .background(HowlColor.navy800, in: RoundedRectangle(cornerRadius: HowlRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HowlRadius.lg, style: .continuous)
                .strokeBorder(border, lineWidth: selected ? 2 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: HowlRadius.lg, style: .continuous))
        .onTapGesture { withAnimation(HowlMotion.spring) { tap() } }
    }
}
