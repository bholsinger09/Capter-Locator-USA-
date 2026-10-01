//
//  SwiftChapterUSA_finderApp.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

@main
struct SwiftChapterUSA_finderApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestNotificationPermissions()
                }
        }
    }
    
    /// Request notification permissions on first launch
    private func requestNotificationPermissions() {
        Task {
            // Placeholder for notification permission handling
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
    }
}
