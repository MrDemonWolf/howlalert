import SwiftUI

/// Primary glass-prominent button (white on cyan, with a text-lift shadow for AA).
public struct HowlPrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HowlTypography.callout)
            .foregroundStyle(.white)
            .padding(.horizontal, HowlSpacing.s5)
            .padding(.vertical, HowlSpacing.s3)
            .background(
                LinearGradient(
                    colors: [HowlColor.cyan400, HowlColor.cyan500],
                    startPoint: .top, endPoint: .bottom
                ),
                in: Capsule()
            )
            .shadow(color: .black.opacity(0.30), radius: 1, y: 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

/// Secondary — tinted surface, cyan label.
public struct HowlSecondaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HowlTypography.callout)
            .foregroundStyle(HowlColor.cyan300)
            .padding(.horizontal, HowlSpacing.s5)
            .padding(.vertical, HowlSpacing.s3)
            .background(HowlColor.navy700, in: Capsule())
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

/// Ghost — text only, ink label.
public struct HowlGhostButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HowlTypography.callout)
            .foregroundStyle(HowlColor.ink300)
            .padding(.horizontal, HowlSpacing.s4)
            .padding(.vertical, HowlSpacing.s2)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

public extension ButtonStyle where Self == HowlPrimaryButtonStyle {
    static var howlPrimary: HowlPrimaryButtonStyle { .init() }
}
public extension ButtonStyle where Self == HowlSecondaryButtonStyle {
    static var howlSecondary: HowlSecondaryButtonStyle { .init() }
}
public extension ButtonStyle where Self == HowlGhostButtonStyle {
    static var howlGhost: HowlGhostButtonStyle { .init() }
}
