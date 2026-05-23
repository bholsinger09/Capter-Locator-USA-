//
//  University.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

struct University: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var state: String
    var city: String
    var hasChapter: Bool
    var chapterId: UUID?
    var studentPopulation: Int?
    var website: String?
    
    var displayLocation: String {
        "\(city), \(state)"
    }
}
