import SwiftUI

/// Line sparkline normalized into its rect.
public struct Sparkline: Shape {
    public var points: [Double]
    public init(_ points: [Double]) { self.points = points }
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let mn = points.min() ?? 0
        let mx = points.max() ?? 1
        let span = (mx - mn) == 0 ? 1 : (mx - mn)
        let stepX = rect.width / CGFloat(points.count - 1)
        for (i, v) in points.enumerated() {
            let x = rect.minX + CGFloat(i) * stepX
            let y = rect.maxY - CGFloat((v - mn) / span) * rect.height
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        return path
    }
}

/// Recent-activity row: model name + sparkline + trailing value.
public struct ModelRow: View {
    private let name: String
    private let points: [Double]
    private let value: String
    private let state: HowlState

    public init(name: String, points: [Double], value: String, state: HowlState = .ok) {
        self.name = name
        self.points = points
        self.value = value
        self.state = state
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s3) {
            Text(name)
                .font(HowlTypography.callout)
                .foregroundStyle(HowlColor.ink100)
            Spacer(minLength: HowlSpacing.s3)
            Sparkline(points)
                .stroke(state.color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 48, height: 16)
            Text(value)
                .font(HowlTypography.numeric(size: 13))
                .foregroundStyle(HowlColor.ink300)
        }
    }
}
