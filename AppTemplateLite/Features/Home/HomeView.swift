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
                hero
                screensSection
                componentsSection
            }
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
        .navigationTitle("Home")
        .toast($viewModel.toast)
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            AppTopIcon(systemName: "scribble.variable")
            Text("Design system showcase")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Calm components with sketch icons and focused glass accents.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var screensSection: some View {
        section(title: "Screens") {
            listCard {
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
            }
        }
    }

    private var componentsSection: some View {
        section(title: "Components") {
            VStack(spacing: DSSpacing.md) {
                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Buttons")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        HStack(spacing: DSSpacing.sm) {
                            GlassButton(title: "Primary") { }
                            GlassButton(title: "Secondary", style: .secondary) { }
                        }
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Controls")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        GlassSegmentedControl(items: ["Daily", "Weekly", "Monthly"], selection: .constant("Daily"))

                        HStack(spacing: DSSpacing.sm) {
                            GlassToggle(isOn: .constant(true))
                            PickerPill(title: "17:00", usesGlass: true)
                        }
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Tiles")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        HStack(spacing: DSSpacing.sm) {
                            IconTileButton(systemName: "heart")
                            IconTileButton(systemName: "tray.and.arrow.down")
                            TagBadge(text: "Featured")
                        }
                    }
                }
            }
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
        .cardSurface(cornerRadius: DSRadii.lg)
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
