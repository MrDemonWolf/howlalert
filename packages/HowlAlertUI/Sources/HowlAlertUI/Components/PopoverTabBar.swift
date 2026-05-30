import SwiftUI

/// Segmented tab bar for the popover — a text label per tab, cyan fill on the
/// selected one (matches the "Overview / 5-Hour / Weekly / Models" control in
/// section-b-macos.html). Selection is a bound index.
public struct PopoverTabBar: View {
    private let tabs: [String]
    @Binding private var selection: Int

    public init(tabs: [String], selection: Binding<Int>) {
        self.tabs = tabs
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s1) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(HowlMotion.spring) { selection = i }
                } label: {
                    Text(tabs[i])
                        .font(HowlTypography.micro)
                        .foregroundStyle(i == selection ? HowlColor.navy900 : HowlColor.ink500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HowlSpacing.s2)
                        .background(
                            i == selection ? HowlColor.cyan500 : Color.clear,
                            in: RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(i == selection ? [.isSelected, .isButton] : .isButton)
            }
        }
        .padding(HowlSpacing.s1)
        .background(HowlColor.navy800, in: RoundedRectangle(cornerRadius: HowlRadius.md + HowlSpacing.s1, style: .continuous))
    }
}

#Preview("PopoverTabBar") {
    StatefulPreview()
        .padding()
        .background(HowlColor.navy900)
}

private struct StatefulPreview: View {
    @State private var sel = 0
    var body: some View {
        PopoverTabBar(tabs: ["Overview", "5-Hour", "Weekly", "Models"], selection: $sel)
    }
}
