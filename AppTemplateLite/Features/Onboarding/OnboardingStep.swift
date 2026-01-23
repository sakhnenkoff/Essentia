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

    var icon: String {
        switch self {
        case .welcome:
            return "doc.text"
        case .goals:
            return "target"
        case .name:
            return "person.crop.circle"
        }
    }

    var headlineLeading: String {
        switch self {
        case .welcome:
            return "plant a "
        case .goals:
            return "what are you "
        case .name:
            return "tell us your "
        }
    }

    var headlineHighlight: String {
        switch self {
        case .welcome:
            return "memory"
        case .goals:
            return "shipping"
        case .name:
            return "name"
        }
    }

    var headlineTrailing: String {
        switch self {
        case .welcome:
            return " everyday?"
        case .goals:
            return " first?"
        case .name:
            return "."
        }
    }

    var subtitle: String {
        switch self {
        case .welcome:
            return "We can remind you with a calm daily nudge."
        case .goals:
            return "Pick a focus to tailor the demo flow."
        case .name:
            return "Short, sweet, and personal."
        }
    }

    var ctaTitle: String {
        switch self {
        case .welcome:
            return "Send me reminders"
        case .goals:
            return "Continue"
        case .name:
            return "Get started"
        }
    }
}
