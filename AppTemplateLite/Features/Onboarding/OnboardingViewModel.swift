//
//  OnboardingViewModel.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import SwiftfulOnboarding

@MainActor
@Observable
final class OnboardingViewModel {
    func onViewAppear(services: AppServices) {
        services.logManager.trackEvent(event: Event.onAppear)
    }

    func onViewDisappear(services: AppServices) {
        services.logManager.trackEvent(event: Event.onDisappear)
    }

    func onSlideComplete(slideData: OnbSlideData, services: AppServices) {
        services.logManager.trackEvent(event: Event.slideComplete(slideId: slideData.slideId))
    }

    func onFlowComplete(flowData: OnbFlowData, services: AppServices, session: AppSession) {
        services.logManager.trackEvent(event: Event.flowComplete(flowData: flowData))

        Task { [weak self] in
            guard self != nil else { return }
            if session.isSignedIn {
                try? await services.userManager.saveOnboardingCompleteForCurrentUser()
            }
            session.setOnboardingComplete()
        }
    }
}

extension OnboardingViewModel {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case slideComplete(slideId: String)
        case flowComplete(flowData: OnbFlowData)

        var eventName: String {
            switch self {
            case .onAppear:
                return "Onboarding_Appear"
            case .onDisappear:
                return "Onboarding_Disappear"
            case .slideComplete:
                return "Onboarding_SlideComplete"
            case .flowComplete:
                return "Onboarding_FlowComplete"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .slideComplete(let slideId):
                return ["slide_id": slideId]
            case .flowComplete(let flowData):
                return flowData.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
