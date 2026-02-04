//
//  EssentiaApp.swift
//  Essentia
//
//
//

import SwiftUI

@main
struct EssentiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var services: AppServices
    @State private var session = AppSession()

    init() {
        let configuration = BuildConfiguration.current
        configuration.configureFirebase()
        _services = State(initialValue: AppServices(configuration: configuration))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(services)
                .environment(session)
        }
    }
}
