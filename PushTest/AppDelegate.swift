//
//  AppDelegate.swift
//  PushTest
//
//  Created by Sugeun Jun on 2023/10/02.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Task {
            try? await registerRemoteNotifications()
        }
        return true
    }
}

// MARK: - Remote Push Notifications
extension AppDelegate {
    @MainActor
    private func registerRemoteNotifications() async throws {
        if try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        print("DeviceToken: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error)")
    }
}
