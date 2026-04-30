//
//  UniversitiesView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct UniversitiesView: View {
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var searchText = ""
    @State private var selectedState = "All States"
    @State private var showOnlyWithChapters = false
    
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
    
    var filteredUniversities: [University] {
        var universities = chapterManager.universities
        
        if selectedState != "All States" {
            universities = universities.filter { $0.state == selectedState }
        }
        
        if showOnlyWithChapters {
            universities = universities.filter { $0.hasChapter }
        }
        
        if !searchText.isEmpty {
            universities = universities.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText) ||
                $0.state.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return universities.sorted { $0.state < $1.state }
    }
    
    // Group universities by state
    var groupedUniversities: [String: [University]] {
        Dictionary(grouping: filteredUniversities) { $0.state }
    }
    
    var sortedStateKeys: [String] {
        groupedUniversities.keys.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search universities...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    HStack {
                        Picker("State", selection: $selectedState) {
                            ForEach(usStates, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Toggle("Has Chapter", isOn: $showOnlyWithChapters)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(white: 0.98))
                
                // University List
                if filteredUniversities.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "graduationcap")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No universities found")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sortedStateKeys, id: \.self) { state in
                            Section(header: Text(state).font(.headline)) {
                                ForEach(groupedUniversities[state] ?? []) { university in
                                    NavigationLink(destination: UniversityDetailView(university: university)) {
                                        UniversityRowView(university: university)
                                    }
                                }
                            }
                        }
                    }
                    #if os(iOS)
                    .listStyle(InsetGroupedListStyle())
                    #else
                    .listStyle(.inset)
                    #endif
                }
            }
            .navigationTitle("Universities")
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

struct UniversityRowView: View {
    let university: University
    
    var body: some View {
        HStack {
            Image(systemName: "graduationcap.fill")
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(university.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(university.displayLocation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if university.hasChapter {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UniversityDetailView: View {
    let university: University
    @EnvironmentObject var chapterManager: ChapterManager
    
    var associatedChapter: Chapter? {
        if let chapterId = university.chapterId {
            return chapterManager.chapters.first { $0.id == chapterId }
        }
        return chapterManager.chapters.first { $0.university == university.name }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if university.hasChapter {
                            VStack(alignment: .trailing) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("Has Chapter")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Text(university.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "location.fill")
                        Text(university.displayLocation)
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Student Population
                if let population = university.studentPopulation {
                    InfoSection(title: "Student Population", icon: "person.3.fill") {
                        Text("\(population.formatted()) students")
                            .font(.body)
                    }
                }
                
                // Website
                if let website = university.website {
                    InfoSection(title: "Website", icon: "globe") {
                        Link(website, destination: URL(string: "https://\(website)")!)
                            .foregroundColor(.blue)
                    }
                }
                
                // Associated Chapter
                if let chapter = associatedChapter {
                    InfoSection(title: "TPUSA Chapter", icon: "building.2.fill") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(chapter.displayName)
                                .font(.headline)
                            
                            Text(chapter.description)
                                .font(.body)
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
                } else {
                    InfoSection(title: "TPUSA Chapter", icon: "building.2.fill") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("No chapter at this university yet")
                                .foregroundColor(.secondary)
                            Text("Be the first to start a chapter here!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("University Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
