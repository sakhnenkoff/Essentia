//
//  SettingsDetailView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

struct SettingsDetailView: View {
    @Environment(AppServices.self) private var services
    @State private var viewModel = SettingsDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header

                if viewModel.isProcessing {
                    ProgressView("Requesting permission...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                privacySection
                trackingSection

                if viewModel.needsRestart {
                    infoCard(
                        title: "Restart recommended",
                        message: "Restart the app to apply analytics changes.",
                        icon: "arrow.clockwise"
                    )
                }

                if AppConfiguration.isMock {
                    infoCard(
                        title: "Mock build",
                        message: "Analytics and tracking SDKs are disabled in Mock builds.",
                        icon: "flask"
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(
                        title: "Privacy update failed",
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
        .background(AmbientBackground())
        .navigationTitle("Settings Detail")
        .onAppear {
            viewModel.onAppear(services: services)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Privacy & data")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Control analytics and tracking preferences for the demo experience.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var privacySection: some View {
        section(title: "Analytics") {
            listCard {
                DSListRow(
                    title: "Share analytics",
                    subtitle: "Help us improve onboarding.",
                    leadingIcon: "chart.line.uptrend.xyaxis"
                ) {
                    viewModel.setAnalyticsOptIn(!viewModel.analyticsOptIn, services: services)
                } trailing: {
                    GlassToggle(isOn: Binding(
                        get: { viewModel.analyticsOptIn },
                        set: { viewModel.setAnalyticsOptIn($0, services: services) }
                    ))
                }

                Divider()

                DSListRow(
                    title: "What we collect",
                    subtitle: "Anonymized engagement data.",
                    leadingIcon: "doc.text.magnifyingglass",
                    leadingTint: .textSecondary,
                    titleColor: .textPrimary
                )
            }
        }
    }

    private var trackingSection: some View {
        section(title: "Tracking") {
            listCard {
                DSListRow(
                    title: "Allow tracking (ATT)",
                    subtitle: "Personalize the demo.",
                    leadingIcon: "hand.raised"
                ) {
                    viewModel.setTrackingOptIn(!viewModel.trackingOptIn, services: services)
                } trailing: {
                    GlassToggle(isOn: Binding(
                        get: { viewModel.trackingOptIn },
                        set: { viewModel.setTrackingOptIn($0, services: services) }
                    ))
                }

                Divider()

                DSListRow(
                    title: "Tracking status",
                    subtitle: viewModel.trackingStatusLabel,
                    leadingIcon: "lock.shield",
                    leadingTint: .textSecondary,
                    titleColor: .textPrimary
                )

                Divider()

                DSListRow(
                    title: "Request authorization",
                    subtitle: "Show the system dialog.",
                    leadingIcon: "checkmark.seal"
                ) {
                    viewModel.requestTrackingAuthorization(services: services)
                } trailing: {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                .disabled(!viewModel.trackingOptIn || viewModel.isProcessing || AppConfiguration.isMock)
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

    private func infoCard(title: String, message: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            HeroIcon(systemName: icon, size: 20, tint: Color.warning)

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
        .padding(DSSpacing.md)
        .cardSurface(
            cornerRadius: DSRadii.lg,
            tint: Color.warning.opacity(0.06),
            shadowRadius: 6,
            shadowYOffset: 3
        )
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
}
