//
//  ProfileView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import UIKit
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
                accountSection
                activitySection
                actionSection
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
        HStack(alignment: .top, spacing: DSSpacing.md) {
            profileAvatar

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(session.currentUser?.commonNameCalculated ?? "Guest")
                    .font(.titleSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(session.isPremium ? "Premium member" : "Free plan")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)

                if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                    Text(email)
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    Image(systemName: "person.fill")
                        .font(.headlineLarge())
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
    }

    private var accountSection: some View {
        section(title: "Account") {
            listCard {
                if let name = session.currentUser?.commonNameCalculated {
                    DSListRow(
                        title: "Name",
                        subtitle: name,
                        leadingIcon: "person.fill",
                        leadingTint: .textPrimary
                    )
                    Divider()
                }

                if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                    DSListRow(
                        title: "Email",
                        subtitle: email,
                        leadingIcon: "envelope",
                        leadingTint: .info,
                        trailingIcon: "doc.on.doc"
                    ) {
                        copyToPasteboard(email)
                    }
                    Divider()
                }

                DSListRow(
                    title: "User ID",
                    subtitle: userId,
                    leadingIcon: "person.crop.circle",
                    leadingTint: .textSecondary,
                    trailingIcon: "doc.on.doc"
                ) {
                    copyToPasteboard(userId)
                }
            }
        }
    }

    private var activitySection: some View {
        let activityItems = sampleActivityItems

        return section(title: "Recent activity") {
            if activityItems.isEmpty {
                EmptyStateView(
                    icon: "sparkles",
                    title: "No activity yet",
                    message: "Complete onboarding and explore features to see updates here.",
                    actionTitle: "View onboarding",
                    action: { router.navigateTo(.detail(title: "Onboarding progress"), for: router.selectedTab) }
                )
            } else {
                listCard {
                    ForEach(Array(activityItems.enumerated()), id: \.element.id) { index, item in
                        activityRow(item)
                        if index < activityItems.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var actionSection: some View {
        section(title: "Quick actions") {
            listCard {
                DSListRow(
                    title: "Open settings",
                    subtitle: "Privacy and notifications.",
                    leadingIcon: "gearshape.fill",
                    leadingTint: .textPrimary,
                    showsDisclosure: true
                ) {
                    router.presentSheet(.settings)
                }
                Divider()
                DSListRow(
                    title: session.isPremium ? "Manage subscription" : "View paywall",
                    subtitle: "Upgrade options.",
                    leadingIcon: "sparkles",
                    leadingTint: .warning,
                    showsDisclosure: true
                ) {
                    router.presentSheet(.paywall)
                }
            }
        }
    }

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            content()
        }
    }

    private func listCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .cardSurface(cornerRadius: DSSpacing.md)
    }

    private func activityRow(_ item: ActivityItem) -> some View {
        DSListRow(
            title: item.title,
            subtitle: item.message,
            leadingIcon: item.icon,
            leadingTint: item.tint
        )
    }

    private func copyToPasteboard(_ value: String) {
        UIPasteboard.general.string = value
        toast = .success("Copied to clipboard.")
    }

    private var sampleActivityItems: [ActivityItem] {
        guard session.isSignedIn else { return [] }
        return [
            ActivityItem(
                id: "onboarding",
                title: "Onboarding completed",
                message: "You finished the onboarding flow.",
                icon: "sparkles",
                tint: Color.info
            ),
            ActivityItem(
                id: "premium",
                title: "Premium preview",
                message: "You reviewed the paywall flow.",
                icon: "creditcard.fill",
                tint: Color.success
            )
        ]
    }

    private struct ActivityItem: Identifiable {
        let id: String
        let title: String
        let message: String
        let icon: String
        let tint: Color
    }
}

#Preview {
    NavigationStack {
        ProfileView(userId: "preview")
    }
    .environment(AppSession())
    .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
