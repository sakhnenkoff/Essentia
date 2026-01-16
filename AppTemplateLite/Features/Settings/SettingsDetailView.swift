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
        ZStack {
            PremiumBackground()

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
        }
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
        sectionCard(title: "Analytics") {
            Toggle(
                "Share analytics",
                isOn: Binding(
                    get: { viewModel.analyticsOptIn },
                    set: { viewModel.setAnalyticsOptIn($0, services: services) }
                )
            )
            .tint(Color.themePrimary)

            Text("Analytics help us understand onboarding and paywall performance.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var trackingSection: some View {
        sectionCard(title: "Tracking") {
            Toggle(
                "Allow tracking (ATT)",
                isOn: Binding(
                    get: { viewModel.trackingOptIn },
                    set: { viewModel.setTrackingOptIn($0, services: services) }
                )
            )
            .tint(Color.themePrimary)

            keyValueRow(title: "Tracking status", value: viewModel.trackingStatusLabel)

            DSButton(title: "Request tracking authorization", style: .secondary, isFullWidth: true) {
                viewModel.requestTrackingAuthorization(services: services)
            }
            .disabled(!viewModel.trackingOptIn || viewModel.isProcessing || AppConfiguration.isMock)
        }
    }

    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            content()
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    private func keyValueRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)
            Text(value)
                .font(.bodySmall())
                .foregroundStyle(Color.textPrimary)
        }
    }

    private func infoCard(title: String, message: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.headlineSmall())
                .foregroundStyle(Color.warning)
                .frame(width: 28, height: 28)
                .background(Color.warning.opacity(0.15))
                .clipShape(Circle())

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
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 8, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
}
