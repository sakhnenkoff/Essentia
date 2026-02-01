//
//  DetailView.swift
//  AppTemplateLite
//
//

import SwiftUI
import DesignSystem
import AppRouter

struct DetailView: View {
    @State private var toast: Toast?
    let title: String

    var body: some View {
        DSScreen(title: DemoContent.Detail.navigationTitle) {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header
                heroCard
                actionSection
            }
        }
        .toast($toast)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text(DemoContent.Detail.headerSubtitle)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var heroCard: some View {
        DSHeroCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -1) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(alignment: .top) {
                    HeroIcon(systemName: "doc.text", size: DSLayout.iconMedium)
                    Spacer()
                    TagBadge(text: "Featured")
                }

                Text(DemoContent.Detail.heroTitle)
                    .font(.headlineMedium())
                    .foregroundStyle(Color.themePrimary)

                Text(DemoContent.Detail.heroSubtitle)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)

                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .fill(Color.surfaceVariant.opacity(0.9))
                    .frame(height: DSLayout.mediaHeight)
            }
        }
    }

    private var actionSection: some View {
        DSSection(title: DemoContent.Sections.actions) {
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
