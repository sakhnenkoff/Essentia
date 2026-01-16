//
//  AuthView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

struct AuthView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                hero
                valueProps
                signInOptions

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(
                        title: "Couldn't sign you in",
                        message: errorMessage,
                        retryTitle: "Try again",
                        onRetry: { viewModel.retryLastSignIn(services: services, session: session) },
                        dismissTitle: "Dismiss",
                        onDismiss: { viewModel.clearError() }
                    )
                }

                footerNote
            }
            .padding(DSSpacing.md)
            .padding(.top, DSSpacing.xxlg)
        }
        .background(Color.backgroundPrimary)
        .loading(viewModel.isLoading, message: "Signing you in...")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Sign in to sync your demo")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Bring your progress across devices, unlock premium previews, and personalize your experience.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var valueProps: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            featureRow(
                icon: "lock.shield.fill",
                title: "Privacy-first",
                message: "We only collect what you explicitly share."
            )
            featureRow(
                icon: "sparkles",
                title: "Production-ready flows",
                message: "Onboarding, analytics, and paywalls are ready to ship."
            )
            featureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Growth visibility",
                message: "Understand engagement with built-in tracking hooks."
            )
        }
        .padding(DSSpacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(DSSpacing.md)
    }

    @ViewBuilder
    private var signInOptions: some View {
        if viewModel.availableProviders.isEmpty {
            EmptyStateView(
                icon: "person.crop.circle.badge.xmark",
                title: "Sign-in unavailable",
                message: "Providers are temporarily unavailable. Try again in a moment.",
                actionTitle: "Refresh",
                action: { viewModel.refreshProviders() }
            )
        } else {
            VStack(spacing: DSSpacing.sm) {
                if viewModel.availableProviders.contains(.apple) {
                    DSButton(title: "Continue with Apple", icon: "apple.logo", isFullWidth: true) {
                        viewModel.signInApple(services: services, session: session)
                    }
                }

                if viewModel.availableProviders.contains(.google) {
                    DSButton(title: "Continue with Google", icon: "globe", style: .secondary, isFullWidth: true) {
                        viewModel.signInGoogle(services: services, session: session)
                    }
                }

                if viewModel.availableProviders.contains(.guest) {
                    DSButton(title: "Explore as Guest", style: .tertiary, isFullWidth: true) {
                        viewModel.signInAnonymously(services: services, session: session)
                    }
                }
            }
            .disabled(viewModel.isLoading)
        }
    }

    private var footerNote: some View {
        Text("By continuing, you agree to the demo terms and acknowledge the privacy policy.")
            .font(.captionLarge())
            .foregroundStyle(Color.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func featureRow(icon: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.headlineSmall())
                .foregroundStyle(Color.info)
                .frame(width: 28, height: 28)
                .background(Color.info.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    AuthView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}
