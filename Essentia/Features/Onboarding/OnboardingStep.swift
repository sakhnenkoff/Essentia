//
//  OnboardingStep.swift
//  Essentia
//
//

import Foundation

/// Defines the steps in the onboarding flow.
/// Add, remove, or reorder cases to customize the flow.
enum OnboardingStep: Int, CaseIterable {
    case intro1
    case intro2
    case intro3
    case goals
    case name

    /// Whether this step is a text-only intro screen (no cards, centered text)
    var isTextIntro: Bool {
        switch self {
        case .intro1, .intro2, .intro3:
            return true
        case .goals, .name:
            return false
        }
    }

    /// Analytics identifier for this step
    var analyticsId: String {
        switch self {
        case .intro1: "intro_1"
        case .intro2: "intro_2"
        case .intro3: "intro_3"
        case .goals: "goals"
        case .name: "name"
        }
    }

    /// Title shown for progress indicators
    var title: String {
        switch self {
        case .intro1: "Welcome"
        case .intro2: "Journey"
        case .intro3: "Habits"
        case .goals: "Goals"
        case .name: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .intro1:
            return "leaf"
        case .intro2:
            return "arrow.right"
        case .intro3:
            return "checkmark.circle"
        case .goals:
            return "target"
        case .name:
            return "person.crop.circle"
        }
    }

    /// For text-intro screens: The main headline (multi-line, centered)
    var introHeadline: String {
        switch self {
        case .intro1:
            return "A quiet space\nfor your thoughts"
        case .intro2:
            return "Track your journey,\none day at a time"
        case .intro3:
            return "Build habits that\nactually stick"
        case .goals, .name:
            return ""
        }
    }

    /// For data-gathering screens: Leading text before highlight
    var headlineLeading: String {
        switch self {
        case .intro1, .intro2, .intro3:
            return ""
        case .goals:
            return "what are you "
        case .name:
            return "tell us your "
        }
    }

    /// For data-gathering screens: Highlighted text
    var headlineHighlight: String {
        switch self {
        case .intro1, .intro2, .intro3:
            return ""
        case .goals:
            return "shipping"
        case .name:
            return "name"
        }
    }

    /// For data-gathering screens: Trailing text after highlight
    var headlineTrailing: String {
        switch self {
        case .intro1, .intro2, .intro3:
            return ""
        case .goals:
            return " first?"
        case .name:
            return "."
        }
    }

    var subtitle: String {
        switch self {
        case .intro1:
            return ""
        case .intro2:
            return ""
        case .intro3:
            return ""
        case .goals:
            return "Pick a focus to tailor the demo flow."
        case .name:
            return "Short, sweet, and personal."
        }
    }

    var ctaTitle: String {
        switch self {
        case .intro1:
            return "Continue"
        case .intro2:
            return "Continue"
        case .intro3:
            return "Let's go"
        case .goals:
            return "Continue"
        case .name:
            return "Get started"
        }
    }
}
