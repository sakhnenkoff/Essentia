//
//  CustomPaywallView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

struct CustomPaywallView: View {
    var products: [AnyProduct] = []
    var title: String = "Premium Studio"
    var subtitle: String = "Unlock premium flows, refined templates, and advanced analytics."
    var isProcessing: Bool = false
    var onRestorePurchasePressed: () -> Void = { }
    var onPurchaseProductPressed: (AnyProduct) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            heroCard

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Choose your plan")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                Text("Cancel anytime. Plans renew automatically unless cancelled in Settings.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: DSSpacing.sm) {
                let featuredId = products.first?.id
                ForEach(products) { product in
                    productCard(product: product, isFeatured: product.id == featuredId)
                }
            }

            DSButton.link(title: "Restore Purchase", action: onRestorePurchasePressed)
                .disabled(isProcessing)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text(subtitle)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: DSSpacing.sm) {
                featureChip(text: "Premium templates", icon: "sparkles")
                featureChip(text: "Analytics", icon: "chart.line.uptrend.xyaxis")
            }
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.lg)
        .glassBackground(cornerRadius: DSSpacing.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.lg)
                .stroke(Color.themePrimary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.08), radius: 16, x: 0, y: 10)
    }

    private func productCard(product: AnyProduct, isFeatured: Bool) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            if isFeatured {
                Text("Best value")
                    .font(.captionLarge())
                    .foregroundStyle(Color.success)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(Color.success.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(product.title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            Text(product.subtitle)
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)

            Text(product.priceStringWithDuration)
                .font(.headlineSmall())
                .foregroundStyle(Color.textPrimary)

            DSButton(title: "Select plan", isLoading: isProcessing, isFullWidth: true) {
                onPurchaseProductPressed(product)
            }
            .disabled(isProcessing)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundSecondary)
        .cornerRadius(DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(isFeatured ? Color.success.opacity(0.4) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.05), radius: 8, x: 0, y: 6)
    }

    private func featureChip(text: String, icon: String) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.captionLarge())
            Text(text)
                .font(.captionLarge())
        }
        .foregroundStyle(Color.textSecondary)
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(Color.backgroundSecondary)
        .clipShape(Capsule())
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
