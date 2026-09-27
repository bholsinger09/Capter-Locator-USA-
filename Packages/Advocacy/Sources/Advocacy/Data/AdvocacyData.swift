//
//  AdvocacyData.swift
//  Advocacy
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation
import Common

public struct AdvocacyData {
    // Mock official data by state - in production, this would be fetched from a service
    public static func officials(forState state: String, university: University? = nil) -> [ElectedOfficial] {
        let mockOfficials: [String: [ElectedOfficial]] = [
            "California": [
                ElectedOfficial(name: "Dianne Feinstein", office: "U.S. Senator", chamber: "Senate", party: "Democratic", state: "California", email: "senator@feinstein.senate.gov"),
                ElectedOfficial(name: "Alex Padilla", office: "U.S. Senator", chamber: "Senate", party: "Democratic", state: "California", email: "senator@padilla.senate.gov"),
            ],
            "Texas": [
                ElectedOfficial(name: "Ted Cruz", office: "U.S. Senator", chamber: "Senate", party: "Republican", state: "Texas", email: "senator@cruz.senate.gov"),
                ElectedOfficial(name: "John Cornyn", office: "U.S. Senator", chamber: "Senate", party: "Republican", state: "Texas", email: "senator@cornyn.senate.gov"),
            ],
            "New York": [
                ElectedOfficial(name: "Chuck Schumer", office: "U.S. Senator", chamber: "Senate", party: "Democratic", state: "New York", email: "senator@schumer.senate.gov"),
                ElectedOfficial(name: "Kirsten Gillibrand", office: "U.S. Senator", chamber: "Senate", party: "Democratic", state: "New York", email: "senator@gillibrand.senate.gov"),
            ]
        ]
        
        return mockOfficials[state] ?? []
    }
}
