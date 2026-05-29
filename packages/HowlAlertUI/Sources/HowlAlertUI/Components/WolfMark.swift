import SwiftUI

/// Wolf head silhouette — single connected path (24×24 template from design-system.html).
public struct WolfShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 24
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * s, y: rect.minY + y * s)
        }
        var p = Path()
        p.move(to: pt(4, 11))
        p.addLine(to: pt(7, 3))
        p.addLine(to: pt(10, 9))
        p.addLine(to: pt(14, 9))
        p.addLine(to: pt(17, 3))
        p.addLine(to: pt(20, 11))
        p.addCurve(to: pt(12, 22), control1: pt(20, 18), control2: pt(16, 22))
        p.addCurve(to: pt(4, 11), control1: pt(8, 22), control2: pt(4, 18))
        p.closeSubpath()
        return p
    }
}

public enum WolfVariant: Sendable { case full, mono, template }

/// Brand mark. `.full` = cyan gradient (product chrome); `.mono`/`.template` tint to the
/// surrounding foreground color (menu bar, complications, inline).
public struct WolfMark: View {
    private let variant: WolfVariant
    private let size: CGFloat

    public init(_ variant: WolfVariant = .full, size: CGFloat = 24) {
        self.variant = variant
        self.size = size
    }

    public var body: some View {
        Group {
            switch variant {
            case .full:
                WolfShape().fill(
                    LinearGradient(
                        colors: [HowlColor.cyan300, HowlColor.cyan500],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            case .mono, .template:
                WolfShape().fill(.foreground)
            }
        }
        .frame(width: size, height: size)
    }
}
