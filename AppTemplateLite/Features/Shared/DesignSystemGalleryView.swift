import SwiftUI
import DesignSystem

struct DesignSystemGalleryView: View {
    @State private var toast: Toast?
    @State private var selectedSegment = "Daily"
    @State private var isToggleOn = true
    @State private var isPillToggleOn = true
    @State private var demoTime = Date()
    @State private var name = ""
    @State private var email = ""
    @State private var selectedChoices: Set<String> = ["Launch"]
    @State private var showSkeleton = true

    var body: some View {
        DSScreen(title: "Design System") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                DSSection(title: "Buttons") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.sm) {
                            DSButton(title: "Primary") { }
                            DSButton(title: "Secondary", style: .secondary) { }
                        }
                        HStack(spacing: DSSpacing.sm) {
                            DSButton(title: "Text only", style: .tertiary) { }
                            DSButton(title: "Destructive", style: .destructive) { }
                        }
                        HStack(spacing: DSSpacing.sm) {
                            DSIconButton(icon: "heart.fill", style: .primary, size: .medium, accessibilityLabel: "Favorite") { }
                            DSIconButton(icon: "plus", style: .secondary, size: .small, accessibilityLabel: "Add") { }
                            DSIconButton(icon: "xmark", style: .tertiary, size: .small, accessibilityLabel: "Close") { }
                        }
                    }
                }

                DSSection(title: "Controls") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        DSSegmentedControl(items: ["Daily", "Weekly", "Monthly"], selection: $selectedSegment)
                        HStack(spacing: DSSpacing.sm) {
                            GlassToggle(isOn: $isToggleOn, accessibilityLabel: "Glass toggle")
                            DSPillToggle(isOn: $isPillToggleOn, icon: "leaf.fill", accessibilityLabel: "Pill toggle")
                            TimePill(time: $demoTime, usesGlass: true, accessibilityLabel: "Time picker")
                        }
                    }
                }

                DSSection(title: "Inputs") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        DSTextField(
                            placeholder: "Your name",
                            text: $name,
                            autocapitalization: .words,
                            style: .underline
                        )
                        DSTextField(
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never,
                            style: .underline
                        )
                    }
                }

                DSSection(title: "Cards") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        DSHeroCard {
                            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                                HStack {
                                    HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                                    Spacer()
                                    TagBadge(text: "New")
                                }
                                Text("Hero card")
                                    .font(.headlineMedium())
                                    .foregroundStyle(Color.textPrimary)
                                Text("Use DSHeroCard for featured content.")
                                    .font(.bodySmall())
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }

                        DSInfoCard(
                            title: "Heads up",
                            message: "Info cards communicate short status updates.",
                            icon: "info.circle",
                            tint: .info
                        )
                    }
                }

                DSSection(title: "Selection") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        DSChoiceButton(
                            title: "Launch",
                            icon: "paperplane.fill",
                            isSelected: selectedChoices.contains("Launch")
                        ) {
                            toggleChoice("Launch")
                        }

                        DSChoiceButton(
                            title: "Monetize",
                            icon: "creditcard.fill",
                            isSelected: selectedChoices.contains("Monetize")
                        ) {
                            toggleChoice("Monetize")
                        }

                        DSChoiceButton(
                            title: "Measure",
                            icon: "chart.line.uptrend.xyaxis",
                            isSelected: selectedChoices.contains("Measure")
                        ) {
                            toggleChoice("Measure")
                        }
                    }
                }

                DSSection(title: "List rows") {
                    DSListCard {
                        DSListRow(
                            title: "Daily prompt",
                            subtitle: "Add one memory.",
                            leadingIcon: "doc.text"
                        ) {
                            TagBadge(text: "New")
                        }
                        Divider()
                        DSListRow(
                            title: "Reminder time",
                            subtitle: "Set a calm nudge.",
                            leadingIcon: "bell.fill"
                        ) {
                            TimePill(title: DemoContent.Notifications.reminderPrimary)
                        }
                    }
                }

                DSSection(title: "States") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.sm) {
                            Circle()
                                .fill(Color.surfaceVariant)
                                .frame(width: DSLayout.avatarSmall, height: DSLayout.avatarSmall)
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                Text("Profile Name")
                                    .font(.headlineSmall())
                                Text("Loading content...")
                                    .font(.bodySmall())
                            }
                            Spacer()
                        }
                        .shimmer(showSkeleton)

                        DSButton(title: showSkeleton ? "Stop shimmer" : "Start shimmer", style: .secondary) {
                            showSkeleton.toggle()
                        }

                        DSButton(title: "Show Toast", style: .tertiary) {
                            toast = Toast(style: .success, message: "Action completed!")
                        }
                    }
                }

                DSSection(title: "Empty & error") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        EmptyStateView(
                            icon: "tray",
                            title: "No items yet",
                            message: "Create your first item to get started.",
                            actionTitle: "Create",
                            action: { }
                        )
                        ErrorStateView(
                            title: "Upload failed",
                            message: "Please check your connection.",
                            retryTitle: "Try again",
                            onRetry: { }
                        )
                    }
                }
            }
        }
        .toast($toast)
    }

    private func toggleChoice(_ choice: String) {
        if selectedChoices.contains(choice) {
            selectedChoices.remove(choice)
        } else {
            selectedChoices.insert(choice)
        }
    }
}

#Preview {
    NavigationStack {
        DesignSystemGalleryView()
    }
}

#Preview("Design System - AX") {
    NavigationStack {
        DesignSystemGalleryView()
    }
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
