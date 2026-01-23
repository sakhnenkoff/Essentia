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
    @State private var paywallMode: PaywallMode = .custom

    let showCloseButton: Bool
    let allowSkip: Bool

    init(showCloseButton: Bool = false, allowSkip: Bool? = nil) {
        self.showCloseButton = showCloseButton
        self.allowSkip = allowSkip ?? !showCloseButton
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                heroCard

                if FeatureFlags.enablePurchases {
                    paywallContent

                    #if DEBUG
                    Picker("Paywall style", selection: $paywallMode) {
                        Text("StoreKit").tag(PaywallMode.storeKit)
                        Text("Custom").tag(PaywallMode.custom)
                    }
                    .pickerStyle(.segmented)
                    #endif

                    if viewModel.isProcessingPurchase {
                        ProgressView("Updating your access...")
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

                Text("Cancel anytime in Settings.")
                    .font(.captionLarge())
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topTrailing) {
            if showCloseButton {
                DSIconButton(icon: "xmark", style: .secondary, size: .small) {
                    dismiss()
                }
                .padding(DSSpacing.md)
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
        } else {
            switch paywallMode {
            case .storeKit:
                StoreKitPaywallView(
                    productIds: viewModel.productIds,
                    onInAppPurchaseStart: { product in
                        viewModel.onStoreKitPurchaseStart(product: product, services: services)
                    },
                    onInAppPurchaseCompletion: { product, result in
                        viewModel.onStoreKitPurchaseComplete(
                            product: product,
                            result: result,
                            services: services,
                            session: session
                        )
                    }
                )
            case .custom:
                if viewModel.isLoadingProducts {
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
        }
    }

    enum PaywallMode: String {
        case storeKit
        case custom
    }

    private var heroCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -2) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(alignment: .top) {
                    HeroIcon(systemName: "sparkles", size: 22)
                    Spacer()
                    TagBadge(text: "Premium")
                }

                Text("Premium Studio")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.themePrimary)

                Text("A refined template pack with analytics, paywalls, and onboarding flows.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: 360)
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
