//
//  DebugMenuView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import UIKit

struct DebugMenuView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var copyStatus: String?

    var body: some View {
        Form {
            Section("Environment") {
                LabeledContent("Build", value: AppConfiguration.environment)
                LabeledContent("Premium", value: session.isPremium ? "true" : "false")
                LabeledContent("Onboarding", value: session.isOnboardingComplete ? "complete" : "incomplete")
            }

            Section("User") {
                LabeledContent("User ID", value: session.auth?.uid ?? "none")
                if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                    LabeledContent("Email", value: email)
                }
            }

            Section("Actions") {
                Button("Reset onboarding") {
                    session.resetOnboarding()
                }
                Button("Reset paywall") {
                    session.resetPaywallDismissal()
                }
                Button("Copy Mixpanel Distinct ID") {
                    copyToPasteboard(Constants.mixpanelDistinctId)
                }
                Button("Copy Firebase Instance ID") {
                    copyToPasteboard(Constants.firebaseAnalyticsAppInstanceID)
                }
            }

            if let copyStatus {
                Section {
                    Text(copyStatus)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Debug Menu")
    }

    private func copyToPasteboard(_ value: String?) {
        guard let value, !value.isEmpty else {
            copyStatus = "Value not available."
            return
        }
        UIPasteboard.general.string = value
        copyStatus = "Copied!"
        services.logManager.trackEvent(
            eventName: "Debug_Copy",
            parameters: ["value_length": value.count],
            type: .analytic
        )
    }
}

#Preview {
    NavigationStack {
        DebugMenuView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
    .environment(AppSession())
}
