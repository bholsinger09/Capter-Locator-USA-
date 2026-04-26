//
//  NotificationManager.swift
//  SwiftChapterUSA_finder
//
//  Created on 4/26/26.
//

import Foundation
import UserNotifications
import CloudKit
import Combine

/// Manages all push and local notifications for the app
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var preferences = NotificationPreferences()
    
    private let center = UNUserNotificationCenter.current()
    private let container = CKContainer(identifier: "iCloud.ChapterFinder")
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadPreferences()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Request notification permissions from the user
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
        let granted = try await center.requestAuthorization(options: options)
        
        await MainActor.run {
            self.authorizationStatus = granted ? .authorized : .denied
        }
        
        if granted {
            await registerForRemoteNotifications()
        }
        
        return granted
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        Task {
            let settings = await center.notificationSettings()
            await MainActor.run {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    /// Register for remote (push) notifications
    @MainActor
    private func registerForRemoteNotifications() {
        #if !targetEnvironment(simulator)
        UIApplication.shared.registerForRemoteNotifications()
        #else
        print("📱 [NotificationManager] Skipping remote notifications on simulator")
        #endif
    }
    
    // MARK: - Event Reminder Notifications
    
    /// Schedule reminder notifications for an event
    func scheduleEventReminders(for event: Event, userRSVP: EventRSVP?) async throws {
        guard preferences.eventReminders else { return }
        guard let userRSVP = userRSVP, userRSVP.status == .confirmed else { return }
        
        // Cancel any existing reminders for this event
        await cancelEventReminders(eventID: event.id.uuidString)
        
        let now = Date()
        guard event.eventDate > now else { return }
        
        // 24-hour reminder
        if preferences.reminder24Hours {
            let reminderDate = event.eventDate.addingTimeInterval(-24 * 60 * 60)
            if reminderDate > now {
                try await scheduleNotification(
                    id: "\(event.id.uuidString)-24hr",
                    title: "Event Tomorrow! 📅",
                    body: "\(event.title) starts tomorrow at \(formatTime(event.eventDate))",
                    date: reminderDate,
                    eventID: event.id.uuidString
                )
            }
        }
        
        // 1-hour reminder
        if preferences.reminder1Hour {
            let reminderDate = event.eventDate.addingTimeInterval(-60 * 60)
            if reminderDate > now {
                try await scheduleNotification(
                    id: "\(event.id.uuidString)-1hr",
                    title: "Event Starting Soon! ⏰",
                    body: "\(event.title) starts in 1 hour",
                    date: reminderDate,
                    eventID: event.id.uuidString
                )
            }
        }
        
        print("✅ [NotificationManager] Scheduled reminders for: \(event.title)")
    }
    
    /// Cancel all reminder notifications for an event
    func cancelEventReminders(eventID: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(eventID)-24hr",
            "\(eventID)-1hr"
        ])
        print("🗑️ [NotificationManager] Cancelled reminders for event: \(eventID)")
    }
    
    /// Schedule a local notification
    private func scheduleNotification(
        id: String,
        title: String,
        body: String,
        date: Date,
        eventID: String? = nil
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        if let eventID = eventID {
            content.userInfo = ["eventID": eventID, "type": "eventReminder"]
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }
    
    // MARK: - RSVP Confirmation Notifications
    
    /// Send immediate notification for RSVP confirmation
    func sendRSVPConfirmation(for event: Event, guestCount: Int) async throws {
        guard preferences.rsvpConfirmations else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "RSVP Confirmed! ✓"
        
        if guestCount > 1 {
            content.body = "You're registered for \(event.title) with \(guestCount - 1) guest(s)"
        } else {
            content.body = "You're registered for \(event.title)"
        }
        
        content.sound = .default
        content.userInfo = ["eventID": event.id, "type": "rsvpConfirmation"]
        
        let request = UNNotificationRequest(
            identifier: "rsvp-\(event.id)-\(UUID().uuidString)",
            content: content,
            trigger: nil // Immediate
        )
        
        try await center.add(request)
        print("✅ [NotificationManager] Sent RSVP confirmation for: \(event.title)")
    }
    
    // MARK: - CloudKit Subscriptions (Push Notifications)
    
    /// Subscribe to new events in user's state
    func subscribeToNewEvents(userState: String?) async throws {
        guard preferences.newEventNotifications else { return }
        guard let userState = userState else { return }
        
        let subscriptionID = "new-events-\(userState)"
        
        // Check if subscription already exists
        if await checkSubscriptionExists(subscriptionID) {
            print("✅ [NotificationManager] Already subscribed to new events in \(userState)")
            return
        }
        
        // Create predicate for events in user's state
        let predicate = NSPredicate(format: "state == %@ AND isActive == %d", userState, 1)
        
        let subscription = CKQuerySubscription(
            recordType: "Event",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New event added in your area!"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        try await container.publicCloudDatabase.save(subscription)
        print("✅ [NotificationManager] Subscribed to new events in \(userState)")
    }
    
    /// Subscribe to updates for a specific event
    func subscribeToEventUpdates(eventID: String) async throws {
        guard preferences.eventUpdates else { return }
        
        let subscriptionID = "event-updates-\(eventID)"
        
        if await checkSubscriptionExists(subscriptionID) {
            return
        }
        
        let predicate = NSPredicate(format: "id == %@", eventID)
        
        let subscription = CKQuerySubscription(
            recordType: "Event",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "An event you're attending has been updated"
        notificationInfo.soundName = "default"
        
        subscription.notificationInfo = notificationInfo
        
        try await container.publicCloudDatabase.save(subscription)
        print("✅ [NotificationManager] Subscribed to updates for event: \(eventID)")
    }
    
    /// Unsubscribe from event updates when RSVP is cancelled
    func unsubscribeFromEventUpdates(eventID: String) async {
        let subscriptionID = "event-updates-\(eventID)"
        
        do {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                container.publicCloudDatabase.delete(withSubscriptionID: subscriptionID) { subscriptionID, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let subscriptionID = subscriptionID {
                        continuation.resume(returning: subscriptionID)
                    } else {
                        continuation.resume(throwing: NSError(domain: "NotificationManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error deleting subscription"]))
                    }
                }
            }
            print("🗑️ [NotificationManager] Unsubscribed from event: \(eventID)")
        } catch {
            print("⚠️ [NotificationManager] Failed to unsubscribe: \(error.localizedDescription)")
        }
    }
    
    /// Check if a subscription exists
    private func checkSubscriptionExists(_ subscriptionID: String) async -> Bool {
        do {
            _ = try await container.publicCloudDatabase.subscription(for: subscriptionID)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Badge Management
    
    /// Clear app badge
    func clearBadge() {
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    /// Get pending notification count
    func getPendingNotificationsCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    /// Get delivered notification count
    func getDeliveredNotificationsCount() async -> Int {
        let notifications = await center.deliveredNotifications()
        return notifications.count
    }
    
    // MARK: - Preferences Management
    
    /// Save notification preferences
    func savePreferences(_ preferences: NotificationPreferences) {
        self.preferences = preferences
        
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "notificationPreferences")
            print("✅ [NotificationManager] Saved notification preferences")
        }
    }
    
    /// Load notification preferences
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "notificationPreferences"),
           let decoded = try? JSONDecoder().decode(NotificationPreferences.self, from: data) {
            self.preferences = decoded
        }
    }
    
    // MARK: - Utilities
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - UIApplication Extension
#if canImport(UIKit)
import UIKit

extension NotificationManager {
    /// Handle device token registration
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("✅ [NotificationManager] Device Token: \(token)")
        
        // Store token for future use (e.g., send to your backend)
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    
    /// Handle registration failure
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        print("❌ [NotificationManager] Failed to register: \(error.localizedDescription)")
    }
}
#endif
