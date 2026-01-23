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
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Settings")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Account, notifications, and demo utilities.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accountSection: some View {
        section(title: "Account") {
            if session.isSignedIn {
                listCard {
                    DSListRow(
                        title: "User ID",
                        subtitle: session.auth?.uid ?? "unknown",
                        leadingIcon: "person.crop.circle",
                        leadingTint: .textPrimary,
                        trailingIcon: "doc.on.doc"
                    ) {
                        copyToPasteboard(session.auth?.uid ?? "")
                    }

                    if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                        Divider()
                        DSListRow(
                            title: "Email",
                            subtitle: email,
                            leadingIcon: "envelope",
                            leadingTint: .info,
                            trailingIcon: "doc.on.doc"
                        ) {
                            copyToPasteboard(email)
                        }
                    }

                    Divider()
                    DSListRow(
                        title: "Sign out",
                        subtitle: "End this session.",
                        leadingIcon: "arrow.backward.square",
                        leadingTint: .textSecondary,
                        trailingIcon: "chevron.right"
                    ) {
                        viewModel.signOut(services: services, session: session)
                    }
                    Divider()
                    DSListRow(
                        title: "Delete account",
                        subtitle: "Remove demo data.",
                        leadingIcon: "trash",
                        leadingTint: .error,
                        trailingIcon: "chevron.right"
                    ) {
                        viewModel.deleteAccount(services: services, session: session)
                    }
                }
                .disabled(viewModel.isProcessing)
            } else {
                EmptyStateView(
                    icon: "person.crop.circle.badge.exclamationmark",
                    title: "Not signed in",
                    message: "Sign in to sync your account and access premium features.",
                    actionTitle: "Go to sign in",
                    action: { session.resetForSignOut() }
                )
            }
        }
    }

    private var subscriptionSection: some View {
        section(title: "Monetization") {
            listCard {
                DSListRow(
                    title: "Plan",
                    subtitle: session.isPremium ? "Premium active." : "Free plan.",
                    leadingIcon: "sparkles",
                    leadingTint: session.isPremium ? .success : .warning,
                    trailingText: session.isPremium ? "Premium" : "Free"
                )
                Divider()
                DSListRow(
                    title: "View paywall",
                    subtitle: "See the upgrade flow.",
                    leadingIcon: "creditcard.fill",
                    leadingTint: .success,
                    showsDisclosure: true
                ) {
                    router.presentSheet(.paywall)
                }
            }
            .disabled(!FeatureFlags.enablePurchases)
        }
    }

    private var notificationsSection: some View {
        section(title: "Notifications") {
            listCard {
                DSListRow(
                    title: "Enable push notifications",
                    subtitle: "Preview engagement flows.",
                    leadingIcon: "bell.fill",
                    leadingTint: .info,
                    trailingText: FeatureFlags.enablePushNotifications ? "Ready" : "Off",
                    showsDisclosure: FeatureFlags.enablePushNotifications
                ) {
                    viewModel.requestPushAuthorization(services: services)
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
                    leadingIcon: "slider.horizontal.3",
                    leadingTint: .textPrimary,
                    showsDisclosure: true
                ) {
                    router.navigateTo(.settingsDetail, for: .settings)
                }
                Divider()
                DSListRow(
                    title: "Profile",
                    subtitle: "Account overview.",
                    leadingIcon: "person.crop.circle",
                    leadingTint: .warning,
                    showsDisclosure: true
                ) {
                    router.navigateTo(.profile(userId: session.auth?.uid ?? "guest"), for: .settings)
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
                    leadingIcon: "arrow.counterclockwise",
                    leadingTint: .textSecondary,
                    trailingIcon: "arrow.counterclockwise"
                ) {
                    viewModel.resetOnboarding(services: services, session: session)
                }
                Divider()
                DSListRow(
                    title: "Reset paywall",
                    subtitle: "Show on next launch.",
                    leadingIcon: "sparkles",
                    leadingTint: .textSecondary,
                    trailingIcon: "arrow.counterclockwise"
                ) {
                    viewModel.resetPaywall(services: services, session: session)
                }
                Divider()
                DSListRow(
                    title: "Open debug menu",
                    subtitle: "Developer utilities.",
                    leadingIcon: "ladybug.fill",
                    leadingTint: .textSecondary,
                    showsDisclosure: true
                ) {
                    router.presentSheet(.debug)
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
        .cardSurface(cornerRadius: DSSpacing.md)
    }
}

#Preview {
    SettingsView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
