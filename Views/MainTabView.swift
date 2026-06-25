//
//  MainTabView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var eventManager: EventManager
    @StateObject private var geospatialService = GeospatialService()
    @StateObject private var locationViewModel: LocationViewModel
    
    init() {
        let geospatialService = GeospatialService()
        _geospatialService = StateObject(wrappedValue: geospatialService)
        _locationViewModel = StateObject(wrappedValue: LocationViewModel(geospatialService: geospatialService))
    }
    
    var body: some View {
        TabView {
            ChaptersView()
                .tabItem {
                    Label("Chapters", systemImage: "building.2.fill")
                }
            
            EventsView(eventManager: eventManager, authManager: authManager)
                .tabItem {
                    Label("Events", systemImage: "calendar.badge.clock")
                }
            
            NearbyChaptersView(viewModel: locationViewModel)
                .environmentObject(authManager)
                .environmentObject(chapterManager)
                .environmentObject(eventManager)
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
            
            LocationAnalyticsView(viewModel: locationViewModel)
                .environmentObject(chapterManager)
                .environmentObject(eventManager)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
            
            AdvocacyView(viewModel: AdvocacyViewModel(chapterService: chapterManager))
                .tabItem {
                    Label("Advocacy", systemImage: "hand.raised.fill")
                }
            
            // More tab for secondary features
            NavigationView {
                List {
                    NavigationLink(destination: UniversitiesView()) {
                        Label("Universities", systemImage: "graduationcap.fill")
                    }
                    
                    NavigationLink(destination: FreeSpeechHubView()) {
                        Label("Free Speech", systemImage: "megaphone.fill")
                    }
                    
                    NavigationLink(destination: MembersView()) {
                        Label("Members", systemImage: "person.3.fill")
                    }
                    
                    NavigationLink(destination: ResourceLibraryView()) {
                        Label("Resources", systemImage: "books.vertical.fill")
                    }
                    
                    NavigationLink(destination: BlogView()) {
                        Label("Blog", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    
                    NavigationLink(destination: ContactDeveloperView()) {
                        Label("Contact", systemImage: "envelope.fill")
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.circle.fill")
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
