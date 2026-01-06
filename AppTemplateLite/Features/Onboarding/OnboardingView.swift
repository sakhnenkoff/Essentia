//
//  OnboardingView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import SwiftfulOnboarding
import DesignSystem

struct OnboardingView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        SwiftfulOnboardingView(
            configuration: OnbConfiguration(
                headerConfiguration: OnboardingConstants.headerConfiguration,
                slides: OnboardingConstants.slides,
                slideDefaults: OnboardingConstants.slideDefaults,
                onSlideComplete: { slideData in
                    viewModel.onSlideComplete(slideData: slideData, services: services)
                },
                onFlowComplete: { flowData in
                    viewModel.onFlowComplete(flowData: flowData, services: services, session: session)
                }
            )
        )
        .tint(Color.themeAccent)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onViewAppear(services: services)
        }
        .onDisappear {
            viewModel.onViewDisappear(services: services)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}
