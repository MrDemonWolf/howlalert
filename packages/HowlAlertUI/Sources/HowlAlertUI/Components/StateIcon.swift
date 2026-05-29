import SwiftUI

/// SF Symbol tinted by usage state.
public struct StateIcon: View {
    private let systemName: String
    private let state: HowlState
    private let size: CGFloat

    public init(systemName: String, state: HowlState, size: CGFloat = 16) {
        self.systemName = systemName
        self.state = state
        self.size = size
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(state.color)
            .symbolRenderingMode(.hierarchical)
    }
}
