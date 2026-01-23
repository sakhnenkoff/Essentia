//
//  NavigationSheet.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import DesignSystem

struct NavigationSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        DSIconButton(icon: "xmark", style: .secondary, size: .small) {
                            dismiss()
                        }
                    }
                }
        }
    }
}
