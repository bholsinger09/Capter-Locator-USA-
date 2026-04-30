//
//  ChapterDetailView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct ChapterDetailView: View {
    let chapter: Chapter
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("\(chapter.memberCount) members")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            
                            if chapter.isActive {
                                Text("Active")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    
                    Text(chapter.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "location.fill")
                        Text("\(chapter.city), \(chapter.state)")
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // University Info
                if let university = chapter.university {
                    InfoSection(title: "University", icon: "graduationcap.fill") {
                        Text(university)
                            .font(.body)
                    }
                }
                
                // Description
                InfoSection(title: "About", icon: "info.circle.fill") {
                    Text(chapter.description)
                        .font(.body)
                }
                
                // Contact Information
                InfoSection(title: "Contact", icon: "person.fill") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("President:")
                                .fontWeight(.semibold)
                            Text(chapter.presidentName)
                        }
                    }
                }
                
                // State Coordinator
                if let coordinatorName = chapter.stateCoordinatorName {
                    InfoSection(title: "State Coordinator", icon: "person.badge.shield.checkmark.fill") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(coordinatorName)
                                .fontWeight(.semibold)
                            
                            if let linkedIn = chapter.stateCoordinatorLinkedIn {
                                Link(destination: URL(string: linkedIn)!) {
                                    HStack {
                                        Image(systemName: "link.circle.fill")
                                        Text("View LinkedIn Profile")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            
                            Text("Search LinkedIn for more information")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                
                // Meeting Information
                if let location = chapter.meetingLocation, let schedule = chapter.meetingSchedule {
                    InfoSection(title: "Meetings", icon: "calendar") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                Text(location)
                            }
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                Text(schedule)
                            }
                        }
                    }
                }
                
                // Established Date
                InfoSection(title: "Established", icon: "flag.fill") {
                    Text(chapter.dateEstablished.formatted(date: .long, time: .omitted))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Chapter Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            content
                .padding(.leading, 28)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}
