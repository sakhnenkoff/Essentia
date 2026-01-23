//
//  ProfileView.swift
//  AppTemplateLite
//
//

import SwiftUI
import AppRouter
import DesignSystem

struct ProfileView: View {
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
    @State private var toast: Toast?
    let userId: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header
                profileCard
                actionsSection
            }
            .padding(DSSpacing.md)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AmbientBackground())
        .navigationTitle("Profile")
        .toast($toast)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Profile studio")
                .font(.titleLarge())
                .foregroundStyle(Color.textPrimary)
            Text("A calm card with minimal stats and actions.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var profileCard: some View {
        GlassCard(tint: Color.surfaceVariant.opacity(0.7), usesGlass: false, tilt: -2) {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack(alignment: .center, spacing: DSSpacing.md) {
                    profileAvatar

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(session.currentUser?.commonNameCalculated ?? "Guest")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)
                        Text(session.isPremium ? "Premium member" : "Free plan")
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)

                        if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                            Text(email)
                                .font(.bodySmall())
                                .foregroundStyle(Color.textSecondary)
                        }

                        if !userId.isEmpty {
                            Text("ID \(userId)")
                                .font(.captionLarge())
                                .foregroundStyle(Color.textTertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                HStack(spacing: DSSpacing.lg) {
                    statItem(value: "12", title: "Streak")
                    statItem(value: "4", title: "Projects")
                    statItem(value: "36", title: "Days")
                }
            }
        }
        .frame(maxWidth: 360)
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Actions")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: DSSpacing.sm) {
                DSButton.cta(title: "Edit profile") {
                    toast = .success("Profile editor coming soon.")
                }

                DSButton(
                    title: session.isPremium ? "Manage subscription" : "View paywall",
                    style: .secondary,
                    isFullWidth: true
                ) {
                    router.presentSheet(.paywall)
                }

                DSButton(
                    title: "Open settings",
                    style: .secondary,
                    isFullWidth: true
                ) {
                    router.presentSheet(.settings)
                }
            }
        }
    }

    private var profileAvatar: some View {
        Group {
            if let urlString = session.currentUser?.profileImageNameCalculated,
               !urlString.isEmpty {
                ImageLoaderView(urlString: urlString)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.backgroundTertiary)
                    SketchIcon(systemName: "person.fill", size: 22, color: Color.textSecondary)
                }
            }
        }
        .frame(width: 68, height: 68)
        .clipShape(Circle())
    }

    private func statItem(value: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(value)
                .font(.headlineMedium())
                .foregroundStyle(Color.themePrimary)
            Text(title)
                .font(.captionLarge())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        ProfileView(userId: "preview")
    }
    .environment(AppSession())
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
