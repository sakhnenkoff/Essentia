//
//  OnboardingView.swift
//  Essentia
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

            ZStack {
                // Text-intro screens with line-by-line blur
                if controller.currentStep.isTextIntro {
                    textIntroContent
                        .id(controller.currentStep)
                        .transition(lineByLineTransition)
                } else {
                    // Data-gathering screens with staggered fade-in
                    dataGatheringContent
                        .id(controller.currentStep)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.smooth(duration: 0.5), value: controller.currentStep)
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

    private var lineByLineTransition: AnyTransition {
        if #available(iOS 18.0, *) {
            return .asymmetric(
                insertion: AnyTransition(LineByLineInBlurOutTransition()),
                removal: .opacity.combined(with: .scale(scale: 0.95))
            )
        } else {
            return .opacity.combined(with: .scale(scale: 0.98))
        }
    }

    // MARK: - Text Intro Content

    private var textIntroContent: some View {
        VStack(spacing: DSSpacing.xxl) {
            Spacer()

            Text(controller.currentStep.introHeadline)
                .font(.titleLarge())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(DSSpacing.sm)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, DSSpacing.xxl)
    }

    // MARK: - Data Gathering Content

    private var dataGatheringContent: some View {
        ScrollView {
            VStack(alignment: .center, spacing: DSSpacing.xl) {
                heroIcon
                    .staggeredAppearance(index: 0)

                headlineView
                    .staggeredAppearance(index: 1)

                subtitleView
                    .staggeredAppearance(index: 2)

                cardContent
                    .staggeredAppearance(index: 3, baseDelay: 0.15, staggerDelay: 0.1)

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
                    .staggeredAppearance(index: 4)
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

    private var heroIcon: some View {
        HeroIcon(systemName: controller.currentStep.icon, size: DSLayout.iconLarge)
    }

    private var headlineView: some View {
        Text(headlineAttributedString)
            .multilineTextAlignment(.center)
            .lineSpacing(DSSpacing.xs)
    }

    private var headlineAttributedString: AttributedString {
        var leading = AttributedString(controller.currentStep.headlineLeading)
        leading.font = .titleLarge()
        leading.foregroundColor = Color.textPrimary

        var highlight = AttributedString(controller.currentStep.headlineHighlight)
        highlight.font = .titleLarge()
        highlight.foregroundColor = Color.themePrimary

        var trailing = AttributedString(controller.currentStep.headlineTrailing)
        trailing.font = .titleLarge()
        trailing.foregroundColor = Color.textPrimary

        leading.append(highlight)
        leading.append(trailing)
        return leading
    }

    private var subtitleView: some View {
        Text(controller.currentStep.subtitle)
            .font(.bodyMedium())
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: DSLayout.textMaxWidth)
    }

    @ViewBuilder
    private var cardContent: some View {
        switch controller.currentStep {
        case .intro1, .intro2, .intro3:
            // Text-only screens have no card content
            EmptyView()
        case .goals:
            goalsCard
        case .name:
            nameCard
        }
    }

    private var goalsCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false) {
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
        .frame(maxWidth: DSLayout.cardCompactWidth)
    }

    private var nameCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false) {
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
        .frame(maxWidth: DSLayout.cardCompactWidth)
    }

    private func goalPill(title: String, id: String) -> some View {
        Button {
            controller.toggleGoal(id)
        } label: {
            PickerPill(title: title, isHighlighted: controller.selectedGoals.contains(id), isInteractive: true)
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
