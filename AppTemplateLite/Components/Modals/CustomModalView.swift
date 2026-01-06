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
                Text(primaryButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.smd)
                    .background(Color.themeAccent)
                    .foregroundStyle(Color.textOnPrimary)
                    .cornerRadius(DSSpacing.md)
                    .anyButton(.press) {
                        primaryButtonAction()
                    }

                Text(secondaryButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.smd)
                    .tappableBackground()
                    .anyButton(.plain) {
                        secondaryButtonAction()
                    }
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
