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
                overviewSection

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
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Routed detail content.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var overviewSection: some View {
        sectionCard(title: "Overview") {
            listCard {
                DSListRow(
                    title: "Status",
                    subtitle: "Active",
                    leadingIcon: "checkmark.seal",
                    leadingTint: .success,
                    trailingText: "Today"
                )
                Divider()
                DSListRow(
                    title: "Owner",
                    subtitle: "Demo workspace",
                    leadingIcon: "person.fill",
                    leadingTint: .textPrimary,
                    trailingText: sessionName
                )
                Divider()
                DSListRow(
                    title: "View paywall",
                    subtitle: "Preview upgrade flow.",
                    leadingIcon: "sparkles",
                    leadingTint: .warning,
                    showsDisclosure: true
                ) {
                    router.presentSheet(.paywall)
                }
            }
        }
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
            listCard {
                DSListRow(
                    title: "Simulate loading",
                    subtitle: "Show a loading state.",
                    leadingIcon: "hourglass",
                    leadingTint: .textSecondary,
                    showsDisclosure: true
                ) {
                    guard !isLoading else { return }
                    isLoading = true
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        isLoading = false
                    }
                }
                Divider()
                DSListRow(
                    title: "Simulate error",
                    subtitle: "Show an error state.",
                    leadingIcon: "exclamationmark.triangle.fill",
                    leadingTint: .warning,
                    showsDisclosure: true
                ) {
                    showError = true
                }
                Divider()
                DSListRow(
                    title: "Show success toast",
                    subtitle: "Display a confirmation.",
                    leadingIcon: "checkmark.circle.fill",
                    leadingTint: .success,
                    showsDisclosure: true
                ) {
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
    }

    private func listCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .cardSurface(cornerRadius: DSSpacing.md)
    }

    private var sessionName: String {
        "Workspace"
    }
}

#Preview {
    NavigationStack {
        DetailView(title: "Preview")
    }
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
