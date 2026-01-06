//
//  AppSession.swift
//  AppTemplateLite
//
//
//

import SwiftUI

@MainActor
@Observable
final class AppSession {
    enum RootState {
        case loading
        case onboarding
        case auth
        case paywall
        case app
    }

    private let onboardingKey = "app_onboarding_complete"
    private let paywallKey = "app_paywall_dismissed"

    private var didBootstrap = false

    var isLoading = true
    var auth: UserAuthInfo?
    var currentUser: UserModel?
    var isOnboardingComplete: Bool
    var isPremium: Bool
    var hasDismissedPaywall: Bool
    var lastErrorMessage: String?

    init() {
        isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)
        hasDismissedPaywall = UserDefaults.standard.bool(forKey: paywallKey)
        isPremium = false
    }

    var isSignedIn: Bool {
        auth != nil
    }

    var shouldShowPaywall: Bool {
        FeatureFlags.enablePurchases && !isPremium && !hasDismissedPaywall
    }

    var rootState: RootState {
        if isLoading {
            return .loading
        }
        if !isOnboardingComplete {
            return .onboarding
        }
        if !isSignedIn {
            return .auth
        }
        if shouldShowPaywall {
            return .paywall
        }
        return .app
    }

    func bootstrap(services: AppServices) async {
        guard !didBootstrap else { return }
        didBootstrap = true
        isLoading = true

        let auth = services.authManager.auth
        self.auth = auth

        if let auth {
            await services.restoreSession(for: auth)
            do {
                currentUser = try await services.userManager.getUser()
            } catch {
                lastErrorMessage = error.localizedDescription
            }
        }

        if currentUser?.didCompleteOnboarding == true {
            setOnboardingComplete()
        }

        if FeatureFlags.enablePurchases, let purchaseManager = services.purchaseManager {
            isPremium = purchaseManager.entitlements.hasActiveEntitlement
        }

        isLoading = false
    }

    func setOnboardingComplete() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func markPaywallDismissed() {
        hasDismissedPaywall = true
        UserDefaults.standard.set(true, forKey: paywallKey)
    }

    func resetPaywallDismissal() {
        hasDismissedPaywall = false
        UserDefaults.standard.removeObject(forKey: paywallKey)
    }

    func resetOnboarding() {
        isOnboardingComplete = false
        UserDefaults.standard.removeObject(forKey: onboardingKey)
    }

    func updatePremiumStatus(entitlements: [PurchasedEntitlement]) {
        isPremium = entitlements.hasActiveEntitlement
    }

    func updateAuth(user: UserAuthInfo, currentUser: UserModel?) {
        auth = user
        if let currentUser {
            self.currentUser = currentUser
            if currentUser.didCompleteOnboarding == true {
                setOnboardingComplete()
            }
        }
    }

    func resetForSignOut(clearOnboarding: Bool = false) {
        auth = nil
        currentUser = nil
        isPremium = false
        hasDismissedPaywall = false
        lastErrorMessage = nil

        if clearOnboarding {
            isOnboardingComplete = false
            UserDefaults.standard.removeObject(forKey: onboardingKey)
        }
        UserDefaults.standard.removeObject(forKey: paywallKey)
    }
}
