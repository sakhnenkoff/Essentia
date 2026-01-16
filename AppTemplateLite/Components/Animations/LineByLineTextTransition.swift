//
//  LineByLineTextTransition.swift
//  AppTemplateLite
//
//  Line-by-line text appearance animation using iOS 18+ TextRenderer.
//

import SwiftUI
import DesignSystem

// MARK: - Text Renderer

/// Renders text with per-line staggered animation effects.
struct LineByLineTextRenderer: TextRenderer, Animatable {
    var progress: Double
    let duration: TimeInterval
    let singleLineDurationRatio: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let lineDelayRatio = (1.0 - singleLineDurationRatio) / Double(layout.count)
        let lineDuration = duration * singleLineDurationRatio

        for (lineIndex, line) in layout.enumerated() {
            var lineContext = context

            let lineMinProgress = lineDelayRatio * Double(lineIndex)
            let lineProgress = max(min((progress - lineMinProgress) / singleLineDurationRatio, 1.0), 0.0)

            let spring = Spring.snappy(duration: lineDuration, extraBounce: 0.2)

            let yTranslation = spring.value(
                fromValue: line.typographicBounds.rect.height,
                toValue: 0,
                initialVelocity: 0,
                time: lineDuration * lineProgress
            )

            let opacity = UnitCurve.easeInOut.value(at: lineProgress)
            let blurRadius = 2 * (1.0 - UnitCurve.easeInOut.value(at: lineProgress))

            lineContext.translateBy(x: 0, y: yTranslation)
            lineContext.opacity = opacity
            lineContext.addFilter(.blur(radius: blurRadius))

            lineContext.draw(line, options: .disablesSubpixelQuantization)
        }
    }
}

// MARK: - Transition

/// A transition that animates text line-by-line with blur and fade effects.
struct LineByLineTransition: Transition {
    var duration: TimeInterval = 0.6

    func body(content: Content, phase: TransitionPhase) -> some View {
        let renderer = LineByLineTextRenderer(
            progress: phase == .willAppear ? 0.0 : 1.0,
            duration: duration,
            singleLineDurationRatio: 0.9
        )

        let animation: Animation = phase == .identity
            ? .linear(duration: duration)
            : .easeOut(duration: duration * 0.6)

        content
            .textRenderer(renderer)
            .scaleEffect(phase == .didDisappear ? 0.9 : 1.0)
            .opacity(phase == .didDisappear ? 0.0 : 1.0)
            .blur(radius: phase == .didDisappear ? 2.0 : 0.0)
            .offset(x: 0, y: phase == .didDisappear ? -10.0 : 0.0)
            .animation(animation, value: phase)
    }
}

// MARK: - View Extension

extension View {
    /// Applies line-by-line text animation transition.
    func lineByLineTransition(duration: TimeInterval = 0.6) -> some View {
        self.transition(LineByLineTransition(duration: duration))
    }
}

// MARK: - Preview

#Preview {
    LineByLinePreview()
}

private struct LineByLinePreview: View {
    @State private var currentIndex: Int?

    private let steps = [
        "First step of the\nonboarding flow",
        "Second step with\ndifferent content",
        "And finally the last\nstep with a very\nvery long text\nto test the transition\nwith many lines!"
    ]

    var body: some View {
        ZStack {
            if let currentIndex {
                Text(steps[currentIndex])
                    .id(currentIndex)
                    .transition(LineByLineTransition())
            }
        }
        .font(.titleLarge())
        .padding(.horizontal, 42)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DSButton(title: "Next", style: .secondary) {
                    withAnimation(.smooth(duration: 0.5)) {
                        currentIndex = currentIndex.map { ($0 + 1) % steps.count }
                    }
                }
            }
        }
        .onAppear {
            currentIndex = 0
        }
    }
}
