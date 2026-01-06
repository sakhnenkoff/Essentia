//
//  AppServices.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import LocalPersistance
import LocalPersistanceMock
import Networking

@MainActor
@Observable
final class AppServices {
    let configuration: BuildConfiguration

    let logManager: LogManager
    let authManager: AuthManager
    let userManager: UserManager
    let keychainService: KeychainCacheServiceProtocol
    let userDefaultsService: UserDefaultsCacheServiceProtocol
    let networkingService: NetworkingServiceProtocol

    let abTestManager: ABTestManager?
    let purchaseManager: PurchaseManager?
    let pushManager: PushManager?
    let hapticManager: HapticManager?
    let soundEffectManager: SoundEffectManager?
    let streakManager: StreakManager?
    let xpManager: ExperiencePointsManager?
    let progressManager: ProgressManager?

    init(configuration: BuildConfiguration = .current) {
        self.configuration = configuration

        let logManager: LogManager
        let authManager: AuthManager
        let userManager: UserManager
        let keychainService: KeychainCacheServiceProtocol
        let userDefaultsService: UserDefaultsCacheServiceProtocol
        let networkingService: NetworkingServiceProtocol

        var abTestManager: ABTestManager?
        var purchaseManager: PurchaseManager?
        var pushManager: PushManager?
        var hapticManager: HapticManager?
        var soundEffectManager: SoundEffectManager?
        var streakManager: StreakManager?
        var xpManager: ExperiencePointsManager?
        var progressManager: ProgressManager?

        switch configuration {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: true, system: .stdout)
            ])
            authManager = AuthManager(
                service: MockAuthService(user: isSignedIn ? .mock() : nil),
                logger: logManager
            )
            userManager = UserManager(
                services: MockUserServices(document: isSignedIn ? .mock : nil),
                configuration: Self.userManagerConfiguration,
                logger: logManager
            )
            keychainService = MockKeychainCacheService()
            userDefaultsService = MockUserDefaultsCacheService()
            networkingService = NetworkingService()

            if FeatureFlags.enableABTesting {
                abTestManager = ABTestManager(service: MockABTestService(), logManager: logManager)
            }
            if FeatureFlags.enablePurchases {
                purchaseManager = PurchaseManager(service: MockPurchaseService(), logger: logManager)
            }
            if FeatureFlags.enableHaptics {
                hapticManager = HapticManager(logger: logManager)
            }
            if FeatureFlags.enableStreaks {
                streakManager = StreakManager(
                    services: MockStreakServices(),
                    configuration: Self.streakConfiguration,
                    logger: logManager
                )
            }
            if FeatureFlags.enableExperiencePoints {
                xpManager = ExperiencePointsManager(
                    services: MockExperiencePointsServices(),
                    configuration: Self.xpConfiguration,
                    logger: logManager
                )
            }
            if FeatureFlags.enableProgress {
                progressManager = ProgressManager(
                    services: MockProgressServices(),
                    configuration: Self.progressConfiguration,
                    logger: logManager
                )
            }

        case .dev:
            var loggingServices: [any LogService] = [
                ConsoleService(printParameters: true)
            ]
            if FeatureFlags.enableFirebaseAnalytics {
                loggingServices.append(FirebaseAnalyticsService())
            }
            if FeatureFlags.enableMixpanel {
                loggingServices.append(MixpanelService(token: Keys.mixpanelToken))
            }
            if FeatureFlags.enableCrashlytics {
                loggingServices.append(FirebaseCrashlyticsService())
            }
            logManager = LogManager(services: loggingServices)
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(
                services: ProductionUserServices(),
                configuration: Self.userManagerConfiguration,
                logger: logManager
            )
            keychainService = KeychainCacheService()
            userDefaultsService = UserDefaultsCacheService()
            networkingService = NetworkingService()

            if FeatureFlags.enableABTesting {
                abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            }
            if FeatureFlags.enablePurchases {
                purchaseManager = PurchaseManager(
                    service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                    logger: logManager
                )
            }
            if FeatureFlags.enableHaptics {
                hapticManager = HapticManager(logger: logManager)
            }
            if FeatureFlags.enableStreaks {
                streakManager = StreakManager(
                    services: ProdStreakServices(),
                    configuration: Self.streakConfiguration,
                    logger: logManager
                )
            }
            if FeatureFlags.enableExperiencePoints {
                xpManager = ExperiencePointsManager(
                    services: ProdExperiencePointsServices(),
                    configuration: Self.xpConfiguration,
                    logger: logManager
                )
            }
            if FeatureFlags.enableProgress {
                progressManager = ProgressManager(
                    services: ProdProgressServices(),
                    configuration: Self.progressConfiguration,
                    logger: logManager
                )
            }

        case .prod:
            var loggingServices: [any LogService] = []
            if FeatureFlags.enableFirebaseAnalytics {
                loggingServices.append(FirebaseAnalyticsService())
            }
            if FeatureFlags.enableMixpanel {
                loggingServices.append(MixpanelService(token: Keys.mixpanelToken))
            }
            if FeatureFlags.enableCrashlytics {
                loggingServices.append(FirebaseCrashlyticsService())
            }
            logManager = LogManager(services: loggingServices)
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(
                services: ProductionUserServices(),
                configuration: Self.userManagerConfiguration,
                logger: logManager
            )
            keychainService = KeychainCacheService()
            userDefaultsService = UserDefaultsCacheService()
            networkingService = NetworkingService()

            if FeatureFlags.enableABTesting {
                abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            }
            if FeatureFlags.enablePurchases {
                purchaseManager = PurchaseManager(
                    service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                    logger: logManager
                )
            }
            if FeatureFlags.enableHaptics {
                hapticManager = HapticManager(logger: logManager)
            }
            if FeatureFlags.enableStreaks {
                streakManager = StreakManager(
                    services: ProdStreakServices(),
                    configuration: Self.streakConfiguration,
                    logger: logManager
                )
            }
            if FeatureFlags.enableExperiencePoints {
                xpManager = ExperiencePointsManager(
                    services: ProdExperiencePointsServices(),
                    configuration: Self.xpConfiguration,
                    logger: logManager
                )
            }
            if FeatureFlags.enableProgress {
                progressManager = ProgressManager(
                    services: ProdProgressServices(),
                    configuration: Self.progressConfiguration,
                    logger: logManager
                )
            }
        }

        if FeatureFlags.enablePushNotifications {
            pushManager = PushManager(logManager: logManager)
        }
        if FeatureFlags.enableSoundEffects {
            soundEffectManager = SoundEffectManager(logger: logManager)
        }

        self.logManager = logManager
        self.authManager = authManager
        self.userManager = userManager
        self.keychainService = keychainService
        self.userDefaultsService = userDefaultsService
        self.networkingService = networkingService
        self.abTestManager = abTestManager
        self.purchaseManager = purchaseManager
        self.pushManager = pushManager
        self.hapticManager = hapticManager
        self.soundEffectManager = soundEffectManager
        self.streakManager = streakManager
        self.xpManager = xpManager
        self.progressManager = progressManager
    }

    func restoreSession(for user: UserAuthInfo) async {
        do {
            try await userManager.logIn(user.uid)
        } catch {
            logManager.trackEvent(eventName: "UserManager_LogIn_Fail", parameters: error.eventParameters, type: .warning)
        }

        await withTaskGroup(of: Void.self) { group in
            if let purchaseManager {
                group.addTask {
                    _ = try? await purchaseManager.logIn(
                        userId: user.uid,
                        userAttributes: PurchaseProfileAttributes(
                            email: user.email,
                            mixpanelDistinctId: Constants.mixpanelDistinctId,
                            firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
                        )
                    )
                }
            }
            if let streakManager {
                group.addTask {
                    try? await streakManager.logIn(userId: user.uid)
                }
            }
            if let xpManager {
                group.addTask {
                    try? await xpManager.logIn(userId: user.uid)
                }
            }
            if let progressManager {
                group.addTask {
                    try? await progressManager.logIn(userId: user.uid)
                }
            }
        }

        logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
    }

    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.signIn(auth: user, isNewUser: isNewUser)
        await restoreSession(for: user)
    }

    func signOut() async throws {
        try authManager.signOut()
        userManager.signOut()

        if let purchaseManager {
            try await purchaseManager.logOut()
        }
        streakManager?.logOut()
        xpManager?.logOut()
        if let progressManager {
            await progressManager.logOut()
        }

        logManager.deleteUserProfile()
    }
}

extension AppServices {
    static let streakConfiguration = StreakConfiguration(
        streakKey: Constants.streakKey,
        eventsRequiredPerDay: 1,
        useServerCalculation: false,
        leewayHours: 0,
        freezeBehavior: .autoConsumeFreezes
    )

    static let xpConfiguration = ExperiencePointsConfiguration(
        experienceKey: Constants.xpKey,
        useServerCalculation: false
    )

    static let progressConfiguration = ProgressConfiguration(
        progressKey: Constants.progressKey
    )

    static let userManagerConfiguration = DataManagerSyncConfiguration(
        managerKey: "UserMan",
        enablePendingWrites: true
    )
}
