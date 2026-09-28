//
//  SwiftChapterUSA_finderApp.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
import App
import Authentication
import Chapters
import Events
import Notifications

@main
struct SwiftChapterUSA_finderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dependencyContainer = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView(container: dependencyContainer)
                .environmentObject(dependencyContainer.authenticationManager)
                .environmentObject(dependencyContainer.chaptersViewModel)
                .environmentObject(dependencyContainer.eventsViewModel)
                .environmentObject(dependencyContainer.advocacyViewModel)
                .environmentObject(dependencyContainer.geospatialService)
                .environmentObject(dependencyContainer.notificationManager)
                .onAppear {
                    requestNotificationPermissions()
                }
        }
    }
    
    /// Request notification permissions on first launch
    private func requestNotificationPermissions() {
        Task {
            // Only request if not already determined
            if dependencyContainer.notificationManager.authorizationStatus == .notDetermined {
                // Wait a bit before asking (better UX)
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                _ = try? await dependencyContainer.notificationManager.requestAuthorization()
            }
        }
    }
}

