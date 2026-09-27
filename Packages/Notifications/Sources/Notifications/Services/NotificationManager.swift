//
//  NotificationManager.swift
//  Notifications
//

import Foundation
import UserNotifications
import Combine
import Common

public class NotificationManager: ObservableObject {
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published public var preferences = NotificationPreferences()
    
    private let center = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadPreferences()
        checkAuthorizationStatus()
    }
    
    public func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        let granted = try await center.requestAuthorization(options: options)
        
        await MainActor.run {
            self.authorizationStatus = granted ? .authorized : .denied
        }
        
        return granted
    }
    
    public func checkAuthorizationStatus() {
        Task {
            let settings = await center.notificationSettings()
            await MainActor.run {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    public func savePreferences(_ preferences: NotificationPreferences) {
        self.preferences = preferences
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "notificationPreferences")
        }
    }
    
    public func getPendingNotificationsCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "notificationPreferences"),
           let decoded = try? JSONDecoder().decode(NotificationPreferences.self, from: data) {
            self.preferences = decoded
        }
    }
}
