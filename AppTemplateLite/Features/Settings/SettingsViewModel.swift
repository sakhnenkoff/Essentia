//
//  SettingsViewModel.swift
//  AppTemplateLite
//
//
//

import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    var isProcessing = false
    var errorMessage: String?

    func signOut(services: AppServices, session: AppSession) {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.signOutStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await services.signOut()
                session.resetForSignOut()
                services.logManager.trackEvent(event: Event.signOutSuccess)
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.signOutFail(error: error))
            }
            self.isProcessing = false
        }
    }

    func deleteAccount(services: AppServices, session: AppSession) {
        guard let auth = session.auth else {
            errorMessage = "No active session."
            return
        }
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.deleteAccountStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                let option = self.authReauthOption(auth: auth)
                try await services.authManager.deleteAccountWithReauthentication(option: option, revokeToken: false) {
                    try await services.userManager.deleteCurrentUser()
                }

                if let purchaseManager = services.purchaseManager {
                    try await purchaseManager.logOut()
                }
                services.logManager.deleteUserProfile()

                session.resetForSignOut(clearOnboarding: true)
                services.logManager.trackEvent(event: Event.deleteAccountSuccess)
            } catch {
                self.errorMessage = error.localizedDescription
                services.logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
            self.isProcessing = false
        }
    }

    func requestPushAuthorization(services: AppServices) {
        guard let pushManager = services.pushManager else {
            errorMessage = "Push notifications are disabled."
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await pushManager.requestAuthorization()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func authReauthOption(auth: UserAuthInfo) -> SignInOption {
        if auth.authProviders.contains(.apple) {
            return .apple
        }
        if auth.authProviders.contains(.google), let clientId = Constants.firebaseAppClientId {
            return .google(GIDClientID: clientId)
        }
        return .anonymous
    }
}

extension SettingsViewModel {
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)

        var eventName: String {
            switch self {
            case .signOutStart:
                return "Settings_SignOut_Start"
            case .signOutSuccess:
                return "Settings_SignOut_Success"
            case .signOutFail:
                return "Settings_SignOut_Fail"
            case .deleteAccountStart:
                return "Settings_Delete_Start"
            case .deleteAccountSuccess:
                return "Settings_Delete_Success"
            case .deleteAccountFail:
                return "Settings_Delete_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(let error), .deleteAccountFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
