//
//  SwiftChapterUSA_finderApp.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

@main
struct SwiftChapterUSA_finderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var chapterManager = ChapterManager()
    @StateObject private var eventManager = EventManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(chapterManager)
                .environmentObject(eventManager)
                .onAppear {
                    requestNotificationPermissions()
                }
        }
    }
    
    /// Request notification permissions on first launch
    private func requestNotificationPermissions() {
        Task {
            // Only request if not already determined
            let notificationManager = NotificationManager.shared
            if notificationManager.authorizationStatus == .notDetermined {
                // Wait a bit before asking (better UX)
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                _ = try? await notificationManager.requestAuthorization()
            }
        }
    }
}
