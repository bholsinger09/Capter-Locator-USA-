//
//  MembersView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct MembersView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    
    var userChapter: Chapter? {
        if let chapterId = authManager.currentUser?.chapterId {
            return chapterManager.chapters.first { $0.id == chapterId }
        } else if let userState = authManager.currentUser?.state {
            return chapterManager.chaptersInState(userState).first
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Welcome,")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(authManager.currentUser?.fullName ?? "Member")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Membership Status
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Membership Status")
                                .font(.headline)
                        }
                        
                        if authManager.currentUser?.isMember == true, let chapter = userChapter {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Active Member")
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Member of")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(chapter.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Not yet a member")
                                }
                                
                                Text("Select a chapter in your profile to become an active member!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Your Chapter
                    if let chapter = userChapter {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.blue)
                                Text("Your Chapter")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(chapter.displayName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("\(chapter.city), \(chapter.state)")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("\(chapter.memberCount) members")
                                }
                                .foregroundColor(.blue)
                                
                                NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                                    Text("View Chapter Details")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.blue)
                                Text("Find Your Chapter")
                                    .font(.headline)
                            }
                            
                            Text("You haven't joined a chapter yet. Select one in your profile!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let state = authManager.currentUser?.state {
                                let nearbyChapters = chapterManager.chaptersInState(state).prefix(3)
                                
                                if !nearbyChapters.isEmpty {
                                    Text("Chapters in \(state):")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.top, 5)
                                    
                                    ForEach(Array(nearbyChapters)) { chapter in
                                        NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(chapter.displayName)
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                    Text(chapter.city)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.blue)
                                            }
                                            .padding()
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            Button(action: {
                                // This will be handled by the sheet presentation
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Join a Chapter in Profile")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                    
                    // Member Resources
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                            Text("Member Resources")
                                .font(.headline)
                        }
                        
                        Link(destination: URL(string: "https://www.tpusa.com")!) {
                            ResourceLinkView(
                                icon: "link.circle.fill",
                                title: "Official TPUSA Website",
                                description: "Visit the official website"
                            )
                        }
                        
                        Link(destination: URL(string: "https://www.tpusa.com/chapters")!) {
                            ResourceLinkView(
                                icon: "building.2.fill",
                                title: "Official Chapter Resources",
                                description: "Access official chapter materials"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Members")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ResourceLinkView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}
