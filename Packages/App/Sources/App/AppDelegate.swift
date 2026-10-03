//
//  AppDelegate.swift
//  SwiftChapterUSA_finder
//
//  Created on 4/26/26.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // Temporarily disabled to debug crash
    // let notificationManager = NotificationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Check authorization status on launch
        // notificationManager.checkAuthorizationStatus()
        
        return true
    }
    
    // MARK: - Orientation Support
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    // MARK: - Remote Notification Registration
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: Implement device token registration when NotificationManager supports it
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // TODO: Implement remote notification error handling
    }
    
    // MARK: - Notification Handling
    
    /// Called when notification is received while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    /// Called when user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different notification types
        if let type = userInfo["type"] as? String {
            switch type {
            case "eventReminder", "rsvpConfirmation":
                if let eventID = userInfo["eventID"] as? String {
                    handleEventNotification(eventID: eventID)
                }
                
            case "newEvent":
                // Navigate to Events tab
                NotificationCenter.default.post(name: .navigateToEvents, object: nil)
                
            case "chapterAnnouncement":
                if let chapterID = userInfo["chapterID"] as? String {
                    handleChapterNotification(chapterID: chapterID)
                }
                
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    // MARK: - Navigation Helpers
    
    private func handleEventNotification(eventID: String) {
        // Post notification to navigate to specific event
        NotificationCenter.default.post(
            name: .navigateToEvent,
            object: nil,
            userInfo: ["eventID": eventID]
        )
    }
    
    private func handleChapterNotification(chapterID: String) {
        // Post notification to navigate to specific chapter
        NotificationCenter.default.post(
            name: .navigateToChapter,
            object: nil,
            userInfo: ["chapterID": chapterID]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToEvents = Notification.Name("navigateToEvents")
    static let navigateToEvent = Notification.Name("navigateToEvent")
    static let navigateToChapter = Notification.Name("navigateToChapter")
}
#endif
