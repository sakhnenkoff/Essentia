//
//  OnboardingView.swift
//  AppTemplateLite
//
//

import SwiftUI
import DesignSystem

struct OnboardingView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var controller = OnboardingController()

    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeader(
                progress: controller.progress,
                showBackButton: controller.canGoBack,
                onBack: {
                    withAnimation(.smooth(duration: 0.5)) {
                        controller.goBack()
                    }
                }
            )

            // Animated headline area
            headlineArea
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.xl)

            // Step-specific content
            stepContent
                .frame(maxHeight: .infinity)

            DSButton.cta(
                title: controller.isLastStep ? "Get Started" : "Continue",
                isEnabled: controller.canContinue
            ) {
                onContinue()
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.lg)
        }
        .background(Color.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            trackEvent(.onAppear)
        }
        .onDisappear {
            trackEvent(.onDisappear)
        }
    }

    // MARK: - Animated Headline

    private var headlineArea: some View {
        ZStack(alignment: .topLeading) {
            Text(controller.currentStep.headline)
                .id(controller.currentStep)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .transition(LineByLineTransition())

            if let subtitle = controller.currentStep.subtitle {
                Text(subtitle)
                    .id("subtitle-\(controller.currentStep)")
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
                    .transition(LineByLineTransition(duration: 0.5))
                    .padding(.top, 80)
            }
        }
        .frame(minHeight: 140, alignment: .topLeading)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch controller.currentStep {
        case .welcome:
            welcomeContent
        case .goals:
            goalsContent
        case .name:
            nameContent
        }
    }

    // MARK: - Welcome Step

    private var welcomeContent: some View {
        VStack {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(Color.themePrimary)
                .transition(.scale.combined(with: .opacity))

            Spacer()
        }
        .padding(.horizontal, DSSpacing.lg)
    }

    // MARK: - Goals Step

    private var goalsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            VStack(spacing: DSSpacing.sm) {
                DSChoiceButton(
                    title: "Launch fast",
                    icon: "paperplane.fill",
                    isSelected: controller.selectedGoals.contains("launch")
                ) {
                    controller.toggleGoal("launch")
                }

                DSChoiceButton(
                    title: "Monetize",
                    icon: "creditcard.fill",
                    isSelected: controller.selectedGoals.contains("monetize")
                ) {
                    controller.toggleGoal("monetize")
                }

                DSChoiceButton(
                    title: "Measure growth",
                    icon: "chart.line.uptrend.xyaxis",
                    isSelected: controller.selectedGoals.contains("measure")
                ) {
                    controller.toggleGoal("measure")
                }
            }

            Spacer()
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.md)
    }

    // MARK: - Name Step

    private var nameContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            DSTextField.name(
                placeholder: "Your name",
                text: $controller.userName
            )

            Spacer()
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.md)
    }

    // MARK: - Actions

    private func onContinue() {
        trackEvent(.stepComplete(result: controller.stepResult()))

        withAnimation(.smooth(duration: 0.5)) {
            let completed = controller.goNext()
            if completed {
                completeOnboarding()
            }
        }
    }

    private func completeOnboarding() {
        trackEvent(.flowComplete(result: controller.flowResult))

        Task {
            if session.isSignedIn {
                try? await services.userManager.saveOnboardingCompleteForCurrentUser()
            }
            session.setOnboardingComplete()
        }
    }

    private func trackEvent(_ event: OnboardingEvent) {
        services.logManager.trackEvent(event: event)
    }
}

// MARK: - Analytics Events

private enum OnboardingEvent: LoggableEvent {
    case onAppear
    case onDisappear
    case stepComplete(result: [String: Any])
    case flowComplete(result: [String: Any])

    var eventName: String {
        switch self {
        case .onAppear:
            "Onboarding_Appear"
        case .onDisappear:
            "Onboarding_Disappear"
        case .stepComplete:
            "Onboarding_StepComplete"
        case .flowComplete:
            "Onboarding_FlowComplete"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .stepComplete(let result):
            result
        case .flowComplete(let result):
            result
        default:
            nil
        }
    }

    var type: LogType {
        .analytic
    }
}

#Preview {
    OnboardingView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}
