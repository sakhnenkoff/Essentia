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
    var title: String = "Try Premium Today!"
    var subtitle: String = "Unlock unlimited access and exclusive features for premium members."
    var onBackButtonPressed: () -> Void = { }
    var onRestorePurchasePressed: () -> Void = { }
    var onPurchaseProductPressed: (AnyProduct) -> Void = { _ in }

    var body: some View {
        ZStack {
            Color.themeAccent.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: DSSpacing.lg) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.subheadline)
                }
                .foregroundStyle(Color.textOnPrimary)
                .padding(DSSpacing.xxlg)

                VStack(spacing: DSSpacing.sm) {
                    ForEach(products) { product in
                        productRow(product: product)
                    }

                    Button {
                        onRestorePurchasePressed()
                    } label: {
                        Text("Already have a subscription?\nRestore Purchase")
                            .font(.callout)
                            .fontWeight(.medium)
                            .underline()
                            .foregroundStyle(Color.textOnPrimary)
                    }
                    .buttonStyle(.plain)
                    .padding(DSSpacing.md)
                }

                Spacer(minLength: 0)
                Spacer(minLength: 0)
            }
        }
        .multilineTextAlignment(.center)
        .overlay(
            Button {
                onBackButtonPressed()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.textOnPrimary)
                    .font(.title)
                    .padding(DSSpacing.sm)
            }
            .buttonStyle(.plain)
            .padding(DSSpacing.md),
            alignment: .topLeading
        )
    }

    private func productRow(product: AnyProduct) -> some View {
        Button {
            onPurchaseProductPressed(product)
        } label: {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(product.title)
                            .font(.headline)
                        Text(product.priceStringWithDuration)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()
                Text(product.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.md)
            .background(Color.backgroundPrimary)
            .cornerRadius(DSSpacing.md)
            .shadow(color: Color.black.opacity(0.3), radius: DSSpacing.sm, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(DSSpacing.md)
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
