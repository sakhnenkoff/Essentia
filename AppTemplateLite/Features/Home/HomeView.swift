//
//  HomeView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct HomeView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    hero
                    statusGrid
                    navigationActions
                    activitySection
                }
                .padding(DSSpacing.md)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Home")
        .toast($viewModel.toast)
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }

    private var hero: some View {
        let name = session.currentUser?.commonNameCalculated ?? "there"

        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(alignment: .top, spacing: DSSpacing.sm) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Welcome back, \(name)")
                        .font(.titleLarge())
                        .foregroundStyle(Color.textPrimary)
                    Text("Your demo workspace is ready for onboarding, analytics, and monetization.")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                statusBadge
            }
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.lg)
                .stroke(Color.themePrimary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.08), radius: 16, x: 0, y: 10)
    }

    private var statusBadge: some View {
        let isPremium = session.isPremium
        let text = isPremium ? "Premium" : "Free plan"
        let tint = isPremium ? Color.success : Color.info

        return Text(text)
            .font(.captionLarge())
            .foregroundStyle(tint)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(tint.opacity(0.15))
            .clipShape(Capsule())
    }

    private var statusGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
            statusCard(
                title: "Onboarding",
                status: session.isOnboardingComplete ? "Complete" : "Not started",
                detail: session.isOnboardingComplete ? "Flow is ready for returning users." : "Guide new users through setup.",
                icon: "sparkles",
                tint: Color.info,
                actionTitle: "Restart",
                action: { viewModel.resetOnboarding(services: services, session: session) }
            )

            statusCard(
                title: "Subscription",
                status: session.isPremium ? "Premium" : "Free",
                detail: session.isPremium ? "Entitlement is active." : "Preview the upgrade flow.",
                icon: "creditcard.fill",
                tint: session.isPremium ? Color.success : Color.warning,
                actionTitle: "View paywall",
                action: { router.presentSheet(.paywall) }
            )

            statusCard(
                title: "Profile",
                status: session.isSignedIn ? "Synced" : "Guest",
                detail: "View account details and user info.",
                icon: "person.fill",
                tint: Color.warning,
                actionTitle: "Open profile",
                action: {
                    let userId = session.auth?.uid ?? "guest"
                    router.navigateTo(.profile(userId: userId), for: .home)
                }
            )

            statusCard(
                title: "Notifications",
                status: FeatureFlags.enablePushNotifications ? "Ready" : "Disabled",
                detail: FeatureFlags.enablePushNotifications
                    ? "Preview opt-in prompts and engagement flows."
                    : "Enable in FeatureFlags to test notifications.",
                icon: "bell.fill",
                tint: Color.info,
                actionTitle: "Open settings",
                action: { router.presentSheet(.settings) }
            )
        }
    }

    private var navigationActions: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Explore the template")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)
            Text("Jump into routed screens and sheets to see the demo flow.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)

            DSButton(title: "View detail screen", icon: "square.stack.3d.up.fill", isFullWidth: true) {
                router.navigateTo(.detail(title: "Starter detail"), for: .home)
            }

            DSButton(title: "Open settings", icon: "gearshape.fill", style: .secondary, isFullWidth: true) {
                router.presentSheet(.settings)
            }

            DSButton(title: "Open debug menu", icon: "ladybug.fill", style: .tertiary, isFullWidth: true) {
                router.presentSheet(.debug)
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Highlights")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)
            Text("A quick snapshot of what the demo app is ready to do.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)

            if viewModel.isLoading {
                VStack(spacing: DSSpacing.sm) {
                    SkeletonView(style: .listRow)
                    SkeletonView(style: .listRow)
                    SkeletonView(style: .listRow)
                }
                .padding(.vertical, DSSpacing.sm)
                .shimmer(true)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(
                    title: "Unable to refresh highlights",
                    message: errorMessage,
                    retryTitle: "Try again",
                    onRetry: {
                        Task {
                            await viewModel.loadHighlights(services: services, session: session)
                        }
                    }
                )
            } else if viewModel.highlights.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No highlights yet",
                    message: "Add a sample highlight to preview this section.",
                    actionTitle: "Add sample highlight",
                    action: { viewModel.seedHighlights(services: services) }
                )
            } else {
                VStack(spacing: DSSpacing.sm) {
                    ForEach(viewModel.highlights) { highlight in
                        highlightRow(highlight)
                    }
                }
            }
        }
    }

    private func statusCard(
        title: String,
        status: String,
        detail: String,
        icon: String,
        tint: Color,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: icon)
                    .font(.headlineSmall())
                    .foregroundStyle(tint)
                Text(title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
            }

            Text(status)
                .font(.titleSmall())
                .foregroundStyle(Color.textPrimary)

            Text(detail)
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)

            DSButton(title: actionTitle, style: .secondary, size: .small, isFullWidth: true, action: action)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundSecondary)
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    private func highlightRow(_ highlight: HomeViewModel.Highlight) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: highlightIcon(for: highlight.kind))
                .font(.headlineMedium())
                .foregroundStyle(highlightTint(for: highlight.kind))
                .frame(width: 36, height: 36)
                .background(highlightTint(for: highlight.kind).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(highlight.title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(highlight.message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DSSpacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.05), lineWidth: 1)
        )
    }

    private func highlightIcon(for kind: HomeViewModel.Highlight.Kind) -> String {
        switch kind {
        case .onboarding:
            return "sparkles"
        case .analytics:
            return "chart.line.uptrend.xyaxis"
        case .monetization:
            return "creditcard.fill"
        case .community:
            return "person.2.fill"
        }
    }

    private func highlightTint(for kind: HomeViewModel.Highlight.Kind) -> Color {
        switch kind {
        case .onboarding:
            return Color.info
        case .analytics:
            return Color.success
        case .monetization:
            return Color.warning
        case .community:
            return Color.info
        }
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
