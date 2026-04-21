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
    }
}
