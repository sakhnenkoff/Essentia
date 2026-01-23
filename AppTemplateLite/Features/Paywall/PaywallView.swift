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
    @State private var paywallMode: PaywallMode = .storeKit

    let showCloseButton: Bool
    let allowSkip: Bool

    init(showCloseButton: Bool = false, allowSkip: Bool? = nil) {
        self.showCloseButton = showCloseButton
        self.allowSkip = allowSkip ?? !showCloseButton
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                header
                includedSection

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
                DSIconButton(icon: "xmark", style: .tertiary, size: .small) {
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

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Upgrade to Premium")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("Unlock premium flows and advanced analytics.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var includedSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Included")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            listCard {
                DSListRow(
                    title: "Premium templates",
                    subtitle: "Additional layouts and onboarding polish.",
                    leadingIcon: "star.fill",
                    leadingTint: .warning
                )
                Divider()
                DSListRow(
                    title: "Advanced analytics",
                    subtitle: "Track onboarding and paywall performance.",
                    leadingIcon: "chart.line.uptrend.xyaxis",
                    leadingTint: .info
                )
                Divider()
                DSListRow(
                    title: "Priority support",
                    subtitle: "Guided updates and launch help.",
                    leadingIcon: "shield.fill",
                    leadingTint: .success
                )
            }
        }
    }

    private func listCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .cardSurface(cornerRadius: DSSpacing.md)
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
