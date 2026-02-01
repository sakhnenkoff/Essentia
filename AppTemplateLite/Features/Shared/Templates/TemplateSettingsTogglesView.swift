import SwiftUI
import DesignSystem

struct TemplateSettingsTogglesView: View {
    @State private var notificationsEnabled = true
    @State private var analyticsEnabled = false

    var body: some View {
        DSScreen(title: "Template") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                DSSection(title: "Preferences") {
                    DSListCard {
                        DSListRow(
                            title: "Notifications",
                            subtitle: "Stay on top of updates.",
                            leadingIcon: "bell.fill"
                        ) {
                            GlassToggle(isOn: $notificationsEnabled, accessibilityLabel: "Notifications")
                        }
                        Divider()
                        DSListRow(
                            title: "Share analytics",
                            subtitle: "Help improve the experience.",
                            leadingIcon: "chart.line.uptrend.xyaxis"
                        ) {
                            GlassToggle(isOn: $analyticsEnabled, accessibilityLabel: "Share analytics")
                        }
                    }
                }

                DSSection(title: "Account") {
                    DSListCard {
                        DSListRow(
                            title: "Manage plan",
                            subtitle: "View billing details.",
                            leadingIcon: "creditcard.fill"
                        ) {
                            DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplateSettingsTogglesView()
    }
}
