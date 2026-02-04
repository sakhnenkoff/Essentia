//
//  OnboardingController.swift
//  Essentia
//
//

import Foundation

/// Manages onboarding flow state, collected data, and validation.
/// Extend this controller to add more data fields as needed.
@MainActor
@Observable
final class OnboardingController {
    // MARK: - Flow State

    private(set) var currentStep: OnboardingStep = .intro1
    private(set) var stepStartTime: Date = .now

    // MARK: - Collected Data

    var selectedGoals: Set<String> = []
    var userName: String = ""

    // MARK: - Computed Properties

    var canGoBack: Bool {
        currentStep.rawValue > 0
    }

    var canContinue: Bool {
        switch currentStep {
        case .intro1, .intro2, .intro3:
            true
        case .goals:
            !selectedGoals.isEmpty
        case .name:
            userName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        }
    }

    var isLastStep: Bool {
        currentStep.rawValue == OnboardingStep.allCases.count - 1
    }

    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count)
    }

    var stepDuration: TimeInterval {
        Date.now.timeIntervalSince(stepStartTime)
    }

    // MARK: - Actions

    func goBack() {
        guard canGoBack else { return }
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
            stepStartTime = .now
        }
    }

    /// Advances to next step. Returns true if flow is complete.
    func goNext() -> Bool {
        guard canContinue else { return false }

        if isLastStep {
            return true
        }

        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
            stepStartTime = .now
        }
        return false
    }

    func toggleGoal(_ id: String) {
        if selectedGoals.contains(id) {
            selectedGoals.remove(id)
        } else {
            selectedGoals.insert(id)
        }
    }

    // MARK: - Analytics Data

    var flowResult: [String: Any] {
        var result: [String: Any] = [
            "goals": Array(selectedGoals).joined(separator: ","),
            "steps_completed": currentStep.rawValue + 1
        ]
        if !userName.isEmpty {
            result["user_name"] = userName
        }
        return result
    }

    func stepResult() -> [String: Any] {
        var result: [String: Any] = [
            "step_id": currentStep.analyticsId,
            "step_index": currentStep.rawValue,
            "duration": stepDuration
        ]

        switch currentStep {
        case .goals:
            result["selections"] = Array(selectedGoals)
        case .name:
            result["has_name"] = !userName.isEmpty
        default:
            break
        }

        return result
    }
}
