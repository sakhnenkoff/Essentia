//
//  OnboardingHeader.swift
//  AppTemplateLite
//
//

import SwiftUI
import DesignSystem

/// A reusable header for onboarding flows with progress bar and back button.
struct OnboardingHeader: View {
    let progress: Double
    let showBackButton: Bool
    let onBack: () -> Void

    init(
        progress: Double,
        showBackButton: Bool = true,
        onBack: @escaping () -> Void
    ) {
        self.progress = progress
        self.showBackButton = showBackButton
        self.onBack = onBack
    }

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            if showBackButton {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            } else {
                Spacer()
                    .frame(width: 44)
            }

            ProgressView(value: progress)
                .tint(Color.themePrimary)
                .animation(.easeInOut(duration: 0.3), value: progress)

            Spacer()
                .frame(width: 44)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
    }
}

#Preview("Progress States") {
    VStack(spacing: DSSpacing.lg) {
        OnboardingHeader(progress: 0.33, showBackButton: false) {}
        OnboardingHeader(progress: 0.66, showBackButton: true) {}
        OnboardingHeader(progress: 1.0, showBackButton: true) {}
    }
    .background(Color.backgroundPrimary)
}

#Preview("Dark Mode") {
    VStack(spacing: DSSpacing.lg) {
        OnboardingHeader(progress: 0.5, showBackButton: true) {}
    }
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
