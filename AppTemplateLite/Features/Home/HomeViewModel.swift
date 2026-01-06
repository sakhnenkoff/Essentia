//
//  HomeViewModel.swift
//  AppTemplateLite
//
//
//

import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    func onAppear(services: AppServices, session: AppSession) {
        services.logManager.trackEvent(event: Event.onAppear(isSignedIn: session.isSignedIn))
    }
}

extension HomeViewModel {
    enum Event: LoggableEvent {
        case onAppear(isSignedIn: Bool)

        var eventName: String {
            "Home_Appear"
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let isSignedIn):
                return ["is_signed_in": isSignedIn]
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
