import SwiftUI

/// Inset-grouped settings row — title + optional subtitle + arbitrary trailing control
/// (Toggle, pill-select, value label, chevron).
public struct SettingsRow<Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing

    public init(title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s3) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(HowlTypography.body).foregroundStyle(HowlColor.ink100)
                if let subtitle {
                    Text(subtitle).font(HowlTypography.caption).foregroundStyle(HowlColor.ink500)
                }
            }
            Spacer(minLength: HowlSpacing.s3)
            trailing
        }
        .padding(.horizontal, HowlSpacing.s4)
        .padding(.vertical, HowlSpacing.s3)
        .background(HowlColor.navy800, in: RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous))
    }
}

/// Pill-select control for SettingsRow trailing (refresh cadence, etc.).
public struct PillSelect: View {
    private let options: [String]
    @Binding private var selection: Int

    public init(options: [String], selection: Binding<Int>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s1) {
            ForEach(options.indices, id: \.self) { i in
                Text(options[i])
                    .font(HowlTypography.micro)
                    .foregroundStyle(i == selection ? HowlColor.navy900 : HowlColor.ink300)
                    .padding(.horizontal, HowlSpacing.s2)
                    .padding(.vertical, HowlSpacing.s1)
                    .background(i == selection ? HowlColor.cyan500 : Color.clear, in: Capsule())
                    .onTapGesture { withAnimation(HowlMotion.spring) { selection = i } }
            }
        }
        .padding(2)
        .background(HowlColor.navy700, in: Capsule())
    }
}
