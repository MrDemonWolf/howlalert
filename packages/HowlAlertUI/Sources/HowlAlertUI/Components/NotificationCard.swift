import SwiftUI

/// State-tinted notification / alert card.
public struct NotificationCard: View {
    private let state: HowlState
    private let systemImage: String
    private let title: String
    private let message: String
    private let time: String

    public init(state: HowlState, systemImage: String, title: String, message: String, time: String) {
        self.state = state
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.time = time
    }

    public var body: some View {
        HStack(alignment: .top, spacing: HowlSpacing.s3) {
            StateIcon(systemName: systemImage, state: state, size: 18)
            VStack(alignment: .leading, spacing: HowlSpacing.s1) {
                Text(title).font(HowlTypography.callout).foregroundStyle(HowlColor.ink100)
                Text(message).font(HowlTypography.caption).foregroundStyle(HowlColor.ink300)
            }
            Spacer(minLength: HowlSpacing.s2)
            Text(time).font(HowlTypography.micro).foregroundStyle(HowlColor.ink500)
        }
        .padding(HowlSpacing.s4)
        .background(HowlColor.navy800, in: RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous))
    }
}
