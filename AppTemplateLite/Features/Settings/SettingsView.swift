//
//  SettingsView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter

struct SettingsView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section("Account") {
                if session.isSignedIn {
                    LabeledContent("User ID", value: session.auth?.uid ?? "unknown")
                    if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                        LabeledContent("Email", value: email)
                    }
                } else {
                    Text("Not signed in")
                        .foregroundStyle(.secondary)
                }

                Button("Sign out", role: .destructive) {
                    viewModel.signOut(services: services, session: session)
                }
                .disabled(!session.isSignedIn || viewModel.isProcessing)

                Button("Delete account", role: .destructive) {
                    viewModel.deleteAccount(services: services, session: session)
                }
                .disabled(!session.isSignedIn || viewModel.isProcessing)
            }

            Section("Monetization") {
                LabeledContent("Premium", value: session.isPremium ? "Active" : "Free")

                Button("View paywall") {
                    router.presentSheet(.paywall)
                }
                .disabled(!FeatureFlags.enablePurchases)
            }

            Section("Notifications") {
                Button("Enable push notifications") {
                    viewModel.requestPushAuthorization(services: services)
                }
                .disabled(!FeatureFlags.enablePushNotifications)
            }

            Section("Navigation") {
                Button("Open settings detail") {
                    router.navigateTo(.settingsDetail, for: .settings)
                }
                Button("Open profile") {
                    router.navigateTo(.profile(userId: session.auth?.uid ?? "guest"), for: .settings)
                }
            }

            Section("Debug") {
                Button("Reset onboarding") {
                    session.resetOnboarding()
                }
                Button("Reset paywall prompt") {
                    session.resetPaywallDismissal()
                }
                Button("Open debug menu") {
                    router.presentSheet(.debug)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if viewModel.isProcessing {
                Section {
                    ProgressView("Working...")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
