//
//  OnboardingStep.swift
//  AppTemplateLite
//
//

import Foundation

/// Defines the steps in the onboarding flow.
/// Add, remove, or reorder cases to customize the flow.
enum OnboardingStep: Int, CaseIterable {
    case welcome
    case goals
    case name

    /// Analytics identifier for this step
    var analyticsId: String {
        switch self {
        case .welcome: "welcome"
        case .goals: "goals"
        case .name: "name"
        }
    }

    /// Title shown for progress indicators
    var title: String {
        switch self {
        case .welcome: "Welcome"
        case .goals: "Goals"
        case .name: "Profile"
        }
    }

    /// Headline text shown on the step (animated line-by-line)
    var headline: String {
        switch self {
        case .welcome:
            "Build something delightful"
        case .goals:
            "What are you shipping first?"
        case .name:
            "What should we call you?"
        }
    }

    /// Subtitle text shown below headline
    var subtitle: String? {
        switch self {
        case .welcome:
            "Templates, design system, and real integrations included."
        case .goals:
            "Pick a focus to tailor the demo flow."
        case .name:
            "Add a name to personalize the experience."
        }
    }
}
