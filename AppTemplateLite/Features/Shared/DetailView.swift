//
//  DetailView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter

struct DetailView: View {
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("This is a lightweight destination powered by AppRouter.")
                .foregroundStyle(.secondary)

            Text("Show paywall")
                .callToActionButton()
                .anyButton(.press) {
                    router.presentSheet(.paywall)
                }

            Spacer()
        }
        .padding()
        .navigationTitle("Detail")
    }
}

#Preview {
    NavigationStack {
        DetailView(title: "Preview")
    }
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
