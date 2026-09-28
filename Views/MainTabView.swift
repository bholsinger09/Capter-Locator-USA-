//
//  MainTabView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
import App
import Chapters
import Events
import Geospatial
import Advocacy
import Resources
import Notifications

struct MainTabView: View {
    // Package services and ViewModels
    @EnvironmentObject var chaptersViewModel: ChaptersViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var advocacyViewModel: AdvocacyViewModel
    @EnvironmentObject var geospatialService: GeospatialService
    
    let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    var body: some View {
        TabView {
            // Chapters Tab - from Chapters package
            ChaptersView()
                .tabItem {
                    Label("Chapters", systemImage: "building.2.fill")
                }
            
            // Events Tab - from Events package
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar.badge.clock")
                }
            
            // Geospatial Tab - from Geospatial package
            LocationAnalyticsView()
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
            
            // Advocacy Tab - from Advocacy package
            AdvocacyView()
                .tabItem {
                    Label("Advocacy", systemImage: "hand.raised.fill")
                }
            
            // More tab for secondary features
            NavigationView {
                List {
                    NavigationLink(destination: ResourceLibraryView()) {
                        Label("Resources", systemImage: "books.vertical.fill")
                    }
                    
                    NavigationLink(destination: UniversitiesView()) {
                        Label("Universities", systemImage: "graduationcap.fill")
                    }
                    
                    NavigationLink(destination: MembersView()) {
                        Label("Members", systemImage: "person.3.fill")
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.circle.fill")
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }
                .navigationTitle("More")
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
        }
    }
}
