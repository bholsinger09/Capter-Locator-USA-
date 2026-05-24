//
//  ElectedOfficial.swift
//  SwiftChapterUSA Finder
//

import Foundation

struct ElectedOfficial: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let office: String
    let chamber: String
    let party: String
    let state: String
    let district: String?
    let phone: String?
    let email: String?
    let website: String?

    private enum CodingKeys: String, CodingKey {
        case name, office, chamber, party, state, district, phone, email, website
    }

    var displayTitle: String {
        if let district = district {
            return "\(office) • \(district)"
        }
        return office
    }

    var locationText: String {
        if let district = district {
            return "\(district), \(state)"
        }
        return state
    }
}
