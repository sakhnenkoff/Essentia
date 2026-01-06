//
//  AppTabsView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter
import Foundation

struct AppTabsView: View {
    @Environment(AppServices.self) private var services
    @State private var router = Router<AppTab, AppRoute, AppSheet>(initialTab: .home)

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack(path: $router[tab]) {
                    tab.makeContentView()
                        .withAppRouterDestinations()
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .environment(router)
        .onOpenURL { url in
            router.navigate(to: url)
        }
        .onReceive(NotificationCenter.default.publisher(for: .pushNotification)) { notification in
            guard FeatureFlags.enablePushNotifications else { return }
            guard let userInfo = notification.userInfo else { return }
            guard let navigation = PushRouteParser.parse(userInfo: userInfo) else { return }

            if let tab = navigation.tab {
                router.selectedTab = tab
            }

            if let deepLink = navigation.deepLink {
                router.navigate(to: deepLink)
            } else {
                if let route = navigation.route {
                    router.navigateTo(route, for: navigation.tab ?? router.selectedTab)
                }
                if let sheet = navigation.sheet {
                    router.presentSheet(sheet)
                }
            }

            services.logManager.trackEvent(
                eventName: "Push_Open",
                parameters: navigation.eventParameters,
                type: .analytic
            )
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .paywall:
            NavigationSheet {
                PaywallView(showCloseButton: true)
            }
        case .settings:
            NavigationSheet {
                SettingsDetailView()
            }
        case .debug:
            NavigationSheet {
                DebugMenuView()
            }
        }
    }
}
