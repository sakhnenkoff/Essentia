import SwiftUI
import DesignSystem

struct TemplateListHeroCTAView: View {
    var body: some View {
        DSScreen(title: "Template") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                DSHeroCard {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                            Spacer()
                            TagBadge(text: "Featured")
                        }
                        Text("Hero headline")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)
                        Text("Short supporting copy for the hero card.")
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                DSSection(title: "Quick actions") {
                    DSListCard {
                        DSListRow(
                            title: "First action",
                            subtitle: "Describe the primary task.",
                            leadingIcon: "bolt.fill"
                        ) {
                            DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                        }
                        Divider()
                        DSListRow(
                            title: "Secondary action",
                            subtitle: "Optional follow-up step.",
                            leadingIcon: "checkmark.circle"
                        ) {
                            DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                        }
                    }
                }

                DSButton.cta(title: "Primary CTA") { }
                DSButton(title: "Secondary action", style: .secondary, isFullWidth: true) { }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplateListHeroCTAView()
    }
}
