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
                    withAnimation(.easeInOut(duration: 0.25)) {
                        controller.goBack()
                    }
                }
            )

            ScrollView {
                VStack(alignment: .center, spacing: DSSpacing.xl) {
                    heroIcon
                    headlineView
                    subtitleView
                    cardContent

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
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DSSpacing.xl)
                .padding(.top, DSSpacing.xl)
                .padding(.bottom, DSSpacing.xxl)
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

    private var heroIcon: some View {
        HeroIcon(systemName: controller.currentStep.icon, size: 28)
    }

    private var headlineView: some View {
        (
            Text(controller.currentStep.headlineLeading)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            + Text(controller.currentStep.headlineHighlight)
                .font(.titleLarge())
                .foregroundStyle(Color.themePrimary)
            + Text(controller.currentStep.headlineTrailing)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
        )
        .multilineTextAlignment(.center)
        .lineSpacing(4)
    }

    private var subtitleView: some View {
        Text(controller.currentStep.subtitle)
            .font(.bodyMedium())
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 260)
    }

    @ViewBuilder
    private var cardContent: some View {
        switch controller.currentStep {
        case .welcome:
            welcomeCard
        case .goals:
            goalsCard
        case .name:
            nameCard
        }
    }

    private var welcomeCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -4) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    Text("Saturday, 24.05")
                        .font(.captionLarge())
                        .foregroundStyle(Color.themePrimary)
                    Spacer()
                    Text("18/365")
                        .font(.captionLarge())
                        .foregroundStyle(Color.textTertiary)
                }

                Text("How was your day?")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.themePrimary)

                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .fill(Color.surfaceVariant.opacity(0.9))
                    .frame(height: 180)
            }
        }
        .frame(maxWidth: 340)
    }

    private var goalsCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -3) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Choose your focus")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.sm) {
                    goalPill(title: "Launch", id: "launch")
                    goalPill(title: "Monetize", id: "monetize")
                    goalPill(title: "Growth", id: "measure")
                    goalPill(title: "Community", id: "community")
                }
            }
        }
        .frame(maxWidth: 340)
    }

    private var nameCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -2) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Your name")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)

                DSTextField.name(
                    placeholder: "Type your name",
                    text: $controller.userName
                )

                Text("We use this to personalize your demo.")
                    .font(.captionLarge())
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: 340)
    }

    private func goalPill(title: String, id: String) -> some View {
        Button {
            controller.toggleGoal(id)
        } label: {
            PickerPill(title: title, isHighlighted: controller.selectedGoals.contains(id))
        }
        .buttonStyle(.plain)
    }

    private var ctaBar: some View {
        VStack(spacing: DSSpacing.sm) {
            DSButton.cta(
                title: controller.currentStep.ctaTitle,
                isLoading: isSaving,
                isEnabled: controller.canContinue
            ) {
                onContinue()
            }

            if !controller.isLastStep {
                DSButton.link(title: "Skip", action: skipOnboarding)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.lg)
        .background(Color.backgroundPrimary)
    }

    private func onContinue() {
        trackEvent(.stepComplete(result: controller.stepResult()))

        withAnimation(.easeInOut(duration: 0.25)) {
            let completed = controller.goNext()
            if completed {
                completeOnboarding()
            }
        }
    }

    private func skipOnboarding() {
        trackEvent(.flowComplete(result: controller.flowResult))
        session.setOnboardingComplete()
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
