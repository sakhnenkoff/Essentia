//
//  CustomPaywallView.swift
//  AppTemplateLite
//
//

import SwiftUI
import DesignSystem

struct CustomPaywallView: View {
    var products: [AnyProduct] = []
    var isProcessing: Bool = false
    var onRestorePurchasePressed: () -> Void = { }
    var onPurchaseProductPressed: (AnyProduct) -> Void = { _ in }

    @State private var selectedProductId: String?

    init(
        products: [AnyProduct] = [],
        isProcessing: Bool = false,
        onRestorePurchasePressed: @escaping () -> Void = { },
        onPurchaseProductPressed: @escaping (AnyProduct) -> Void = { _ in }
    ) {
        self.products = products
        self.isProcessing = isProcessing
        self.onRestorePurchasePressed = onRestorePurchasePressed
        self.onPurchaseProductPressed = onPurchaseProductPressed
        _selectedProductId = State(initialValue: products.first?.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            planSection

            DSButton.cta(
                title: "Unlock Premium",
                isLoading: isProcessing,
                isEnabled: selectedProduct != nil
            ) {
                guard let selectedProduct else { return }
                onPurchaseProductPressed(selectedProduct)
            }

            DSButton.link(title: "Restore purchase", action: onRestorePurchasePressed)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .onChange(of: products.count) { _, _ in
            if selectedProductId == nil {
                selectedProductId = products.first?.id
            }
        }
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Choose a plan")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: DSSpacing.sm) {
                ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                    planCard(product, isFeatured: index == 0)
                }
            }
            .disabled(isProcessing)
        }
    }

    private func planCard(_ product: AnyProduct, isFeatured: Bool) -> some View {
        let isSelected = product.id == selectedProductId

        return Button {
            selectedProductId = product.id
        } label: {
            VStack(alignment: .leading, spacing: DSSpacing.smd) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(product.title)
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)

                        Text(product.subtitle)
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }

                    Spacer()

                    if isFeatured {
                        TagBadge(text: "Best value")
                    }
                }

                PickerPill(
                    title: product.priceStringWithDuration,
                    isHighlighted: isSelected,
                    usesGlass: isSelected
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DSSpacing.md)
            .cardSurface(
                cornerRadius: DSRadii.lg,
                tint: Color.surfaceVariant.opacity(0.7),
                usesGlass: isSelected,
                isInteractive: true,
                borderColor: isSelected ? Color.themePrimary.opacity(0.4) : Color.border,
                shadowColor: isSelected ? DSShadows.lifted.color : DSShadows.card.color,
                shadowRadius: isSelected ? DSShadows.lifted.radius : DSShadows.card.radius,
                shadowYOffset: isSelected ? DSShadows.lifted.y : DSShadows.card.y
            )
        }
        .buttonStyle(.plain)
    }

    private var selectedProduct: AnyProduct? {
        products.first { $0.id == selectedProductId }
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
