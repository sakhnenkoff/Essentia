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
        case .name: "Your Name"
        }
    }

    /// Headline text shown on the step (animated line-by-line)
    var headline: String {
        switch self {
        case .welcome:
            "Get started with\nyour next app idea"
        case .goals:
            "What do you want\nto build?"
        case .name:
            "What should we\ncall you?"
        }
    }

    /// Subtitle text shown below headline
    var subtitle: String? {
        switch self {
        case .welcome:
            "Built for speed.\nDesigned for growth."
        case .goals:
            "Choose a few to personalize\nyour experience."
        case .name:
            nil
        }
    }
}
