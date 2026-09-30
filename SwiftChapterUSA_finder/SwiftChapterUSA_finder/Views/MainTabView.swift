import SwiftUI
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
            Text("Chapters View")
                .tabItem {
                    Label("Chapters", systemImage: "building.2.fill")
                }
            
            Text("Events View")
                .tabItem {
                    Label("Events", systemImage: "calendar.badge.clock")
                }
            
            Text("Nearby View")
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
            
            Text("Advocacy View")
                .tabItem {
                    Label("Advocacy", systemImage: "hand.raised.fill")
                }
            
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
