//
//  CustomModalView.swift
//  
//
//  
//

import SwiftUI
import DesignSystem

struct CustomModalView: View {

    var title: String = "Title"
    var subtitle: String? = "This is a subtitle."
    var primaryButtonTitle: String = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonTitle: String = "No"
    var secondaryButtonAction: () -> Void = { }
    
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            VStack(spacing: DSSpacing.smd) {
                Text(title)
                    .font(.titleSmall())
                    .foregroundStyle(Color.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(DSSpacing.smd)

            VStack(spacing: DSSpacing.sm) {
                DSButton(title: primaryButtonTitle, isFullWidth: true, action: primaryButtonAction)
                DSButton(title: secondaryButtonTitle, style: .tertiary, isFullWidth: true, action: secondaryButtonAction)
            }
        }
        .multilineTextAlignment(.center)
        .padding(DSSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.backgroundSecondary, Color.backgroundTertiary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSSpacing.md)
        .glassBackground(cornerRadius: DSSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.md)
                .stroke(Color.themePrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.themePrimary.opacity(0.08), radius: 16, x: 0, y: 10)
        .padding(DSSpacing.xxlg)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                
            }
        )
    }
}
