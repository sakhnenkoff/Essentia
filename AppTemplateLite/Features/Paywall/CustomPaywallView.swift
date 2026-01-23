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
            header

            listCard {
                let featuredId = products.first?.id
                ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                    let isFeatured = product.id == featuredId
                    DSListRow(
                        title: product.title,
                        subtitle: productSubtitle(product, isFeatured: isFeatured),
                        leadingIcon: "sparkles",
                        leadingTint: isFeatured ? .success : .textPrimary,
                        trailingText: product.priceStringWithDuration,
                        showsDisclosure: true
                    ) {
                        onPurchaseProductPressed(product)
                    }

                    if index < products.count - 1 {
                        Divider()
                    }
                }
            }
            .disabled(isProcessing)

            DSButton.link(title: "Restore Purchase", action: onRestorePurchasePressed)
                .disabled(isProcessing)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text(subtitle)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func productSubtitle(_ product: AnyProduct, isFeatured: Bool) -> String {
        if isFeatured {
            return "Best value · \(product.subtitle)"
        }
        return product.subtitle
    }

    private func listCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .cardSurface(
            cornerRadius: DSSpacing.md,
            tint: Color.textPrimary.opacity(0.04),
            usesGlass: true
        )
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
