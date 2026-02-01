//
//  PaywallView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

struct PaywallView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PaywallViewModel()

    let showCloseButton: Bool
    let allowSkip: Bool

    init(showCloseButton: Bool = false, allowSkip: Bool? = nil) {
        self.showCloseButton = showCloseButton
        self.allowSkip = allowSkip ?? !showCloseButton
    }

    var body: some View {
        NavigationStack {
            DSScreen(title: DemoContent.Paywall.navigationTitle) {
                VStack(spacing: DSSpacing.lg) {
                    heroCard

                    if FeatureFlags.enablePurchases {
                        paywallContent

                        if viewModel.isProcessingPurchase {
                            ProgressView(DemoContent.Paywall.processingTitle)
                                .font(.bodySmall())
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } else {
                        EmptyStateView(
                            icon: "lock.slash",
                            title: "Purchases disabled",
                            message: "Enable purchases in FeatureFlags to preview the paywall.",
                            actionTitle: "Close",
                            action: { dismiss() }
                        )
                    }

                    if allowSkip {
                        DSButton(title: "Not now", style: .secondary, isFullWidth: true) {
                            session.markPaywallDismissed()
                        }
                    }

                    Text(DemoContent.Common.cancelAnytime)
                        .font(.captionLarge())
                        .foregroundStyle(Color.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .toolbar {
                if showCloseButton {
                    ToolbarItem(placement: .topBarLeading) {
                        DSIconButton(icon: "xmark", style: .tertiary, size: .small, showsBackground: false, accessibilityLabel: "Close") {
                            dismiss()
                        }
                    }
                }
            }
            .toast($viewModel.toast)
            .task {
                await viewModel.loadProducts(services: services)
            }
            .onChange(of: viewModel.didUnlockPremium) { _, unlocked in
                if unlocked && showCloseButton {
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var paywallContent: some View {
        if let errorMessage = viewModel.errorMessage {
            ErrorStateView(
                title: "Unable to load offers",
                message: errorMessage,
                retryTitle: "Try again",
                onRetry: {
                    Task {
                        await viewModel.loadProducts(services: services)
                    }
                }
            )
        } else if viewModel.isLoadingProducts {
            paywallSkeleton
        } else if viewModel.products.isEmpty {
            EmptyStateView(
                icon: "cart",
                title: "No offers available",
                message: "We couldn't load subscription options right now.",
                actionTitle: "Refresh",
                action: {
                    Task {
                        await viewModel.loadProducts(services: services)
                    }
                }
            )
        } else {
            CustomPaywallView(
                products: viewModel.products,
                isProcessing: viewModel.isProcessingPurchase,
                onRestorePurchasePressed: {
                    Task {
                        await viewModel.restorePurchases(services: services, session: session)
                    }
                },
                onPurchaseProductPressed: { product in
                    Task {
                        await viewModel.purchase(
                            productId: product.id,
                            services: services,
                            session: session
                        )
                    }
                }
            )
        }
    }

    private var heroCard: some View {
        DSHeroCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(alignment: .top) {
                    HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                    Spacer()
                    TagBadge(text: "Premium")
                }

                Text(DemoContent.Paywall.heroTitle)
                    .font(.headlineMedium())
                    .foregroundStyle(Color.themePrimary)

                Text(DemoContent.Paywall.heroSubtitle)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private var paywallSkeleton: some View {
        VStack(spacing: DSSpacing.sm) {
            SkeletonView(style: .card)
            SkeletonView(style: .card)
            SkeletonView(style: .card)
        }
        .shimmer(true)
    }
}

#Preview {
    PaywallView(showCloseButton: true)
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
}
