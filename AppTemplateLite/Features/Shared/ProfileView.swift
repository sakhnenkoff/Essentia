//
//  ProfileView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct ProfileView: View {
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    let userId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("User ID: \(userId)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let name = session.currentUser?.commonNameCalculated {
                LabeledContent("Name", value: name)
            }
            if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                LabeledContent("Email", value: email)
            }

            DSButton(title: "Open settings", style: .secondary) {
                router.presentSheet(.settings)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView(userId: "preview")
    }
    .environment(AppSession())
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
