//
//  University.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

public struct University: Identifiable, Codable {
    public var id: UUID = UUID()
    public var name: String
    public var state: String
    public var city: String
    public var hasChapter: Bool
    public var chapterId: UUID?
    public var studentPopulation: Int?
    public var website: String?
    
    public var displayLocation: String {
        "\(city), \(state)"
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        state: String,
        city: String,
        hasChapter: Bool,
        chapterId: UUID? = nil,
        studentPopulation: Int? = nil,
        website: String? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.city = city
        self.hasChapter = hasChapter
        self.chapterId = chapterId
        self.studentPopulation = studentPopulation
        self.website = website
    }
}
