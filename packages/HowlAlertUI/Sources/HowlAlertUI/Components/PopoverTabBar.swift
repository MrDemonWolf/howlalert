import SwiftUI

/// Segmented icon tab bar (Overview / Now / Day / Week), glass-pill selection.
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
                tab(i)
            }
        }
        .padding(HowlSpacing.s1)
        .background(HowlColor.navy800, in: Capsule())
    }

    @ViewBuilder
    private func tab(_ i: Int) -> some View {
        let active = i == selection
        let fg: Color = active ? HowlColor.navy900 : HowlColor.ink300
        let bg: Color = active ? HowlColor.cyan500 : .clear
        Image(systemName: tabs[i])
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(fg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HowlSpacing.s2)
            .background(bg, in: Capsule())
            .contentShape(Capsule())
            .onTapGesture { withAnimation(HowlMotion.spring) { selection = i } }
    }
}
