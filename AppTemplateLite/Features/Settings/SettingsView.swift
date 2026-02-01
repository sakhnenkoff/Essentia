//
//  SettingsView.swift
//  AppTemplateLite
//
//

import SwiftUI
import UIKit
import AppRouter
import DesignSystem

struct SettingsView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var viewModel = SettingsViewModel()
    @State private var remindersEnabled = true
    @State private var reminderTime = DemoContent.Notifications.reminderPrimary

    var body: some View {
        DSScreen(title: DemoContent.Settings.navigationTitle) {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header

                if viewModel.isProcessing {
                    ProgressView("Updating settings...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                demoSection
                accountSection
                subscriptionSection
                notificationsSection
                navigationSection
                debugSection

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(
                        title: "Settings update failed",
                        message: errorMessage,
                        retryTitle: "Dismiss",
                        onRetry: { viewModel.clearError() }
                    )
                }
            }
        }
        .toast($viewModel.toast)
    }

    private var header: some View {
        Text(DemoContent.Settings.header)
            .font(.bodyMedium())
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accountSection: some View {
        DSSection(title: DemoContent.Sections.account) {
            if session.isSignedIn {
                DSListCard {
                    DSListRow(
                        title: "User ID",
                        subtitle: session.auth?.uid ?? "unknown",
                        leadingIcon: "person.crop.circle"
                    ) {
                        copyToPasteboard(session.auth?.uid ?? "")
                    } trailing: {
                        DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                    }

                    if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                        Divider()
                        DSListRow(
                            title: "Email",
                            subtitle: email,
                            leadingIcon: "envelope"
                        ) {
                            copyToPasteboard(email)
                        } trailing: {
                            DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                        }
                    }

                    Divider()
                    DSListRow(
                        title: "Sign out",
                        subtitle: "End this session.",
                        leadingIcon: "arrow.backward.square"
                    ) {
                        viewModel.signOut(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                    Divider()
                    DSListRow(
                        title: "Delete account",
                        subtitle: "Remove demo data.",
                        leadingIcon: "trash",
                        leadingTint: .error,
                        titleColor: .error
                    ) {
                        viewModel.deleteAccount(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .destructive, size: .small)
                    }
                }
                .disabled(viewModel.isProcessing)
            } else {
                if FeatureFlags.enableAuth {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.exclamationmark",
                        title: "Not signed in",
                        message: "Sign in to sync your account and access premium features.",
                        actionTitle: "Go to sign in",
                        action: { viewModel.showAuthScreen(services: services, session: session) }
                    )
                } else {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Guest mode active",
                        message: "Authentication is disabled in FeatureFlags."
                    )
                }
            }
        }
    }

    private var demoSection: some View {
        DSSection(title: DemoContent.Sections.demoToggles) {
            DSListCard {
                DSListRow(
                    title: "Onboarding flow",
                    subtitle: "Show the onboarding steps.",
                    leadingIcon: "sparkles"
                ) {
                    GlassToggle(isOn: onboardingToggle, accessibilityLabel: "Onboarding flow")
                }

                Divider()

                if FeatureFlags.enableAuth {
                    DSListRow(
                        title: "Sign-in screen",
                        subtitle: "Reopen the auth demo.",
                        leadingIcon: "person.crop.circle"
                    ) {
                        GlassToggle(isOn: authToggle, accessibilityLabel: "Sign-in screen")
                    }
                } else {
                    DSListRow(
                        title: "Sign-in screen",
                        subtitle: "Disabled in FeatureFlags.",
                        leadingIcon: "person.crop.circle.badge.checkmark"
                    ) {
                        TagBadge(text: "Disabled", tint: .textSecondary)
                    }
                }

                Divider()

                if FeatureFlags.enablePurchases {
                    DSListRow(
                        title: "Paywall flow",
                        subtitle: "Show the premium upsell.",
                        leadingIcon: "creditcard.fill"
                    ) {
                        GlassToggle(isOn: paywallToggle, accessibilityLabel: "Paywall flow")
                    }
                } else {
                    DSListRow(
                        title: "Paywall flow",
                        subtitle: "Disabled in FeatureFlags.",
                        leadingIcon: "creditcard.fill"
                    ) {
                        TagBadge(text: "Disabled", tint: .textSecondary)
                    }
                }
            }
            .disabled(viewModel.isProcessing)
        }
    }

    private var subscriptionSection: some View {
        DSSection(title: DemoContent.Sections.monetization) {
            DSListCard {
                DSListRow(
                    title: "Plan",
                    subtitle: session.isPremium ? "Premium active." : "Free plan.",
                    leadingIcon: "sparkles"
                ) {
                    TagBadge(text: session.isPremium ? "Premium" : "Free")
                }
                Divider()
                DSListRow(
                    title: "View paywall",
                    subtitle: "See the upgrade flow.",
                    leadingIcon: "creditcard.fill"
                ) {
                    router.presentSheet(.paywall)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
            .disabled(!FeatureFlags.enablePurchases)
        }
    }

    private var notificationsSection: some View {
        DSSection(title: DemoContent.Sections.notifications) {
            DSListCard {
                DSListRow(
                    title: "Reminder time",
                    subtitle: "Set a time to plant a memory.",
                    leadingIcon: "bell.fill"
                ) {
                    reminderTime = reminderTime == DemoContent.Notifications.reminderPrimary
                        ? DemoContent.Notifications.reminderSecondary
                        : DemoContent.Notifications.reminderPrimary
                } trailing: {
                    TimePill(title: reminderTime, usesGlass: true)
                }
                Divider()
                DSListRow(
                    title: "Daily reminders",
                    subtitle: "Enable notifications.",
                    leadingIcon: "calendar"
                ) {
                    GlassToggle(isOn: remindersToggle, accessibilityLabel: "Daily reminders")
                }
            }
            .disabled(!FeatureFlags.enablePushNotifications)
        }
    }

    private var navigationSection: some View {
        DSSection(title: DemoContent.Sections.navigation) {
            DSListCard {
                DSListRow(
                    title: "Settings detail",
                    subtitle: "Privacy and tracking.",
                    leadingIcon: "slider.horizontal.3"
                ) {
                    router.navigateTo(.settingsDetail, for: .settings)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Profile",
                    subtitle: "Account overview.",
                    leadingIcon: "person.crop.circle"
                ) {
                    router.navigateTo(.profile(userId: session.auth?.uid ?? "guest"), for: .settings)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
        }
    }

    private var debugSection: some View {
        DSSection(title: DemoContent.Sections.debugTools) {
            DSListCard {
                DSListRow(
                    title: "Open debug menu",
                    subtitle: "Developer utilities.",
                    leadingIcon: "ladybug.fill"
                ) {
                    router.presentSheet(.debug)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
        }
    }

    private var onboardingToggle: Binding<Bool> {
        Binding(
            get: { !session.isOnboardingComplete },
            set: { newValue in
                if newValue {
                    viewModel.resetOnboarding(services: services, session: session)
                } else {
                    session.setOnboardingComplete()
                    viewModel.toast = .info("Onboarding hidden.")
                }
            }
        )
    }

    private var authToggle: Binding<Bool> {
        Binding(
            get: { FeatureFlags.enableAuth && !session.hasDismissedAuth },
            set: { newValue in
                guard FeatureFlags.enableAuth else { return }
                if newValue {
                    viewModel.showAuthScreen(services: services, session: session)
                } else {
                    session.markAuthDismissed()
                    viewModel.toast = .info("Sign-in hidden.")
                }
            }
        )
    }

    private var paywallToggle: Binding<Bool> {
        Binding(
            get: { FeatureFlags.enablePurchases && !session.hasDismissedPaywall },
            set: { newValue in
                guard FeatureFlags.enablePurchases else { return }
                if newValue {
                    viewModel.resetPaywall(services: services, session: session)
                } else {
                    session.markPaywallDismissed()
                    viewModel.toast = .info("Paywall hidden.")
                }
            }
        )
    }

    private var remindersToggle: Binding<Bool> {
        Binding(
            get: { remindersEnabled },
            set: { newValue in
                remindersEnabled = newValue
                if newValue {
                    viewModel.requestPushAuthorization(services: services)
                }
            }
        )
    }

    private func copyToPasteboard(_ value: String) {
        guard !value.isEmpty else { return }
        UIPasteboard.general.string = value
        viewModel.toast = .success("Copied to clipboard.")
    }

}

#Preview {
    SettingsView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
