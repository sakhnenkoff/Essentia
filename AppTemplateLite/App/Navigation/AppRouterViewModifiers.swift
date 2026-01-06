//
//  AppRouterViewModifiers.swift
//  AppTemplateLite
//
//
//

import SwiftUI

extension View {
    func withAppRouterDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .detail(let title):
                DetailView(title: title)
            case .profile(let userId):
                ProfileView(userId: userId)
            case .settingsDetail:
                SettingsDetailView()
            }
        }
    }
}
