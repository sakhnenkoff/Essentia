//
//  DebugMenuView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import UIKit
import DesignSystem

struct DebugMenuView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var toast: Toast?

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    header
                    environmentSection
                    userSection
                    actionSection
                }
                .padding(DSSpacing.md)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Debug Menu")
        .toast($toast)
    }

    private func copyToPasteboard(_ value: String?) {
        guard let value, !value.isEmpty else {
            toast = .warning("Value not available.")
            return
        }
        UIPasteboard.general.string = value
        toast = .success("Copied to clipboard.")
        services.logManager.trackEvent(
            eventName: "Debug_Copy",
            parameters: ["value_length": value.count],
            type: .analytic
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Developer utilities")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Quick access to environment info and demo reset actions.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var environmentSection: some View {
        sectionCard(title: "Environment") {
            keyValueRow(title: "Build", value: AppConfiguration.environment)
            keyValueRow(title: "Premium", value: session.isPremium ? "true" : "false")
            keyValueRow(title: "Onboarding", value: session.isOnboardingComplete ? "complete" : "incomplete")
        }
    }

    private var userSection: some View {
        sectionCard(title: "User") {
            keyValueRow(title: "User ID", value: session.auth?.uid ?? "none")
            if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                keyValueRow(title: "Email", value: email)
            }
        }
    }

    private var actionSection: some View {
        sectionCard(title: "Actions") {
            VStack(spacing: DSSpacing.sm) {
                DSButton(title: "Reset onboarding", style: .secondary, isFullWidth: true) {
                    session.resetOnboarding()
                    toast = .info("Onboarding reset.")
                }
                DSButton(title: "Reset paywall", style: .secondary, isFullWidth: true) {
                    session.resetPaywallDismissal()
                    toast = .info("Paywall reset.")
                }
                DSButton(title: "Copy Mixpanel Distinct ID", style: .tertiary, isFullWidth: true) {
                    copyToPasteboard(Constants.mixpanelDistinctId)
                }
                DSButton(title: "Copy Firebase Instance ID", style: .tertiary, isFullWidth: true) {
                    copyToPasteboard(Constants.firebaseAnalyticsAppInstanceID)
                }
            }
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
}

#Preview {
    NavigationStack {
        DebugMenuView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
    .environment(AppSession())
}
