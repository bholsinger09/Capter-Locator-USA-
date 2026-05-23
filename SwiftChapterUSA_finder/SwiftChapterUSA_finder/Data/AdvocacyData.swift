//
//  AdvocacyData.swift
//  SwiftChapterUSA Finder
//

import Foundation

struct AdvocacyData {
    static let sampleDistricts: [AdvocacyDistrict] = [
        AdvocacyDistrict(
            state: "California",
            districtName: "CA-17",
            universities: ["Stanford University", "University of California, Berkeley", "University of California, San Jose State University"],
            officials: [
                ElectedOfficial(name: "Sen. California Senior", office: "U.S. Senator", chamber: "Senate", party: "Independent", state: "California", district: nil, phone: "202-224-3121", email: "senior.senator@senate.gov", website: "senate.gov"),
                ElectedOfficial(name: "Sen. California Junior", office: "U.S. Senator", chamber: "Senate", party: "Independent", state: "California", district: nil, phone: "202-224-3122", email: "junior.senator@senate.gov", website: "senate.gov"),
                ElectedOfficial(name: "Rep. California 17", office: "U.S. Representative", chamber: "House", party: "Republican", state: "California", district: "CA-17", phone: "202-225-1111", email: "ca17.rep@house.gov", website: "house.gov")
            ]
        ),
        AdvocacyDistrict(
            state: "Texas",
            districtName: "TX-10",
            universities: ["University of Texas at Austin", "Texas A&M University", "Rice University"],
            officials: [
                ElectedOfficial(name: "Sen. Texas Senior", office: "U.S. Senator", chamber: "Senate", party: "Republican", state: "Texas", district: nil, phone: "202-224-3123", email: "senior.tx@senate.gov", website: "senate.gov"),
                ElectedOfficial(name: "Sen. Texas Junior", office: "U.S. Senator", chamber: "Senate", party: "Republican", state: "Texas", district: nil, phone: "202-224-3124", email: "junior.tx@senate.gov", website: "senate.gov"),
                ElectedOfficial(name: "Rep. Texas 10", office: "U.S. Representative", chamber: "House", party: "Republican", state: "Texas", district: "TX-10", phone: "202-225-2222", email: "tx10.rep@house.gov", website: "house.gov")
            ]
        ),
        AdvocacyDistrict(
            state: "Florida",
            districtName: "FL-12",
            universities: ["University of Florida", "Florida State University", "University of Central Florida"],
            officials: [
                ElectedOfficial(name: "Sen. Florida Senior", office: "U.S. Senator", chamber: "Senate", party: "Republican", state: "Florida", district: nil, phone: "202-224-3125", email: "senior.fl@senate.gov", website: "senate.gov"),
                ElectedOfficial(name: "Sen. Florida Junior", office: "U.S. Senator", chamber: "Senate", party: "Republican", state: "Florida", district: nil, phone: "202-224-3126", email: "junior.fl@senate.gov", website: "senate.gov"),
                ElectedOfficial(name: "Rep. Florida 12", office: "U.S. Representative", chamber: "House", party: "Democrat", state: "Florida", district: "FL-12", phone: "202-225-3333", email: "fl12.rep@house.gov", website: "house.gov")
            ]
        )
    ]

    static let fallbackOfficials: [ElectedOfficial] = [
        ElectedOfficial(name: "Senior Senator", office: "U.S. Senator", chamber: "Senate", party: "Independent", state: "", district: nil, phone: "202-224-3000", email: "senior.senator@senate.gov", website: "senate.gov"),
        ElectedOfficial(name: "Junior Senator", office: "U.S. Senator", chamber: "Senate", party: "Independent", state: "", district: nil, phone: "202-224-3001", email: "junior.senator@senate.gov", website: "senate.gov"),
        ElectedOfficial(name: "U.S. Representative", office: "U.S. Representative", chamber: "House", party: "Independent", state: "", district: "District 1", phone: "202-225-3000", email: "representative@house.gov", website: "house.gov")
    ]

    static func officials(forState state: String, university: University?) -> [ElectedOfficial] {
        let selectedState = state.trimmingCharacters(in: .whitespacesAndNewlines)

        if let university = university,
           let districtData = sampleDistricts.first(where: { district in
               district.universities.contains(where: { universityName in
                   university.name.localizedCaseInsensitiveContains(universityName)
               })
           }) {
            return districtData.officials
        }

        if let stateData = sampleDistricts.first(where: { $0.state == selectedState }) {
            return stateData.officials
        }

        return fallbackOfficials.map { official in
            let districtName = official.district?.contains("District 1") == true ? "\(selectedState) District 1" : official.district
            return ElectedOfficial(
                name: official.name,
                office: official.office,
                chamber: official.chamber,
                party: official.party,
                state: selectedState.isEmpty ? "Unknown State" : selectedState,
                district: districtName,
                phone: official.phone,
                email: official.email,
                website: official.website
            )
        }
    }
}

struct AdvocacyDistrict: Identifiable, Codable {
    let id = UUID()
    let state: String
    let districtName: String
    let universities: [String]
    let officials: [ElectedOfficial]
}
