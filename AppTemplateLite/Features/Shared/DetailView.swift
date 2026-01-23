//
//  DetailView.swift
//  AppTemplateLite
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct DetailView: View {
    @State private var toast: Toast?
    let title: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header
                heroCard
                actionSection
            }
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
        .navigationTitle("Detail")
        .toast($toast)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("A focused detail surface with a single hero card.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var heroCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -3) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(alignment: .top) {
                    HeroIcon(systemName: "doc.text", size: 22)
                    Spacer()
                    TagBadge(text: "Featured")
                }

                Text("Focus notes")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.themePrimary)

                Text("Capture one idea per day and track progress over time.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)

                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .fill(Color.surfaceVariant.opacity(0.9))
                    .frame(height: 160)
            }
        }
        .frame(maxWidth: 360)
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Actions")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: DSSpacing.sm) {
                DSButton.cta(title: "Mark complete") {
                    toast = .success("Marked complete.")
                }

                DSButton(title: "Share card", style: .secondary, isFullWidth: true) {
                    toast = .info("Share flow coming soon.")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(title: "Preview")
    }
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
