//
//  AppTabsView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter

struct AppTabsView: View {
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
