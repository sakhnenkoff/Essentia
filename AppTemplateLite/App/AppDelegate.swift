//
//  AppDelegate.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import UserNotifications
import Firebase
import FirebaseMessaging
import DesignSystem

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppConfiguration.validateConfiguration()
        DesignSystem.configureWithDefaults()

        #if DEBUG
        UserDefaults.standard.set(false, forKey: "com.apple.CoreData.SQLDebug")
        UserDefaults.standard.set(false, forKey: "com.apple.CoreData.Logging.stderr")
        #endif

        registerForRemotePushNotifications(application: application)
        return true
    }

    private func registerForRemotePushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        #if !MOCK
        Messaging.messaging().delegate = self
        #endif
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        #if DEBUG
        print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
        #endif
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo["aps"] as? [String: Any]
        NotificationCenter.default.post(name: .pushNotification, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NotificationCenter.default.postFCMToken(token: fcmToken ?? "")
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool)
    case dev
    case prod

    static var current: BuildConfiguration {
        var config: BuildConfiguration

        #if MOCK
        config = .mock(isSignedIn: false)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        if Utilities.isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            config = .mock(isSignedIn: isSignedIn)
        }

        return config
    }

    func configureFirebase() {
        switch self {
        case .mock:
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}
