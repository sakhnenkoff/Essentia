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
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                environmentSection
                userSection
                actionSection
            }
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
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

    private var environmentSection: some View {
        section(title: "Environment") {
            listCard {
                DSListRow(
                    title: "Build",
                    subtitle: AppConfiguration.environment,
                    leadingIcon: "wrench"
                ) {
                    TagBadge(text: AppConfiguration.environment, tint: .textSecondary)
                }
                Divider()
                DSListRow(
                    title: "Premium",
                    subtitle: session.isPremium ? "true" : "false",
                    leadingIcon: "sparkles"
                ) {
                    TagBadge(text: session.isPremium ? "true" : "false", tint: .textSecondary)
                }
                Divider()
                DSListRow(
                    title: "Onboarding",
                    subtitle: session.isOnboardingComplete ? "complete" : "incomplete",
                    leadingIcon: "checkmark.seal"
                ) {
                    TagBadge(text: session.isOnboardingComplete ? "complete" : "incomplete", tint: .textSecondary)
                }
            }
        }
    }

    private var userSection: some View {
        section(title: "User") {
            listCard {
                DSListRow(
                    title: "User ID",
                    subtitle: session.auth?.uid ?? "none",
                    leadingIcon: "person.crop.circle"
                ) {
                    copyToPasteboard(session.auth?.uid)
                } trailing: {
                    DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                }

                if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                    Divider()
                    DSListRow(
                        title: "Email",
                        subtitle: email,
                        leadingIcon: "envelope"
                    ) {
                        copyToPasteboard(email)
                    } trailing: {
                        DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                    }
                }
            }
        }
    }

    private var actionSection: some View {
        section(title: "Actions") {
            listCard {
                DSListRow(
                    title: "Reset onboarding",
                    subtitle: "Restart the setup flow.",
                    leadingIcon: "arrow.counterclockwise"
                ) {
                    session.resetOnboarding()
                    toast = .info("Onboarding reset.")
                } trailing: {
                    DSIconButton(icon: "arrow.counterclockwise", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Reset paywall",
                    subtitle: "Show on next launch.",
                    leadingIcon: "sparkles"
                ) {
                    session.resetPaywallDismissal()
                    toast = .info("Paywall reset.")
                } trailing: {
                    DSIconButton(icon: "arrow.counterclockwise", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Copy Mixpanel Distinct ID",
                    subtitle: "Developer identifier.",
                    leadingIcon: "doc.on.doc"
                ) {
                    copyToPasteboard(Constants.mixpanelDistinctId)
                } trailing: {
                    DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(
                    title: "Copy Firebase Instance ID",
                    subtitle: "Analytics identifier.",
                    leadingIcon: "doc.on.doc"
                ) {
                    copyToPasteboard(Constants.firebaseAnalyticsAppInstanceID)
                } trailing: {
                    DSIconButton(icon: "doc.on.doc", style: .secondary, size: .small)
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
    NavigationStack {
        DebugMenuView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
    .environment(AppSession())
}
