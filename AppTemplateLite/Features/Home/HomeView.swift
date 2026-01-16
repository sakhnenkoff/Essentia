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
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                header
                statusCards
                primaryActions
                quickNavigation
            }
            .padding(DSSpacing.md)
        }
        .navigationTitle("Home")
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("AppTemplateLite")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Launch-ready scaffolding for onboarding, analytics, and monetization.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusCards: some View {
        VStack(spacing: DSSpacing.sm) {
            statusCard(
                title: "Onboarding",
                value: session.isOnboardingComplete ? "Complete" : "Not started",
                detail: session.isOnboardingComplete ? "All set for returning users." : "Show the onboarding flow.",
                actionTitle: "Restart",
                action: { session.resetOnboarding() }
            )
            statusCard(
                title: "Subscription",
                value: session.isPremium ? "Premium" : "Free",
                detail: session.isPremium ? "Entitlement active." : "Prompt upgrade when ready.",
                actionTitle: "Show paywall",
                action: { router.presentSheet(.paywall) }
            )
        }
    }

    private var primaryActions: some View {
        VStack(spacing: DSSpacing.sm) {
            Text("Go deeper")
                .font(.headline)
            Text("Preview AppRouter destinations and sheets.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            DSButton(title: "View detail screen") {
                router.navigateTo(.detail(title: "Starter detail"), for: .home)
            }

            DSButton(title: "Open profile", style: .secondary) {
                let userId = session.auth?.uid ?? "guest"
                router.navigateTo(.profile(userId: userId), for: .home)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var quickNavigation: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Quick navigation")
                .font(.headline)
            HStack(spacing: DSSpacing.sm) {
                quickButton(title: "Settings sheet", systemImage: "gearshape") {
                    router.presentSheet(.settings)
                }
                quickButton(title: "Debug menu", systemImage: "ladybug") {
                    router.presentSheet(.debug)
                }
            }
        }
    }

    private func statusCard(
        title: String,
        value: String,
        detail: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
            DSButton(title: actionTitle, style: .secondary, size: .small, action: action)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundPrimary)
        .cornerRadius(DSSpacing.md)
        .shadow(color: Color.black.opacity(0.05), radius: DSSpacing.sm, x: 0, y: 2)
    }

    private func quickButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.footnote)
            .padding(.vertical, DSSpacing.xs)
            .padding(.horizontal, DSSpacing.sm)
            .background(Color.backgroundSecondary)
            .cornerRadius(DSSpacing.sm)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
