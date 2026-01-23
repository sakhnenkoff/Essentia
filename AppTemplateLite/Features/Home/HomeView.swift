//
//  HomeView.swift
//  AppTemplateLite
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
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header
                statusSection
                actionsSection
                highlightsSection
            }
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
        .navigationTitle("Inbox")
        .toast($viewModel.toast)
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }

    private var header: some View {
        let name = session.currentUser?.commonNameCalculated ?? "there"

        return VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Welcome, \(name)")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Your demo workspace is ready.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusSection: some View {
        section(title: "Status") {
            listCard {
                DSListRow(
                    title: "Onboarding",
                    subtitle: session.isOnboardingComplete ? "All steps completed." : "Start the setup flow.",
                    leadingIcon: "sparkles",
                    leadingTint: .info,
                    trailingText: session.isOnboardingComplete ? "Complete" : "New"
                )
                Divider()
                DSListRow(
                    title: "Subscription",
                    subtitle: session.isPremium ? "Premium is active." : "Upgrade preview available.",
                    leadingIcon: "creditcard.fill",
                    leadingTint: session.isPremium ? .success : .warning,
                    trailingText: session.isPremium ? "Premium" : "Free"
                )
                Divider()
                DSListRow(
                    title: "Profile",
                    subtitle: session.isSignedIn ? "Synced account." : "Guest session.",
                    leadingIcon: "person.fill",
                    leadingTint: .warning,
                    trailingText: session.isSignedIn ? "Synced" : "Guest"
                )
                Divider()
                DSListRow(
                    title: "Notifications",
                    subtitle: FeatureFlags.enablePushNotifications ? "Opt-in flow ready." : "Feature flag is off.",
                    leadingIcon: "bell.fill",
                    leadingTint: .info,
                    trailingText: FeatureFlags.enablePushNotifications ? "Ready" : "Off"
                )
            }
        }
    }

    private var actionsSection: some View {
        section(title: "Quick actions") {
            listCard {
                DSListRow(
                    title: "Preview onboarding",
                    subtitle: "Reset and start the flow.",
                    leadingIcon: "sparkles",
                    leadingTint: .info,
                    trailingIcon: "arrow.counterclockwise"
                ) {
                    viewModel.resetOnboarding(services: services, session: session)
                }
                Divider()
                DSListRow(
                    title: "View paywall",
                    subtitle: "StoreKit and custom layouts.",
                    leadingIcon: "creditcard.fill",
                    leadingTint: .success,
                    showsDisclosure: true
                ) {
                    router.presentSheet(.paywall)
                }
                Divider()
                DSListRow(
                    title: "View detail screen",
                    subtitle: "Routed detail content.",
                    leadingIcon: "square.stack.3d.up.fill",
                    leadingTint: .textPrimary,
                    showsDisclosure: true
                ) {
                    router.navigateTo(.detail(title: "Starter detail"), for: .home)
                }
                Divider()
                DSListRow(
                    title: "Open profile",
                    subtitle: "Account details and activity.",
                    leadingIcon: "person.fill",
                    leadingTint: .warning,
                    showsDisclosure: true
                ) {
                    let userId = session.auth?.uid ?? "guest"
                    router.navigateTo(.profile(userId: userId), for: .home)
                }
            }
        }
    }

    private var highlightsSection: some View {
        section(title: "Highlights") {
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
                listCard {
                    ForEach(Array(viewModel.highlights.enumerated()), id: \.element.id) { index, highlight in
                        highlightRow(highlight)
                        if index < viewModel.highlights.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func highlightRow(_ highlight: HomeViewModel.Highlight) -> some View {
        DSListRow(
            title: highlight.title,
            subtitle: highlight.message,
            leadingIcon: highlightIcon(for: highlight.kind),
            leadingTint: highlightTint(for: highlight.kind)
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
            return .info
        case .analytics:
            return .success
        case .monetization:
            return .warning
        case .community:
            return .info
        }
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
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
