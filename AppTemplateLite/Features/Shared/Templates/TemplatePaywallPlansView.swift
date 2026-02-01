import SwiftUI
import DesignSystem

struct TemplatePaywallPlansView: View {
    @State private var selectedPlan: String? = "monthly"

    var body: some View {
        DSScreen(title: "Template") {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                DSHeroCard {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                            Spacer()
                            TagBadge(text: "Pro")
                        }
                        Text("Upgrade to Pro")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)
                        Text("Unlock advanced features and analytics.")
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                DSSection(title: "Choose a plan") {
                    VStack(spacing: DSSpacing.sm) {
                        planCard(title: "Monthly", price: "$9.99", id: "monthly")
                        planCard(title: "Yearly", price: "$79.99", id: "yearly")
                    }
                }

                DSButton.cta(title: "Unlock Pro", isEnabled: selectedPlan != nil) { }
                DSButton.link(title: "Restore purchase") { }
            }
        }
    }

    private func planCard(title: String, price: String, id: String) -> some View {
        let isSelected = selectedPlan == id

        return Button {
            selectedPlan = id
        } label: {
            VStack(alignment: .leading, spacing: DSSpacing.smd) {
                Text(title)
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                Text(price)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)

                PickerPill(
                    title: "Billed monthly",
                    isHighlighted: isSelected,
                    usesGlass: isSelected,
                    isInteractive: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DSSpacing.md)
            .cardSurface(
                cornerRadius: DSRadii.lg,
                tint: Color.surfaceVariant.opacity(0.7),
                usesGlass: isSelected,
                isInteractive: true,
                borderColor: isSelected ? Color.themePrimary.opacity(0.4) : Color.border,
                shadowColor: isSelected ? DSShadows.lifted.color : DSShadows.card.color,
                shadowRadius: isSelected ? DSShadows.lifted.radius : DSShadows.card.radius,
                shadowYOffset: isSelected ? DSShadows.lifted.y : DSShadows.card.y
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TemplatePaywallPlansView()
    }
}
