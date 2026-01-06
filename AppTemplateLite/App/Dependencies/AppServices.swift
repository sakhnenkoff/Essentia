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

private struct ServiceBundle {
    let logManager: LogManager
    let authManager: AuthManager
    let userManager: UserManager
    let keychainService: KeychainCacheServiceProtocol
    let userDefaultsService: UserDefaultsCacheServiceProtocol
    let networkingService: NetworkingServiceProtocol
    let abTestManager: ABTestManager?
    let purchaseManager: PurchaseManager?
    let hapticManager: HapticManager?
    let streakManager: StreakManager?
    let xpManager: ExperiencePointsManager?
    let progressManager: ProgressManager?
}

private struct OptionalManagers {
    let abTestManager: ABTestManager?
    let purchaseManager: PurchaseManager?
    let hapticManager: HapticManager?
    let streakManager: StreakManager?
    let xpManager: ExperiencePointsManager?
    let progressManager: ProgressManager?
}

@MainActor
@Observable
final class AppServices {
    let configuration: BuildConfiguration
    let consentManager: ConsentManager

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

        let isMock: Bool
        if case .mock = configuration {
            isMock = true
        } else {
            isMock = false
        }

        let consentManager = ConsentManager(isMock: isMock)
        let analyticsEnabled = consentManager.shouldEnableAnalytics

        let bundle: ServiceBundle
        switch configuration {
        case .mock(isSignedIn: let isSignedIn):
            bundle = Self.makeMockServices(isSignedIn: isSignedIn)
        case .dev:
            bundle = Self.makeDevServices(analyticsEnabled: analyticsEnabled)
        case .prod:
            bundle = Self.makeProdServices(analyticsEnabled: analyticsEnabled)
        }

        let pushManager = FeatureFlags.enablePushNotifications
            ? PushManager(logManager: bundle.logManager)
            : nil
        let soundEffectManager = FeatureFlags.enableSoundEffects
            ? SoundEffectManager(logger: bundle.logManager)
            : nil

