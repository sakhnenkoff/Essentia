//
//  AuthView.swift
//  Essentia
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
        DSScreen(contentPadding: DSSpacing.md, topPadding: DSSpacing.xxlg) {
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
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(DemoContent.Auth.title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text(DemoContent.Auth.subtitle)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var valueProps: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            featureRow(
                icon: "lock.shield.fill",
                title: DemoContent.Auth.privacyTitle,
                message: DemoContent.Auth.privacyMessage
            )
            featureRow(
                icon: "sparkles",
                title: DemoContent.Auth.flowsTitle,
                message: DemoContent.Auth.flowsMessage
            )
            featureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: DemoContent.Auth.growthTitle,
                message: DemoContent.Auth.growthMessage
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
            DSListCard {
                if viewModel.availableProviders.contains(.apple) {
                    DSListRow(
                        title: "Continue with Email",
                        subtitle: "Private sign-in",
                        leadingIcon: "envelope.fill"
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
                        title: "Continue with Workspace",
                        subtitle: "Secure access",
                        leadingIcon: "person.badge.key.fill"
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
        Text(DemoContent.Auth.footerNote)
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
            HeroIcon(
                systemName: icon,
                size: DSLayout.iconMedium,
                tint: Color.themePrimary,
                backgroundTint: Color.surface
            )

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
