import SwiftUI

/// Calm empty / recovery state — icon, title, message.
public struct EmptyState: View {
    private let systemImage: String
    private let title: String
    private let message: String

    public init(systemImage: String, title: String, message: String) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: HowlSpacing.s3) {
            Image(systemName: systemImage)
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(HowlColor.ink500)
            Text(title)
                .font(HowlTypography.headline)
                .foregroundStyle(HowlColor.ink100)
            Text(message)
                .font(HowlTypography.caption)
                .foregroundStyle(HowlColor.ink300)
                .multilineTextAlignment(.center)
        }
        .padding(HowlSpacing.s6)
    }
}
