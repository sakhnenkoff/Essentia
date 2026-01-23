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
                headerCard
                accountDetails
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

    private var headerCard: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            profileAvatar

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(session.currentUser?.commonNameCalculated ?? "Guest")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                Text("User ID: \(userId)")
                    .font(.captionLarge())
                    .foregroundStyle(Color.textTertiary)

                if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                    Text(email)
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            statusChip
        }
        .padding(DSSpacing.md)
        .cardSurface(cornerRadius: DSSpacing.md)
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

    private var statusChip: some View {
        let isPremium = session.isPremium
        let text = isPremium ? "Premium" : "Free plan"
        let tint = isPremium ? Color.success : Color.info

        return Text(text)
            .font(.captionLarge())
            .foregroundStyle(tint)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(tint.opacity(0.15))
            .clipShape(Capsule())
    }

    private var accountDetails: some View {
        sectionCard(title: "Account details") {
            if let name = session.currentUser?.commonNameCalculated {
                keyValueRow(title: "Name", value: name)
            }
            if let email = session.currentUser?.emailCalculated ?? session.auth?.email {
                keyValueRow(title: "Email", value: email)
            }

            DSButton(title: "Copy user ID", style: .secondary, isFullWidth: true) {
                copyToPasteboard(userId)
            }
        }
    }

    private var activitySection: some View {
        let activityItems = sampleActivityItems

        return sectionCard(title: "Recent activity") {
            if activityItems.isEmpty {
                EmptyStateView(
                    icon: "sparkles",
                    title: "No activity yet",
                    message: "Complete onboarding and explore features to see updates here.",
                    actionTitle: "View onboarding",
                    action: { router.navigateTo(.detail(title: "Onboarding progress"), for: router.selectedTab) }
                )
            } else {
                VStack(spacing: DSSpacing.sm) {
                    ForEach(activityItems) { item in
                        activityRow(item)
                    }
                }
            }
        }
    }

    private var actionSection: some View {
        sectionCard(title: "Quick actions") {
            GlassStack(spacing: DSSpacing.sm) {
                DSButton(title: "Open settings", icon: "gearshape.fill", style: .secondary, isFullWidth: true) {
                    router.presentSheet(.settings)
                }

                DSButton(title: session.isPremium ? "Manage subscription" : "View paywall", icon: "sparkles", isFullWidth: true) {
                    router.presentSheet(.paywall)
                }
            }
        }
    }

    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            content()
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: DSSpacing.md)
    }

    private func keyValueRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)
            Text(value)
                .font(.bodySmall())
                .foregroundStyle(Color.textPrimary)
        }
    }

    private func activityRow(_ item: ActivityItem) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            DSIconBadge(
                systemName: item.icon,
                size: 28,
                cornerRadius: 14,
                backgroundColor: item.tint.opacity(0.15),
                foregroundColor: item.tint,
                font: .headlineSmall()
            )

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(item.title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(item.message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
