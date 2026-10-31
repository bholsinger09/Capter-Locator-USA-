//
//  AdvocacyData.swift
//  Advocacy
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation
import Common
import Chapters

public struct AdvocacyData {
    // Load chapter representatives from chapters-data.json
    public static func officials(forState state: String, university: University? = nil) -> [ElectedOfficial] {
        if state == "All States" {
            return []
        }
        
        // Load data from ChaptersDataLoader
        let chapterContact = ChaptersDataLoader.shared.getChapterContact(forState: state)
        
        guard let contact = chapterContact else {
            return []
        }
        
        // Convert ChapterContactInfo to ElectedOfficial
        let official = ElectedOfficial(
            name: contact.presidentName,
            office: contact.title ?? "State Representative",
            chamber: "Local",
            party: "Independent",
            state: state,
            district: nil,
            phone: nil,
            email: contact.contactEmail,
            website: contact.linkedIn
        )
        
        return [official]
    }
}
