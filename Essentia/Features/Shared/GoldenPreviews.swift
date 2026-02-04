import SwiftUI
import AppRouter

#Preview("Home") {
    NavigationStack {
        HomeView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
    .environment(AppSession())
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}

#Preview("Auth") {
    AuthView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}

#Preview("Paywall") {
    NavigationStack {
        PaywallView(showCloseButton: true)
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
    .environment(AppSession())
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
    .environment(AppSession())
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .settings))
}
