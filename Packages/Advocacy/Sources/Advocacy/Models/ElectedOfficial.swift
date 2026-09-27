//
//  ElectedOfficial.swift
//  Advocacy
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation

public struct ElectedOfficial: Identifiable, Codable, Hashable {
    public let id = UUID()
    public let name: String
    public let office: String
    public let chamber: String
    public let party: String
    public let state: String
    public let district: String?
    public let phone: String?
    public let email: String?
    public let website: String?

    public init(
        name: String,
        office: String,
        chamber: String,
        party: String,
        state: String,
        district: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil
    ) {
        self.name = name
        self.office = office
        self.chamber = chamber
        self.party = party
        self.state = state
        self.district = district
        self.phone = phone
        self.email = email
        self.website = website
    }

    public var displayTitle: String {
        if let district = district {
            return "\(office) • \(district)"
        }
        return office
    }

    public var locationText: String {
        if let district = district {
            return "\(district), \(state)"
        }
        return state
    }
}
