//
//  ChaptersViewModel.swift
//  Chapters
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation
import Combine
import Common

public class ChaptersViewModel: ObservableObject {
    @Published public var chapters: [Chapter] = []
    @Published public var universities: [University] = []
    @Published public var searchText: String = ""
    @Published public var selectedState: String = "All States"
    @Published public var filterByDistance: Bool = false
    @Published public var userLocation: (latitude: Double, longitude: Double)?
    
    public init() {
        loadData()
    }
    
    public var filteredChapters: [Chapter] {
        var filtered = chapters
        
        if selectedState != "All States" {
            filtered = filtered.filter { $0.state == selectedState }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { chapter in
                chapter.name.localizedCaseInsensitiveContains(searchText) ||
                chapter.city.localizedCaseInsensitiveContains(searchText) ||
                (chapter.university?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    public var stateOptions: [String] {
        let states = Set(chapters.map { $0.state })
        return ["All States"] + states.sorted()
    }
    
    public func loadData() {
        chapters = Chapter.samples
    }
    
    public func addChapter(_ chapter: Chapter) {
        chapters.append(chapter)
    }
    
    public func updateChapter(_ chapter: Chapter) {
        if let index = chapters.firstIndex(where: { $0.id == chapter.id }) {
            chapters[index] = chapter
        }
    }
}

// MARK: - Sample Data
extension Chapter {
    public static var samples: [Chapter] {
        [
            Chapter(
                name: "UCLA Chapter",
                state: "California",
                city: "Los Angeles",
                university: "UCLA",
                presidentName: "John Smith",
                contactEmail: "ucla@tpusa.org",
                description: "Largest chapter in California",
                memberCount: 150,
                dateEstablished: Date()
            ),
            Chapter(
                name: "UT Austin Chapter",
                state: "Texas",
                city: "Austin",
                university: "University of Texas",
                presidentName: "Sarah Jones",
                contactEmail: "utaustin@tpusa.org",
                description: "Active chapter in the heart of Texas",
                memberCount: 200,
                dateEstablished: Date()
            )
        ]
    }
}
