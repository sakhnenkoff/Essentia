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
                ZStack {
                    Color.backgroundPrimary.ignoresSafeArea()
                    LoadingView(message: "Preparing your demo...", style: .default)
                }
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
