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
                skipButton
                if viewModel.isLoading {
                    ProgressView("Signing you in...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

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
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Sign in")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Sync your demo progress and unlock premium previews.")
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
        .cardSurface(cornerRadius: DSRadii.lg)
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
            listCard {
                if viewModel.availableProviders.contains(.apple) {
                    DSListRow(
                        title: "Continue with Apple",
                        subtitle: "Private sign-in",
                        leadingIcon: "apple.logo"
                    ) {
                        viewModel.signInApple(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                }

                if viewModel.availableProviders.contains(.google) {
                    if viewModel.availableProviders.contains(.apple) {
                        Divider()
                    }
                    DSListRow(
                        title: "Continue with Google",
                        subtitle: "Fast setup",
                        leadingIcon: "globe"
                    ) {
                        viewModel.signInGoogle(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                    }
                }

                if viewModel.availableProviders.contains(.guest) {
                    if viewModel.availableProviders.contains(.apple) || viewModel.availableProviders.contains(.google) {
                        Divider()
                    }
                    DSListRow(
                        title: "Explore as guest",
                        subtitle: "Skip sign-in for now",
                        leadingIcon: "person"
                    ) {
                        viewModel.signInAnonymously(services: services, session: session)
                    } trailing: {
                        DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
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

    private var skipButton: some View {
        DSButton.link(title: "Skip for now") {
            session.markAuthDismissed()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func featureRow(icon: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            HeroIcon(systemName: icon, size: 22)

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

    private func listCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .cardSurface(cornerRadius: DSRadii.lg)
    }
}

#Preview {
    AuthView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}
