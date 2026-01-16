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
        ZStack {
            PremiumBackground()

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

                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    // Animated headline area
                    headlineArea
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, DSSpacing.lg)

                    // Step-specific content
                    stepContent
                }
                .padding(.horizontal, DSSpacing.lg)

                Spacer(minLength: DSSpacing.sm)

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
                    .padding(.horizontal, DSSpacing.lg)
                }

                if isSaving {
                    ProgressView("Setting up your workspace...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, DSSpacing.lg)
                }

                DSButton.cta(
                    title: controller.isLastStep ? "Get Started" : "Continue",
                    isEnabled: controller.canContinue
                ) {
                    onContinue()
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.bottom, DSSpacing.lg)
            }
        }
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
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(controller.currentStep.title.uppercased())
                .id("step-title-\(controller.currentStep)")
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)
                .transition(LineByLineTransition(duration: 0.4))

            ZStack(alignment: .topLeading) {
                Text(controller.currentStep.headline)
                    .id(controller.currentStep)
                    .font(.titleLarge())
                    .foregroundStyle(Color.textPrimary)
                    .transition(LineByLineTransition())
            }

            if let subtitle = controller.currentStep.subtitle {
                ZStack(alignment: .topLeading) {
                    Text(subtitle)
                        .id("subtitle-\(controller.currentStep)")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)
                        .transition(LineByLineTransition(duration: 0.5))
                }
            }
        }
        .frame(minHeight: 132, alignment: .topLeading)
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
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            welcomeHeroCard

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
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
                EmptyStateView(
                    icon: "sparkles",
                    title: "Nothing selected yet",
                    message: "Pick at least one goal to unlock the next step.",
                    actionTitle: "Select a goal",
                    action: { controller.toggleGoal("launch") }
                )
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

    private var welcomeHeroCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: "wand.and.stars")
                    .font(.headlineLarge())
                    .foregroundStyle(Color.themePrimary)
                    .frame(width: 52, height: 52)
                    .background(Color.themePrimary.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Launch with confidence")
                        .font(.headlineMedium())
                        .foregroundStyle(Color.textPrimary)
                    Text("Designed for joyful first-run experiences.")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Text("Everything here is structured, accessible, and ready for production.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .glassBackground(cornerRadius: DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    private func featureRow(icon: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.headlineSmall())
                .foregroundStyle(Color.themePrimary)
                .frame(width: 28, height: 28)
                .background(Color.themePrimary.opacity(0.15))
                .clipShape(Circle())

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
