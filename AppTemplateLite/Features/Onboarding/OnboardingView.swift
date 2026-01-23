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
    @State private var isSaving = false
    @State private var errorMessage: String?

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

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    stepHeader

                    stepContent

                    if let errorMessage = errorMessage {
                        ErrorStateView(
                            title: "Couldn't finish setup",
                            message: errorMessage,
                            retryTitle: "Try again",
                            onRetry: { completeOnboarding() },
                            dismissTitle: "Continue anyway",
                            onDismiss: {
                                self.errorMessage = nil
                                session.setOnboardingComplete()
                            }
                        )
                    }

                    if isSaving {
                        ProgressView("Setting up your workspace...")
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AmbientBackground())
        .safeAreaInset(edge: .bottom) {
            ctaBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            trackEvent(.onAppear)
        }
        .onDisappear {
            trackEvent(.onDisappear)
        }
    }

    // MARK: - Step Header

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(controller.currentStep.title.uppercased())
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)

            Text(controller.currentStep.headline)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)

            if let subtitle = controller.currentStep.subtitle {
                Text(subtitle)
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("What you get")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                Text("Everything you need to ship a polished demo quickly.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: DSSpacing.sm) {
                featureRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Guided onboarding",
                    message: "Progress tracking and analytics are wired in."
                )
                featureRow(
                    icon: "creditcard.fill",
                    title: "Monetization ready",
                    message: "StoreKit and custom paywall layouts included."
                )
                featureRow(
                    icon: "paintbrush.pointed.fill",
                    title: "Design system",
                    message: "Semantic colors, typography, and spacing rules."
                )
            }
        }
    }

    // MARK: - Goals Step

    private var goalsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("Choose a focus")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                Text("Select a couple of goals to personalize this demo.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }

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

            if controller.selectedGoals.isEmpty {
                Text("Select at least one goal to continue.")
                    .font(.captionLarge())
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }

    // MARK: - Name Step

    private var nameContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            Text("Your name")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            DSTextField.name(
                placeholder: "Your name",
                text: $controller.userName
            )

            Text("We use this to personalize your demo experience.")
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)
        }
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
            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

            do {
                if session.isSignedIn {
                    try await services.userManager.saveOnboardingCompleteForCurrentUser()
                }
                session.setOnboardingComplete()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func trackEvent(_ event: OnboardingEvent) {
        services.logManager.trackEvent(event: event)
    }

    private func featureRow(icon: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            DSIconBadge(systemName: icon)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var ctaBar: some View {
        VStack(spacing: DSSpacing.sm) {
            Divider()

            DSButton.cta(
                title: controller.isLastStep ? "Get Started" : "Continue",
                isEnabled: controller.canContinue
            ) {
                onContinue()
            }
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.lg)
        .background(Color.backgroundPrimary)
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
