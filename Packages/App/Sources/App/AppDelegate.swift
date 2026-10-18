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
import Common

#if os(iOS)
public class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // Temporarily disabled to debug crash
    // let notificationManager = NotificationManager()
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Check authorization status on launch
        // notificationManager.checkAuthorizationStatus()
        
        return true
    }
    
    // MARK: - Orientation Support
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    // MARK: - Remote Notification Registration
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: Implement device token registration when NotificationManager supports it
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // TODO: Implement remote notification error handling
    }
    
    // MARK: - Deep Link Handling
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle referral deep links
        if DeepLinkHandler.isReferralLink(url) {
            if let referralLink = DeepLinkHandler.parseReferralLink(url) {
                // Store the referral link for the next screen to pick up
                UserDefaults.standard.set(
                    referralLink.referrerId?.uuidString,
                    forKey: "pendingReferrerId"
                )
                
                if let chapterId = referralLink.chapterId {
                    UserDefaults.standard.set(
                        chapterId.uuidString,
                        forKey: "pendingChapterId"
                    )
                }
                
                // Post notification that referral link was received
                NotificationCenter.default.post(
                    name: .referralLinkReceived,
                    object: nil,
                    userInfo: [
                        "referrerId": referralLink.referrerId?.uuidString as Any,
                        "chapterId": referralLink.chapterId?.uuidString as Any
                    ]
                )
                
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Notification Handling
    
    /// Called when notification is received while app is in foreground
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    /// Called when user taps on a notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
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
    static let referralLinkReceived = Notification.Name("referralLinkReceived")
}
#endif
