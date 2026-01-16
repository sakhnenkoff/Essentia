//
//  AppRootView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

struct AppRootView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session

    var body: some View {
        Group {
            switch session.rootState {
            case .loading:
                ProgressView("Preparing your demo...")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AmbientBackground())
            case .onboarding:
                OnboardingView()
            case .auth:
                AuthView()
            case .paywall:
                PaywallView()
            case .app:
                AppTabsView()
            }
        }
        .task {
            await session.bootstrap(services: services)
        }
    }
}
