//
//  StoreKitPaywallView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import StoreKit
import DesignSystem

struct StoreKitPaywallView: View {
    var productIds: [String] = EntitlementOption.allProductIds
    var onInAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?

    var body: some View {
        SubscriptionStoreView(productIDs: productIds) {
            VStack(spacing: DSSpacing.sm) {
                Text("Premium Studio")
                    .font(.titleLarge())
                    .foregroundStyle(Color.textPrimary)

                Text("Unlock premium tools, templates, and analytics upgrades.")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)
            }
            .multilineTextAlignment(.center)
            .containerBackground(Color.backgroundSecondary.gradient, for: .subscriptionStore)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart(perform: onInAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

#Preview {
    StoreKitPaywallView(
        onInAppPurchaseStart: nil,
        onInAppPurchaseCompletion: nil
    )
}
