//
//  NotificationSettingsViewModel.swift
//  SwiftChapterUSA_finder
//
//  Created on 4/26/26.
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var preferences: NotificationPreferences
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var pendingNotificationsCount = 0
    
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.preferences = notificationManager.preferences
        
        // Subscribe to notification manager updates
        notificationManager.$authorizationStatus
            .assign(to: &$authorizationStatus)
        
        notificationManager.$preferences
            .assign(to: &$preferences)
        
        loadPendingNotificationsCount()
    }
    
    // MARK: - Authorization
    
    /// Request notification permissions
    func requestPermissions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let granted = try await notificationManager.requestAuthorization()
            
            if !granted {
                errorMessage = "Notification permissions were denied. Please enable them in Settings."
                showError = true
            }
        } catch {
            errorMessage = "Failed to request permissions: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    /// Open app settings
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Preferences Management
    
    /// Save preferences and update subscriptions
    func savePreferences() {
        notificationManager.savePreferences(preferences)
        
        // Update CloudKit subscriptions based on new preferences
        Task {
            await updateSubscriptions()
        }
    }
    
    /// Toggle event reminders
    func toggleEventReminders(_ enabled: Bool) {
        preferences.eventReminders = enabled
        if !enabled {
            preferences.reminder24Hours = false
            preferences.reminder1Hour = false
        }
        savePreferences()
    }
    
    /// Toggle 24-hour reminder
    func toggle24HourReminder(_ enabled: Bool) {
        preferences.reminder24Hours = enabled
        if enabled {
            preferences.eventReminders = true
        }
        savePreferences()
    }
    
    /// Toggle 1-hour reminder
    func toggle1HourReminder(_ enabled: Bool) {
        preferences.reminder1Hour = enabled
        if enabled {
            preferences.eventReminders = true
        }
        savePreferences()
    }
    
    /// Toggle new event notifications
    func toggleNewEventNotifications(_ enabled: Bool) {
        preferences.newEventNotifications = enabled
        savePreferences()
    }
    
    /// Toggle event updates
    func toggleEventUpdates(_ enabled: Bool) {
        preferences.eventUpdates = enabled
        savePreferences()
    }
    
    /// Toggle RSVP confirmations
    func toggleRSVPConfirmations(_ enabled: Bool) {
        preferences.rsvpConfirmations = enabled
        savePreferences()
    }
    
    /// Toggle chapter announcements
    func toggleChapterAnnouncements(_ enabled: Bool) {
        preferences.chapterAnnouncements = enabled
        savePreferences()
    }
    
    /// Toggle blog posts
    func toggleBlogPosts(_ enabled: Bool) {
        preferences.newBlogPosts = enabled
        savePreferences()
    }
    
    /// Toggle sound
    func toggleSound(_ enabled: Bool) {
        preferences.soundEnabled = enabled
        savePreferences()
    }
    
    /// Toggle badge
    func toggleBadge(_ enabled: Bool) {
        preferences.badgeEnabled = enabled
        if !enabled {
            notificationManager.clearBadge()
        }
        savePreferences()
    }
    
    // MARK: - Subscription Management
    
    /// Update CloudKit subscriptions based on preferences
    private func updateSubscriptions() async {
        // This will be called when preferences change
        // Individual subscriptions are managed in EventManager and NotificationManager
        print("🔔 [NotificationSettings] Preferences updated")
    }
    
    // MARK: - Notification Stats
    
    /// Load pending notifications count
    func loadPendingNotificationsCount() {
        Task {
            pendingNotificationsCount = await notificationManager.getPendingNotificationsCount()
        }
    }
    
    /// Clear all pending notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationManager.clearBadge()
        loadPendingNotificationsCount()
    }
    
    // MARK: - Test Notification
    
    /// Send a test notification
    func sendTestNotification() async {
        guard authorizationStatus == .authorized else {
            await requestPermissions()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification 🔔"
        content.body = "Your notifications are working perfectly!"
        content.sound = preferences.soundEnabled ? .default : nil
        
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: nil // Immediate
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ [NotificationSettings] Test notification sent")
        } catch {
            errorMessage = "Failed to send test notification: \(error.localizedDescription)"
            showError = true
        }
    }
}
