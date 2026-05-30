import SwiftUI

/// Menu footer row — SF Symbol + label + optional ⌘-shortcut. `.danger` for Quit.
///
/// A real `Button` (not a tap gesture) so it gets native hover highlight,
/// keyboard activation, and accessibility for free. Attach `.keyboardShortcut`
/// at the call site for the actual key binding.
public struct MenuActionRow: View {
    private let systemImage: String
    private let label: String
    private let shortcut: String?
    private let danger: Bool
    private let help: String?
    private let action: () -> Void

    @State private var hovering = false

    public init(
        systemImage: String,
        label: String,
        shortcut: String? = nil,
        danger: Bool = false,
        help: String? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.systemImage = systemImage
        self.label = label
        self.shortcut = shortcut
        self.danger = danger
        self.help = help
        self.action = action
    }

    private var tint: Color { danger ? HowlColor.stateCrit : HowlColor.ink100 }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: HowlSpacing.s3) {
                Image(systemName: systemImage)
                    .font(.system(size: 13))
                    .frame(width: 18)
                    .foregroundStyle(danger ? HowlColor.stateCrit : HowlColor.ink300)
                Text(label)
                    .font(HowlTypography.callout)
                    .foregroundStyle(tint)
                Spacer(minLength: HowlSpacing.s3)
                if let shortcut {
                    Text(shortcut)
                        .font(HowlTypography.numeric(size: 12, weight: .regular))
                        .foregroundStyle(HowlColor.ink500)
                }
            }
            .padding(.horizontal, HowlSpacing.s3)
            .padding(.vertical, HowlSpacing.s2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous)
                    .fill(hovering ? HowlColor.navy700 : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            withAnimation(.easeInOut(duration: 0.12)) { hovering = isHovering }
        }
        .help(help ?? label)
    }
}
