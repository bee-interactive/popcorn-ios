import SwiftUI
import AVFoundation
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    // Called when the user grants (or revokes) notification permissions
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Convert token to a hex string
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()

        // Call our bridging function so the token goes to PHP
        NativePHPSetPushTokenC(tokenString)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications:", error.localizedDescription)
    }
}
