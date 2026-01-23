import SwiftUI
import DesignSystem

struct GlassStack<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let usesGlass: Bool
    let content: Content

    init(
        spacing: CGFloat = DSSpacing.sm,
        alignment: HorizontalAlignment = .leading,
        usesGlass: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.alignment = alignment
        self.usesGlass = usesGlass
        self.content = content()
    }

    var body: some View {
        if #available(iOS 26.0, *), usesGlass {
            GlassEffectContainer(spacing: spacing) {
                VStack(alignment: alignment, spacing: spacing) {
                    content
                }
            }
        } else {
            VStack(alignment: alignment, spacing: spacing) {
                content
            }
        }
    }
}
