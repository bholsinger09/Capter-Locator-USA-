//
//  MainTabView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
import Chapters
import Events
import Geospatial
import Advocacy
import AppUI
#if canImport(UIKit)
import UIKit
#endif

struct MainTabView: View {
    let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
        
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
            // Tab 1: Chapters (from Chapters package)
            ChaptersView(container: container)
                .tabItem {
                    Label("Chapters", systemImage: "building.2.fill")
                }
            
            // Tab 2: Events (from Events package)
            EventsView(container: container)
                .tabItem {
                    Label("Events", systemImage: "calendar.badge.clock")
                }
            
            // Tab 3: Geospatial (from Geospatial package)
            LocationAnalyticsView(container: container)
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
            
            // Tab 4: Advocacy (from Advocacy package)
            AdvocacyView(container: container)
                .tabItem {
                    Label("Advocacy", systemImage: "hand.raised.fill")
                }
            
            // Tab 5: More (monolithic views via container pattern)
            NavigationView {
                List {
                    NavigationLink(destination: UniversitiesView(container: container)) {
                        Label("Universities", systemImage: "graduationcap.fill")
                    }
                    
                    NavigationLink(destination: MembersView(container: container)) {
                        Label("Members", systemImage: "person.3.fill")
                    }
                    
                    NavigationLink(destination: ProfileView(container: container)) {
                        Label("Profile", systemImage: "person.circle.fill")
                    }
                    
                    NavigationLink(destination: ContactDeveloperView(container: container)) {
                        Label("Contact", systemImage: "envelope.fill")
                    }
                }
                .navigationTitle("More")
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
        }
        .accentColor(.blue)
    }
}
