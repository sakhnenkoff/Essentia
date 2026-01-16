//
//  SettingsView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct SettingsView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        ZStack {
            PremiumBackground()

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
        }
        .navigationTitle("Settings")
        .toast($viewModel.toast)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Personalize your experience")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Manage account details, privacy preferences, and demo features.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accountSection: some View {
        sectionCard(title: "Account") {
            if session.isSignedIn {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    keyValueRow(title: "User ID", value: session.auth?.uid ?? "unknown")
                    if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                        keyValueRow(title: "Email", value: email)
                    }

                    DSButton(title: "Sign out", style: .secondary, isFullWidth: true) {
                        viewModel.signOut(services: services, session: session)
                    }
                    .disabled(viewModel.isProcessing)

                    DSButton(title: "Delete account", style: .destructive, isFullWidth: true) {
                        viewModel.deleteAccount(services: services, session: session)
                    }
                    .disabled(viewModel.isProcessing)
                }
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
        sectionCard(title: "Monetization") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                keyValueRow(title: "Plan", value: session.isPremium ? "Premium active" : "Free plan")

                DSButton(title: "View paywall", icon: "sparkles", isFullWidth: true) {
                    router.presentSheet(.paywall)
                }
                .disabled(!FeatureFlags.enablePurchases)
            }
        }
    }

    private var notificationsSection: some View {
        sectionCard(title: "Notifications") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Enable push notifications to preview engagement flows.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)

                DSButton(title: "Enable push notifications", icon: "bell.fill", style: .secondary, isFullWidth: true) {
                    viewModel.requestPushAuthorization(services: services)
                }
                .disabled(!FeatureFlags.enablePushNotifications)
            }
        }
    }

    private var navigationSection: some View {
        sectionCard(title: "Navigation") {
            VStack(spacing: DSSpacing.sm) {
                DSButton(title: "Open settings detail", icon: "slider.horizontal.3", style: .secondary, isFullWidth: true) {
                    router.navigateTo(.settingsDetail, for: .settings)
                }

                DSButton(title: "Open profile", icon: "person.crop.circle", style: .secondary, isFullWidth: true) {
                    router.navigateTo(.profile(userId: session.auth?.uid ?? "guest"), for: .settings)
                }
            }
        }
    }

    private var debugSection: some View {
        sectionCard(title: "Debug tools") {
            VStack(spacing: DSSpacing.sm) {
                DSButton(title: "Reset onboarding", icon: "arrow.counterclockwise", style: .tertiary, isFullWidth: true) {
                    viewModel.resetOnboarding(services: services, session: session)
                }

                DSButton(title: "Reset paywall prompt", icon: "sparkles", style: .tertiary, isFullWidth: true) {
                    viewModel.resetPaywall(services: services, session: session)
                }

                DSButton(title: "Open debug menu", icon: "ladybug.fill", style: .tertiary, isFullWidth: true) {
                    router.presentSheet(.debug)
                }
            }
        }
    }

    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            content()
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    private func keyValueRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)
            Text(value)
                .font(.bodySmall())
                .foregroundStyle(Color.textPrimary)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
