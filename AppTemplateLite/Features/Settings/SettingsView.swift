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
    @State private var reminderTime = "17:00"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header

                if viewModel.isProcessing {
                    ProgressView("Updating settings...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

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
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
        .navigationTitle("Settings")
        .toast($viewModel.toast)
    }

    private var header: some View {
        Text("Account, notifications, and demo utilities.")
            .font(.bodyMedium())
            .foregroundStyle(Color.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accountSection: some View {
        section(title: "Account") {
            if session.isSignedIn {
                listCard {
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

                    if FeatureFlags.enableAuth {
                        Divider()
                        DSListRow(
                            title: "Show sign-in screen",
                            subtitle: "Preview the auth demo again.",
                            leadingIcon: "person.crop.circle.badge.plus"
                        ) {
                            viewModel.showAuthScreen(services: services, session: session)
                        } trailing: {
                            DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
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

    private var subscriptionSection: some View {
        section(title: "Monetization") {
            listCard {
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
        section(title: "Notifications") {
            listCard {
                DSListRow(
                    title: "Reminder time",
                    subtitle: "Set a time to plant a memory.",
                    leadingIcon: "bell.fill"
                ) {
                    reminderTime = reminderTime == "17:00" ? "08:30" : "17:00"
                } trailing: {
                    TimePill(title: reminderTime, usesGlass: true)
                }
                Divider()
                DSListRow(
                    title: "Daily reminders",
                    subtitle: "Enable notifications.",
                    leadingIcon: "calendar"
                ) {
                    remindersEnabled.toggle()
                    viewModel.requestPushAuthorization(services: services)
                } trailing: {
                    GlassToggle(isOn: $remindersEnabled)
                }
            }
            .disabled(!FeatureFlags.enablePushNotifications)
        }
    }

    private var navigationSection: some View {
        section(title: "Navigation") {
            listCard {
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
        section(title: "Debug tools") {
            listCard {
                DSListRow(
                    title: "Reset onboarding",
                    subtitle: "Restart the setup flow.",
                    leadingIcon: "arrow.counterclockwise"
                ) {
                    viewModel.resetOnboarding(services: services, session: session)
                } trailing: {
                    DSIconButton(icon: "arrow.counterclockwise", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Reset paywall",
                    subtitle: "Show on next launch.",
                    leadingIcon: "sparkles"
                ) {
                    viewModel.resetPaywall(services: services, session: session)
                } trailing: {
                    DSIconButton(icon: "arrow.counterclockwise", style: .secondary, size: .small)
                }
                Divider()
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

    private func copyToPasteboard(_ value: String) {
        guard !value.isEmpty else { return }
        UIPasteboard.general.string = value
        viewModel.toast = .success("Copied to clipboard.")
    }

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)
            content()
        }
    }

    private func listCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .cardSurface(cornerRadius: DSRadii.lg)
    }
}

#Preview {
    SettingsView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
