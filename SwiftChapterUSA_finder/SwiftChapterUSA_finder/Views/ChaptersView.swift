//
//  ChaptersView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct ChaptersView: View {
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var searchText = ""
    @State private var selectedState = "All States"
    @State private var showingCreateChapter = false
    
    let usStates = ["All States", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming"]
    
    var filteredChapters: [Chapter] {
        var chapters = chapterManager.chapters
        
        if selectedState != "All States" {
            chapters = chapters.filter { $0.state == selectedState }
        }
        
        if !searchText.isEmpty {
            chapters = chapters.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText) ||
                $0.state.localizedCaseInsensitiveContains(searchText) ||
                ($0.university?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return chapters.sorted { $0.state < $1.state }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search chapters...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Picker("State", selection: $selectedState) {
                        ForEach(usStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(white: 0.98))
                
                // Chapter List
                if filteredChapters.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No chapters found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Try adjusting your search or create a new chapter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredChapters) { chapter in
                            NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                                ChapterRowView(chapter: chapter)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Chapters")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingCreateChapter = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingCreateChapter = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingCreateChapter) {
                CreateChapterView()
            }
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

struct ChapterRowView: View {
    let chapter: Chapter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.displayName)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text("\(chapter.city), \(chapter.state)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(chapter.memberCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            if let university = chapter.university {
                Text(university)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(5)
            }
        }
        .padding(.vertical, 4)
    }
}
