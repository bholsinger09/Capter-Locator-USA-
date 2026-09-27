//
//  Resource.swift
//  Resources
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation

public struct Resource: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var title: String
    public var description: String
    public var category: ResourceCategory
    public var type: ResourceType
    public var content: String
    public var imageURL: String?
    public var author: String?
    public var dateAdded: Date = Date()
    public var tags: [String] = []
    public var downloadCount: Int = 0
    public var isFeatured: Bool = false
    
    public enum ResourceCategory: String, Codable, CaseIterable {
        case talkingPoints = "Talking Points"
        case research = "Research & Statistics"
        case eventPlanning = "Event Planning"
        case recruitment = "Recruitment Materials"
        case socialMedia = "Social Media Graphics"
        case videos = "Videos & Speeches"
        case activism = "Activism Guides"
        case debate = "Debate Prep"
        case constitutionalLaw = "Constitutional Law"
        case economics = "Economics & Policy"
        
        public var icon: String {
            switch self {
            case .talkingPoints: return "text.bubble.fill"
            case .research: return "chart.bar.fill"
            case .eventPlanning: return "calendar.badge.plus"
            case .recruitment: return "person.2.fill"
            case .socialMedia: return "photo.fill"
            case .videos: return "play.circle.fill"
            case .activism: return "megaphone.fill"
            case .debate: return "quote.bubble.fill"
            case .constitutionalLaw: return "scroll.fill"
            case .economics: return "dollarsign.circle.fill"
            }
        }
    }
    
    public enum ResourceType: String, Codable {
        case article = "Article"
        case pdf = "PDF"
        case video = "Video"
        case image = "Image"
        case link = "External Link"
        case guide = "Guide"
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: ResourceCategory,
        type: ResourceType,
        content: String,
        imageURL: String? = nil,
        author: String? = nil,
        dateAdded: Date = Date(),
        tags: [String] = [],
        downloadCount: Int = 0,
        isFeatured: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.type = type
        self.content = content
        self.imageURL = imageURL
        self.author = author
        self.dateAdded = dateAdded
        self.tags = tags
        self.downloadCount = downloadCount
        self.isFeatured = isFeatured
    }
}

// MARK: - Sample Data
extension Resource {
    public static var samples: [Resource] {
        [
            Resource(
                title: "Free Speech on Campus",
                description: "Comprehensive guide to understanding and defending First Amendment rights.",
                category: .talkingPoints,
                type: .guide,
                content: "Guide to free speech rights on campus...",
                tags: ["first amendment", "free speech", "campus rights"],
                isFeatured: true
            ),
            Resource(
                title: "Economic Freedom Statistics",
                description: "Data comparing economic freedom and prosperity across systems.",
                category: .research,
                type: .article,
                content: "Economic freedom improves quality of life...",
                tags: ["economics", "data", "prosperity"],
                isFeatured: true
            )
        ]
    }
}
