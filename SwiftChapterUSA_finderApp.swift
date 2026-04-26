//
//  SwiftChapterUSA_finderApp.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

@main
struct SwiftChapterUSA_finderApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var chapterManager = ChapterManager()
    @StateObject private var eventManager = EventManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(chapterManager)
                .environmentObject(eventManager)
        }
    }
}
