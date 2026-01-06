//
//  NavigationSheet.swift
//  AppTemplateLite
//
//
//

import SwiftUI

struct NavigationSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
