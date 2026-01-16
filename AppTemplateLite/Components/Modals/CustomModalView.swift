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
                    .font(.title3)
                    .fontWeight(.semibold)

                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(DSSpacing.smd)

            VStack(spacing: DSSpacing.sm) {
                DSButton(title: primaryButtonTitle, action: primaryButtonAction)

                Button(action: secondaryButtonAction) {
                    Text(secondaryButtonTitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.smd)
                }
                .buttonStyle(.plain)
            }
        }
        .multilineTextAlignment(.center)
        .padding(DSSpacing.md)
        .background(Color.backgroundPrimary)
        .cornerRadius(DSSpacing.md)
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
