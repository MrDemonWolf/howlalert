import SwiftUI

/// Menu footer row — SF Symbol + label + optional ⌘-shortcut. `.danger` for Quit.
public struct MenuActionRow: View {
    private let systemImage: String
    private let label: String
    private let shortcut: String?
    private let danger: Bool

    public init(systemImage: String, label: String, shortcut: String? = nil, danger: Bool = false) {
        self.systemImage = systemImage
        self.label = label
        self.shortcut = shortcut
        self.danger = danger
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s3) {
            Image(systemName: systemImage)
                .font(.system(size: 13))
                .frame(width: 18)
                .foregroundStyle(danger ? HowlColor.stateCrit : HowlColor.ink300)
            Text(label)
                .font(HowlTypography.callout)
                .foregroundStyle(danger ? HowlColor.stateCrit : HowlColor.ink100)
            Spacer()
            if let shortcut {
                Text(shortcut)
                    .font(HowlTypography.numeric(size: 12, weight: .regular))
                    .foregroundStyle(HowlColor.ink500)
            }
        }
        .padding(.horizontal, HowlSpacing.s3)
        .padding(.vertical, HowlSpacing.s2)
        .contentShape(Rectangle())
    }
}
