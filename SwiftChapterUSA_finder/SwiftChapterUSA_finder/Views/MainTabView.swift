//
//  MainTabView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var eventManager: EventManager
    
    init() {
        #if os(iOS)
        // Configure tab bar appearance for better contrast in both light and dark modes
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Selected tab - bright blue (works well in both modes)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        // Unselected tab - adaptive gray with good contrast
        // Uses lighter gray in dark mode, darker gray in light mode
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        #endif
    }
    
    var body: some View {
        TabView {
            ChaptersView()
                .tabItem {
                    Label("Chapters", systemImage: "building.2.fill")
                }
            
            UniversitiesView()
                .tabItem {
                    Label("Universities", systemImage: "graduationcap.fill")
                }
            
            EventsView(eventManager: eventManager, authManager: authManager)
                .tabItem {
                    Label("Events", systemImage: "calendar.badge.clock")
                }
            
            FreeSpeechHubView()
                .tabItem {
                    Label("Free Speech", systemImage: "megaphone.fill")
                }
            
            MembersView()
                .tabItem {
                    Label("Members", systemImage: "person.3.fill")
                }
            
            ResourceLibraryView()
                .tabItem {
                    Label("Resources", systemImage: "books.vertical.fill")
                }
            
            BlogView()
                .tabItem {
                    Label("Blog", systemImage: "bubble.left.and.bubble.right.fill")
                }
            
            ContactDeveloperView()
                .tabItem {
                    Label("Contact", systemImage: "envelope.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .accentColor(.blue)
    }
}
