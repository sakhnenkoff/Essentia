//
//  DetailView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct DetailView: View {
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var isLoading = false
    @State private var showError = false
    @State private var toast: Toast?
    let title: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header
                overviewCard

                if isLoading {
                    ProgressView("Loading detail...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if showError {
                    ErrorStateView(
                        title: "Detail failed to load",
                        message: "We couldn't refresh this content. Try again or return later.",
                        retryTitle: "Retry",
                        onRetry: { showError = false },
                        dismissTitle: "Dismiss",
                        onDismiss: { showError = false }
                    )
                }

                relatedSection
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
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("This routed screen shows how AppRouter pushes detail content.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Overview")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)
            Text("Use this view to show rich content, status, and the next best action.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)

            DSButton(title: "Show paywall", icon: "sparkles", isFullWidth: true) {
                router.presentSheet(.paywall)
            }
        }
        .padding(DSSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    private var relatedSection: some View {
        sectionCard(title: "Related items") {
            EmptyStateView(
                icon: "tray",
                title: "No related items",
                message: "Add related content to make this screen feel complete.",
                actionTitle: "Create sample",
                action: {
                    toast = .info("Sample content added.")
                }
            )
        }
    }

    private var actionSection: some View {
        sectionCard(title: "Demo states") {
            VStack(spacing: DSSpacing.sm) {
                DSButton(title: "Simulate loading", style: .secondary, isFullWidth: true) {
                    guard !isLoading else { return }
                    isLoading = true
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        isLoading = false
                    }
                }

                DSButton(title: "Simulate error", style: .secondary, isFullWidth: true) {
                    showError = true
                }

                DSButton(title: "Show success toast", style: .tertiary, isFullWidth: true) {
                    toast = .success("Detail updated successfully.")
                }
            }
        }
    }

    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            content()
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        DetailView(title: "Preview")
    }
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
