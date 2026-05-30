import SwiftUI

/// Liquid Glass — the macOS 26 / iOS 26 / watchOS 26 navigation material.
///
/// Apply ONLY to the navigation layer: toolbars, popover chrome, floating CTAs,
/// tab bars. NEVER on content cards (brand rule — content stays solid navy).
/// 26-only and unconditional: no `@available` guards, no `.ultraThinMaterial`
/// fallback.
public extension View {
    /// Wrap a navigation surface in Liquid Glass.
    /// - Parameters:
    ///   - glass: the glass variant (default `.regular`).
    ///   - shape: the clip shape (default = `HowlRadius.xl` continuous rounded rect).
    func howlGlass(
        _ glass: Glass = .regular,
        in shape: some Shape = RoundedRectangle(cornerRadius: HowlRadius.xl, style: .continuous)
    ) -> some View {
        glassEffect(glass, in: shape)
    }
}

/// Groups multiple `howlGlass` surfaces so they blend/merge as one Liquid Glass
/// system (shared refraction, fluid morphing) instead of N independent layers.
/// Use around a cluster of glass controls — e.g. a row of floating buttons.
public struct HowlGlassGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = HowlSpacing.s2, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}
