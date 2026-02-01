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
        DSScreen(title: DemoContent.Home.navigationTitle) {
            LazyVStack(alignment: .leading, spacing: DSSpacing.xl) {
                hero
                screensSection
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DSIconButton(icon: "gearshape", style: .tertiary, size: .small, showsBackground: false, accessibilityLabel: "Settings") {
                    router.selectedTab = .settings
                }
            }
        }
        .toast($viewModel.toast)
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            AppTopIcon(systemName: "scribble.variable")
            Text(DemoContent.Home.heroTitle)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text(DemoContent.Home.heroSubtitle)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var screensSection: some View {
        DSSection(title: DemoContent.Home.screensSectionTitle) {
            DSListCard {
                DSListRow(
                    title: "Onboarding",
                    subtitle: session.isOnboardingComplete ? "Restart the flow." : "Start the demo flow.",
                    leadingIcon: "sparkles"
                ) {
                    viewModel.resetOnboarding(services: services, session: session)
                } trailing: {
                    DSIconButton(icon: "arrow.counterclockwise", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Detail",
                    subtitle: "Hero card + actions.",
                    leadingIcon: "square.stack.3d.up.fill"
                ) {
                    router.navigateTo(.detail(title: "Studio detail"), for: .home)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Profile",
                    subtitle: "Avatar, stats, and actions.",
                    leadingIcon: "person.fill"
                ) {
                    let userId = session.auth?.uid ?? "guest"
                    router.navigateTo(.profile(userId: userId), for: .home)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Paywall",
                    subtitle: "Plan selector + CTA.",
                    leadingIcon: "creditcard.fill"
                ) {
                    router.presentSheet(.paywall)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: DemoContent.Home.designSystemGalleryTitle,
                    subtitle: DemoContent.Home.designSystemGallerySubtitle,
                    leadingIcon: "square.grid.2x2"
                ) {
                    router.navigateTo(.designSystemGallery, for: .home)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
