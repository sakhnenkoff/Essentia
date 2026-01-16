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
        VStack(spacing: DSSpacing.md) {
            if showCloseButton {
                HStack {
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }

            if FeatureFlags.enablePurchases {
                paywallContent

                #if DEBUG
                Picker("Paywall style", selection: $paywallMode) {
                    Text("StoreKit").tag(PaywallMode.storeKit)
                    Text("Custom").tag(PaywallMode.custom)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.md)
                #endif
            } else {
                Text("Purchases are disabled in FeatureFlags.")
                    .foregroundStyle(.secondary)
                    .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if viewModel.isLoading {
                ProgressView("Processing...")
            }

            if allowSkip {
                DSButton(title: "Not now", style: .secondary) {
                    session.markPaywallDismissed()
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
        .padding(.vertical, DSSpacing.md)
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
            if viewModel.products.isEmpty {
                ProgressView("Loading offers...")
            } else {
                CustomPaywallView(
                    products: viewModel.products,
                    onBackButtonPressed: {
                        if showCloseButton {
                            dismiss()
                        }
                    },
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

    enum PaywallMode: String {
        case storeKit
        case custom
    }
}

#Preview {
    PaywallView(showCloseButton: true)
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
}
