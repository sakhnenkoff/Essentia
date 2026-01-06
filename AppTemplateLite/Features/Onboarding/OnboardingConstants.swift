//
//  OnboardingConstants.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import SwiftfulOnboarding
import DesignSystem

@MainActor
struct OnboardingConstants {
    static let headerConfiguration = OnbHeaderConfiguration(
        headerStyle: .progressBar,
        headerAlignment: .center,
        showBackButton: .afterFirstSlide,
        backButtonColor: Color.themeAccent,
        progressBarAccentColor: Color.themeAccent
    )

    static let slideDefaults = OnbSlideDefaults(
        ctaButtonStyle: .solid(
            backgroundColor: Color.themeAccent,
            textColor: Color.textOnPrimary,
            selectedBackgroundColor: Color.themeAccent,
            selectedTextColor: Color.textOnPrimary
        ),
        optionsButtonStyle: .solid(
            backgroundColor: Color.backgroundSecondary,
            textColor: .primary,
            selectedBackgroundColor: Color.themeAccent,
            selectedTextColor: Color.textOnPrimary
        )
    )

    static let slides: [OnbSlideType] = [
        .regular(
            id: "welcome",
            title: "Welcome!",
            subtitle: "Get started with your next app idea.",
            media: .systemIcon(named: "sparkles"),
            mediaPosition: .top,
            contentAlignment: .center
        ),
        .multipleChoice(
            id: "goals",
            title: "What do you want to build?",
            subtitle: "Choose a few to personalize your experience.",
            options: [
                OnbChoiceOption(
                    id: "launch",
                    content: OnbButtonContentData(
                        text: "Launch fast",
                        secondaryContent: .media(media: .systemIcon(named: "paperplane.fill", size: .small))
                    )
                ),
                OnbChoiceOption(
                    id: "monetize",
                    content: OnbButtonContentData(
                        text: "Monetize",
                        secondaryContent: .media(media: .systemIcon(named: "creditcard.fill", size: .small))
                    )
                ),
                OnbChoiceOption(
                    id: "measure",
                    content: OnbButtonContentData(
                        text: "Measure growth",
                        secondaryContent: .media(media: .systemIcon(named: "chart.line.uptrend.xyaxis", size: .small))
                    )
                )
            ],
            selectionBehavior: .multi(max: 3),
            contentAlignment: .top
        )
    ]
}