        self.consentManager = consentManager
        self.logManager = bundle.logManager
        self.authManager = bundle.authManager
        self.userManager = bundle.userManager
        self.keychainService = bundle.keychainService
        self.userDefaultsService = bundle.userDefaultsService
        self.networkingService = bundle.networkingService
        self.abTestManager = bundle.abTestManager
        self.purchaseManager = bundle.purchaseManager
        self.pushManager = pushManager
        self.hapticManager = bundle.hapticManager
        self.soundEffectManager = soundEffectManager
        self.streakManager = bundle.streakManager
        self.xpManager = bundle.xpManager
        self.progressManager = bundle.progressManager
        bundle.logManager.addUserProperties(dict: consentManager.eventParameters, isHighPriority: false)
    }

    private static func makeMockServices(isSignedIn: Bool) -> ServiceBundle {
        let logManager = LogManager(services: [
            ConsoleService(printParameters: true, system: .stdout)
        ])
        let authManager = AuthManager(
            service: MockAuthService(user: isSignedIn ? .mock() : nil),
            logger: logManager
        )
        let userManager = UserManager(
            services: MockUserServices(document: isSignedIn ? .mock : nil),
            configuration: Self.userManagerConfiguration,
            logger: logManager
        )
        let managers = Self.makeMockOptionalManagers(logManager: logManager)

        return ServiceBundle(
            logManager: logManager,
            authManager: authManager,
            userManager: userManager,
            keychainService: MockKeychainCacheService(),
            userDefaultsService: MockUserDefaultsCacheService(),
            networkingService: NetworkingService(),
            abTestManager: managers.abTestManager,
            purchaseManager: managers.purchaseManager,
            hapticManager: managers.hapticManager,
            streakManager: managers.streakManager,
            xpManager: managers.xpManager,
            progressManager: managers.progressManager
        )
    }

    private static func makeDevServices(analyticsEnabled: Bool) -> ServiceBundle {
        let logManager = Self.makeDevLogManager(analyticsEnabled: analyticsEnabled)
        let managers = Self.makeLiveOptionalManagers(
            logManager: logManager,
            abTestService: LocalABTestService()
        )

        return Self.makeLiveServices(logManager: logManager, managers: managers)
    }

    private static func makeProdServices(analyticsEnabled: Bool) -> ServiceBundle {
        let logManager = Self.makeProdLogManager(analyticsEnabled: analyticsEnabled)
        let managers = Self.makeLiveOptionalManagers(
            logManager: logManager,
            abTestService: FirebaseABTestService()
        )

        return Self.makeLiveServices(logManager: logManager, managers: managers)
    }

    private static func makeDevLogManager(analyticsEnabled: Bool) -> LogManager {
        var loggingServices: [any LogService] = [
            ConsoleService(printParameters: true)
        ]
        if analyticsEnabled && FeatureFlags.enableFirebaseAnalytics {
            loggingServices.append(FirebaseAnalyticsService())
        }
        if analyticsEnabled && FeatureFlags.enableMixpanel {
            loggingServices.append(MixpanelService(token: Keys.mixpanelToken))
        }
        if FeatureFlags.enableCrashlytics {
            loggingServices.append(FirebaseCrashlyticsService())
        }

        return LogManager(services: loggingServices)
    }

    private static func makeProdLogManager(analyticsEnabled: Bool) -> LogManager {
        var loggingServices: [any LogService] = []
        if analyticsEnabled && FeatureFlags.enableFirebaseAnalytics {
            loggingServices.append(FirebaseAnalyticsService())
        }
        if analyticsEnabled && FeatureFlags.enableMixpanel {
            loggingServices.append(MixpanelService(token: Keys.mixpanelToken))
        }
        if FeatureFlags.enableCrashlytics {
            loggingServices.append(FirebaseCrashlyticsService())
        }

        return LogManager(services: loggingServices)
    }

    private static func makeLiveServices(
        logManager: LogManager,
        managers: OptionalManagers
    ) -> ServiceBundle {
        let authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
        let userManager = UserManager(
            services: ProductionUserServices(),
            configuration: Self.userManagerConfiguration,
            logger: logManager
        )

        return ServiceBundle(
            logManager: logManager,
            authManager: authManager,
            userManager: userManager,
            keychainService: KeychainCacheService(),
            userDefaultsService: UserDefaultsCacheService(),
            networkingService: NetworkingService(),
            abTestManager: managers.abTestManager,
            purchaseManager: managers.purchaseManager,
            hapticManager: managers.hapticManager,
            streakManager: managers.streakManager,
            xpManager: managers.xpManager,
            progressManager: managers.progressManager
        )
    }

    private static func makeMockOptionalManagers(logManager: LogManager) -> OptionalManagers {
        let abTestManager = FeatureFlags.enableABTesting
            ? ABTestManager(service: MockABTestService(), logManager: logManager)
            : nil
        let purchaseManager = FeatureFlags.enablePurchases
            ? PurchaseManager(service: MockPurchaseService(), logger: logManager)
            : nil
        let hapticManager = FeatureFlags.enableHaptics
            ? HapticManager(logger: logManager)
            : nil
        let streakManager = FeatureFlags.enableStreaks
            ? StreakManager(
                services: MockStreakServices(),
                configuration: Self.streakConfiguration,
                logger: logManager
            )
            : nil
        let xpManager = FeatureFlags.enableExperiencePoints
            ? ExperiencePointsManager(
                services: MockExperiencePointsServices(),
                configuration: Self.xpConfiguration,
                logger: logManager
            )
            : nil
        let progressManager = FeatureFlags.enableProgress
            ? ProgressManager(
                services: MockProgressServices(),
                configuration: Self.progressConfiguration,
                logger: logManager
            )
            : nil

        return OptionalManagers(
            abTestManager: abTestManager,
            purchaseManager: purchaseManager,
            hapticManager: hapticManager,
            streakManager: streakManager,
            xpManager: xpManager,
            progressManager: progressManager
        )
    }

    private static func makeLiveOptionalManagers(
        logManager: LogManager,
        abTestService: ABTestService
    ) -> OptionalManagers {
        let abTestManager = FeatureFlags.enableABTesting
            ? ABTestManager(service: abTestService, logManager: logManager)
            : nil
        let purchaseManager = FeatureFlags.enablePurchases
            ? PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey),
                logger: logManager
            )
            : nil
        let hapticManager = FeatureFlags.enableHaptics
            ? HapticManager(logger: logManager)
            : nil
        let streakManager = FeatureFlags.enableStreaks
            ? StreakManager(
                services: ProdStreakServices(),
                configuration: Self.streakConfiguration,
                logger: logManager
            )
            : nil
        let xpManager = FeatureFlags.enableExperiencePoints
            ? ExperiencePointsManager(
                services: ProdExperiencePointsServices(),
                configuration: Self.xpConfiguration,
                logger: logManager
            )
            : nil
        let progressManager = FeatureFlags.enableProgress
            ? ProgressManager(
                services: ProdProgressServices(),
                configuration: Self.progressConfiguration,
                logger: logManager
            )
            : nil

        return OptionalManagers(
            abTestManager: abTestManager,
            purchaseManager: purchaseManager,
            hapticManager: hapticManager,
            streakManager: streakManager,
            xpManager: xpManager,
            progressManager: progressManager
        )
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
