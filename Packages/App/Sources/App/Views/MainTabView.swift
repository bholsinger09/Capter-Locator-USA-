import SwiftUI
import Chapters
import Events
import Geospatial
import Advocacy

#if canImport(UIKit)
import UIKit
#endif

struct MainTabView: View {
    init() {
        #if os(iOS)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
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
            // Tab 1: Chapters
            ChaptersView()
                .tabItem {
                    Label("Chapters", systemImage: "building.2.fill")
                }
            
            // Tab 2: Events
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar.badge.clock")
                }
            
            // Tab 3: Nearby (Geospatial)
            LocationAnalyticsView()
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
            
            // Tab 4: Advocacy
            AdvocacyView()
                .tabItem {
                    Label("Advocacy", systemImage: "hand.raised.fill")
                }
            
            // Tab 5: More
            NavigationView {
                List {
                    NavigationLink(destination: UniversitiesView()) {
                        Label("Universities", systemImage: "graduationcap.fill")
                    }
                    
                    NavigationLink(destination: MembersView()) {
                        Label("Members", systemImage: "person.3.fill")
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.circle.fill")
                    }
                    
                    NavigationLink(destination: ContactDeveloperView()) {
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
