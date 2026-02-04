//
//  HomeViewModel.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

enum HomeHighlightKind {
    case onboarding
    case analytics
    case monetization
    case community
}

@MainActor
@Observable
final class HomeViewModel {
    struct Highlight: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let kind: HomeHighlightKind
    }

    var highlights: [Highlight] = []
    var isLoading = false
    var errorMessage: String?
    var toast: Toast?

    private var hasLoaded = false

    func onAppear(services: AppServices, session: AppSession) {
        services.logManager.trackEvent(event: Event.onAppear(isSignedIn: session.isSignedIn))
        guard !hasLoaded else { return }
        hasLoaded = true

        Task {
            await loadHighlights(services: services, session: session)
        }
    }

    func loadHighlights(services: AppServices, session: AppSession) async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(for: .milliseconds(450))

        if let lastError = session.lastErrorMessage, !lastError.isEmpty {
            errorMessage = lastError
            highlights = []
        } else if session.isSignedIn {
            highlights = [
                Highlight(
                    title: "Onboarding ready",
                    message: "Three-step flow with progress tracking and analytics baked in.",
                    kind: .onboarding
                ),
                Highlight(
                    title: "Growth analytics",
                    message: "Events, properties, and attribution hooks are wired and ready.",
                    kind: .analytics
                ),
                Highlight(
                    title: "Monetization routes",
                    message: "Paywall, entitlements, and restore flows are production-ready.",
                    kind: .monetization
                )
            ]
        } else {
            highlights = []
        }

        isLoading = false
    }

    func seedHighlights(services: AppServices) {
        highlights = [
            Highlight(
                title: "Start with a template",
                message: "Duplicate the demo flow and tailor it to your product.",
                kind: .community
            )
        ]
        toast = .success("Sample highlight added.")
        services.logManager.trackEvent(event: Event.sampleHighlightAdded)
    }

    func resetOnboarding(services: AppServices, session: AppSession) {
        session.resetOnboarding()
        toast = .info("Onboarding reset. Next launch will show the intro flow.")
        services.logManager.trackEvent(event: Event.resetOnboarding)
    }

    func resetPaywall(services: AppServices, session: AppSession) {
        session.resetPaywallDismissal()
        toast = .info("Paywall will be shown again on next launch.")
        services.logManager.trackEvent(event: Event.resetPaywall)
    }
}

extension HomeViewModel {
    enum Event: LoggableEvent {
        case onAppear(isSignedIn: Bool)
        case resetOnboarding
        case resetPaywall
        case sampleHighlightAdded

        var eventName: String {
            switch self {
            case .onAppear:
                return "Home_Appear"
            case .resetOnboarding:
                return "Home_Reset_Onboarding"
            case .resetPaywall:
                return "Home_Reset_Paywall"
            case .sampleHighlightAdded:
                return "Home_Sample_Highlight"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let isSignedIn):
                return ["is_signed_in": isSignedIn]
            default:
                return nil
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
