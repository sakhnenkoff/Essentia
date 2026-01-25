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
    @State private var demoFrequency = "Daily"
    @State private var demoToggle = true
    @State private var demoPillToggle = true
    @State private var demoName = ""
    @State private var demoEmail = ""
    @State private var showSkeletonDemo = true
    @State private var demoTime = Date()
    @State private var selectedChoices: Set<String> = ["Fast launch"]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DSSpacing.xl) {
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.selectedTab = .settings
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Color.themePrimary)
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
                GlassCard(usesGlass: true, tilt: -2) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Buttons")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        HStack(spacing: DSSpacing.sm) {
                            DSButton(title: "Primary") { }
                            DSButton(title: "Secondary", style: .secondary) { }
                        }

                        HStack(spacing: DSSpacing.sm) {
                            DSButton(title: "Text only", style: .tertiary) { }
                            DSButton(title: "Destructive", style: .destructive) { }
                        }
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Controls")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        DSSegmentedControl(items: ["Daily", "Weekly", "Monthly"], selection: $demoFrequency)

                        HStack(spacing: DSSpacing.sm) {
                            GlassToggle(isOn: $demoToggle)
                            DSPillToggle(isOn: $demoPillToggle, icon: "leaf.fill")
                            TimePill(time: $demoTime, usesGlass: true)
                        }
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        Text("Inputs")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        DSTextField(
                            placeholder: "Your name",
                            text: $demoName,
                            autocapitalization: .words,
                            style: .underline
                        )

                        DSTextField(
                            placeholder: "Email",
                            text: $demoEmail,
                            keyboardType: .emailAddress,
                            autocapitalization: .never,
                            style: .underline
                        )
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
                            DSIconButton(icon: "xmark", style: .tertiary, size: .small, usesGlass: false)
                            TagBadge(text: "Featured")
                        }
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Selection")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        DSChoiceButton(
                            title: "Fast launch",
                            icon: "paperplane.fill",
                            isSelected: selectedChoices.contains("Fast launch")
                        ) {
                            toggleChoice("Fast launch")
                        }

                        DSChoiceButton(
                            title: "Monetize",
                            icon: "creditcard.fill",
                            isSelected: selectedChoices.contains("Monetize")
                        ) {
                            toggleChoice("Monetize")
                        }

                        DSChoiceButton(
                            title: "Measure growth",
                            icon: "chart.line.uptrend.xyaxis",
                            isSelected: selectedChoices.contains("Measure growth")
                        ) {
                            toggleChoice("Measure growth")
                        }
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("List rows")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        VStack(spacing: 0) {
                            DSListRow(
                                title: "Daily prompt",
                                subtitle: "Add one memory.",
                                leadingIcon: "doc.text"
                            ) {
                                TagBadge(text: "New")
                            }
                            Divider()
                            DSListRow(
                                title: "Reminder time",
                                subtitle: "Set a calm nudge.",
                                leadingIcon: "bell.fill"
                            ) {
                                TimePill(title: "17:00")
                            }
                        }
                        .cardSurface(cornerRadius: DSRadii.lg)
                    }
                }

                GlassCard(usesGlass: false, tilt: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("States")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        // Shimmer loading demo
                        HStack(spacing: DSSpacing.sm) {
                            Circle()
                                .fill(Color.surfaceVariant)
                                .frame(width: 44, height: 44)
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                Text("Profile Name")
                                    .font(.headlineSmall())
                                Text("Loading content...")
                                    .font(.bodySmall())
                            }
                            Spacer()
                        }
                        .shimmer(showSkeletonDemo)

                        DSButton(title: showSkeletonDemo ? "Stop shimmer" : "Start shimmer", style: .secondary) {
                            showSkeletonDemo.toggle()
                        }

                        DSButton(title: "Show Toast", style: .tertiary) {
                            viewModel.toast = Toast(style: .success, message: "Action completed!")
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

    private func toggleChoice(_ choice: String) {
        if selectedChoices.contains(choice) {
            selectedChoices.remove(choice)
        } else {
            selectedChoices.insert(choice)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
