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
        DSScreen(title: DemoContent.SettingsDetail.navigationTitle) {
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
                    DSInfoCard(
                        title: DemoContent.SettingsDetail.restartTitle,
                        message: DemoContent.SettingsDetail.restartMessage,
                        icon: "arrow.clockwise",
                        tint: .warning
                    )
                }

                if AppConfiguration.isMock {
                    DSInfoCard(
                        title: DemoContent.SettingsDetail.mockTitle,
                        message: DemoContent.SettingsDetail.mockMessage,
                        icon: "flask",
                        tint: .info
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
        }
        .onAppear {
            viewModel.onAppear(services: services)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(DemoContent.SettingsDetail.headerTitle)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text(DemoContent.SettingsDetail.headerSubtitle)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var privacySection: some View {
        DSSection(title: DemoContent.Sections.analytics) {
            DSListCard {
                DSListRow(
                    title: "Share analytics",
                    subtitle: "Help us improve onboarding.",
                    leadingIcon: "chart.line.uptrend.xyaxis"
                ) {
                    GlassToggle(isOn: Binding(
                        get: { viewModel.analyticsOptIn },
                        set: { viewModel.setAnalyticsOptIn($0, services: services) }
                    ), accessibilityLabel: "Share analytics")
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
        DSSection(title: DemoContent.Sections.tracking) {
            DSListCard {
                DSListRow(
                    title: "Allow tracking (ATT)",
                    subtitle: "Personalize the demo.",
                    leadingIcon: "hand.raised"
                ) {
                    GlassToggle(isOn: Binding(
                        get: { viewModel.trackingOptIn },
                        set: { viewModel.setTrackingOptIn($0, services: services) }
                    ), accessibilityLabel: "Allow tracking")
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

}

#Preview {
    NavigationStack {
        SettingsDetailView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
}
