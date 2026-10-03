import XCTest
@testable import App

final class PoliticalPartyTests: XCTestCase {
    
    // MARK: - Party Data Integrity Tests
    
    func testPoliticalPartiesExist() {
        let parties = PoliticalPartyGuidance.parties
        XCTAssertEqual(parties.count, 5, "Should have exactly 5 political parties")
    }
    
    func testPartyNamesAreUnique() {
        let parties = PoliticalPartyGuidance.parties
        let names = parties.map { $0.name }
        let uniqueNames = Set(names)
        XCTAssertEqual(names.count, uniqueNames.count, "Party names should be unique")
    }
    
    func testPartyEmojisArePresent() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.emoji.isEmpty, "\(party.name) should have an emoji")
        }
    }
    
    func testPartyColorsArePresent() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.color.isEmpty, "\(party.name) should have a color")
        }
    }
    
    func testPartyTaglinesArePresent() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.tagline.isEmpty, "\(party.name) should have a tagline")
        }
    }
    
    func testPartyCoreValuesAreDefined() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertGreaterThan(party.coreValues.count, 0, "\(party.name) should have core values")
            for value in party.coreValues {
                XCTAssertFalse(value.isEmpty, "\(party.name) core values should not be empty")
            }
        }
    }
    
    func testPartyEconomicApproachIsDefined() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.economicApproach.isEmpty, "\(party.name) should have economic approach")
            XCTAssertGreaterThan(party.economicApproach.count, 10, "\(party.name) economic approach should be substantive")
        }
    }
    
    func testPartySocialApproachIsDefined() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.socialApproach.isEmpty, "\(party.name) should have social approach")
            XCTAssertGreaterThan(party.socialApproach.count, 10, "\(party.name) social approach should be substantive")
        }
    }
    
    func testPartyEnvironmentalApproachIsDefined() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.environmentalApproach.isEmpty, "\(party.name) should have environmental approach")
            XCTAssertGreaterThan(party.environmentalApproach.count, 10, "\(party.name) environmental approach should be substantive")
        }
    }
    
    func testPartyDescriptionsAreDefined() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertFalse(party.description.isEmpty, "\(party.name) should have a description")
            XCTAssertGreaterThan(party.description.count, 20, "\(party.name) description should be detailed")
        }
    }
    
    // MARK: - Party Name Tests
    
    func testDemocraticPartyExists() {
        let democratic = PoliticalPartyGuidance.parties.first { $0.name == "Democratic Party" }
        XCTAssertNotNil(democratic, "Democratic Party should exist")
        XCTAssertEqual(democratic?.emoji, "🔵", "Democratic Party should have blue circle emoji")
    }
    
    func testRepublicanPartyExists() {
        let republican = PoliticalPartyGuidance.parties.first { $0.name == "Republican Party" }
        XCTAssertNotNil(republican, "Republican Party should exist")
        XCTAssertEqual(republican?.emoji, "🔴", "Republican Party should have red circle emoji")
    }
    
    func testLibertarianPartyExists() {
        let libertarian = PoliticalPartyGuidance.parties.first { $0.name == "Libertarian Party" }
        XCTAssertNotNil(libertarian, "Libertarian Party should exist")
        XCTAssertEqual(libertarian?.emoji, "🟡", "Libertarian Party should have yellow circle emoji")
    }
    
    func testGreenPartyExists() {
        let green = PoliticalPartyGuidance.parties.first { $0.name == "Green Party" }
        XCTAssertNotNil(green, "Green Party should exist")
        XCTAssertEqual(green?.emoji, "🟢", "Green Party should have green circle emoji")
    }
    
    func testIndependentPartyExists() {
        let independent = PoliticalPartyGuidance.parties.first { $0.name == "Independent / No Affiliation" }
        XCTAssertNotNil(independent, "Independent / No Affiliation should exist")
        XCTAssertEqual(independent?.emoji, "⚪", "Independent should have white circle emoji")
    }
    
    // MARK: - Specific Party Content Tests
    
    func testDemocraticPartyContent() {
        guard let democratic = PoliticalPartyGuidance.parties.first(where: { $0.name == "Democratic Party" }) else {
            XCTFail("Democratic Party not found")
            return
        }
        
        XCTAssertEqual(democratic.color, "blue")
        XCTAssertEqual(democratic.tagline, "Progress, Equality, Community")
        XCTAssertTrue(democratic.coreValues.contains("Social equality"))
        XCTAssertTrue(democratic.economicApproach.contains("progressive taxation"))
        XCTAssertTrue(democratic.socialApproach.contains("civil rights"))
    }
    
    func testRepublicanPartyContent() {
        guard let republican = PoliticalPartyGuidance.parties.first(where: { $0.name == "Republican Party" }) else {
            XCTFail("Republican Party not found")
            return
        }
        
        XCTAssertEqual(republican.color, "red")
        XCTAssertEqual(republican.tagline, "Liberty, Limited Government, Tradition")
        XCTAssertTrue(republican.coreValues.contains("Individual liberty"))
        XCTAssertTrue(republican.economicApproach.contains("free market"))
    }
    
    func testLibertarianPartyContent() {
        guard let libertarian = PoliticalPartyGuidance.parties.first(where: { $0.name == "Libertarian Party" }) else {
            XCTFail("Libertarian Party not found")
            return
        }
        
        XCTAssertEqual(libertarian.color, "yellow")
        XCTAssertTrue(libertarian.coreValues.contains("Individual liberty"))
        XCTAssertTrue(libertarian.coreValues.contains("Non-aggression principle"))
    }
    
    func testGreenPartyContent() {
        guard let green = PoliticalPartyGuidance.parties.first(where: { $0.name == "Green Party" }) else {
            XCTFail("Green Party not found")
            return
        }
        
        XCTAssertEqual(green.color, "green")
        XCTAssertTrue(green.coreValues.contains("Environmental sustainability"))
        XCTAssertTrue(green.socialApproach.contains("progressive"))
    }
    
    func testIndependentContent() {
        guard let independent = PoliticalPartyGuidance.parties.first(where: { $0.name == "Independent / No Affiliation" }) else {
            XCTFail("Independent not found")
            return
        }
        
        XCTAssertEqual(independent.color, "gray")
        XCTAssertTrue(independent.coreValues.contains("Critical thinking"))
        XCTAssertTrue(independent.description.contains("pragmatism"))
    }
    
    // MARK: - Codable Tests
    
    func testPoliticalPartyIsCodable() {
        let party = PoliticalPartyGuidance.parties[0]
        
        // Encode
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(party)
        XCTAssertNotNil(encoded, "Party should be encodable")
        
        // Decode
        if let encoded = encoded {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(PoliticalParty.self, from: encoded)
            XCTAssertNotNil(decoded, "Party should be decodable")
            XCTAssertEqual(decoded?.name, party.name, "Decoded party should have same name")
        }
    }
    
    func testAllPartiesAreCodable() {
        let parties = PoliticalPartyGuidance.parties
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for party in parties {
            let encoded = try? encoder.encode(party)
            XCTAssertNotNil(encoded, "\(party.name) should be encodable")
            
            if let encoded = encoded {
                let decoded = try? decoder.decode(PoliticalParty.self, from: encoded)
                XCTAssertNotNil(decoded, "\(party.name) should be decodable")
                XCTAssertEqual(decoded?.name, party.name)
                XCTAssertEqual(decoded?.emoji, party.emoji)
                XCTAssertEqual(decoded?.color, party.color)
            }
        }
    }
    
    // MARK: - LifePathCategory Politics Tests
    
    func testPoliticsLifePathCategoryExists() {
        let politicsCategory = LifePathCategory.politics
        XCTAssertEqual(politicsCategory.rawValue, "politics")
    }
    
    func testPoliticsEmoji() {
        let politicsCategory = LifePathCategory.politics
        XCTAssertEqual(politicsCategory.emoji, "🗳️")
    }
    
    func testPoliticsTitle() {
        let politicsCategory = LifePathCategory.politics
        XCTAssertEqual(politicsCategory.title, "Choose My Political Party")
    }
    
    func testPoliticsDescription() {
        let politicsCategory = LifePathCategory.politics
        XCTAssertTrue(politicsCategory.description.contains("political"))
        XCTAssertFalse(politicsCategory.description.isEmpty)
    }
    
    // MARK: - AllCases Tests
    
    func testLifePathCategoryAllCasesIncludesPolitics() {
        let allCases = LifePathCategory.allCases
        let hasPolitics = allCases.contains { $0 == .politics }
        XCTAssertTrue(hasPolitics, "LifePathCategory.allCases should include politics")
    }
    
    func testLifePathCategoryAllCasesCount() {
        let allCases = LifePathCategory.allCases
        XCTAssertEqual(allCases.count, 8, "Should have 8 life path categories (including politics)")
    }
    
    // MARK: - Data Quality Tests
    
    func testNoCoreValueDuplicatesWithinParty() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            let values = party.coreValues
            let uniqueValues = Set(values)
            XCTAssertEqual(values.count, uniqueValues.count, "\(party.name) should not have duplicate core values")
        }
    }
    
    func testPartyIDsAreUnique() {
        let parties = PoliticalPartyGuidance.parties
        let ids = parties.map { $0.id }
        
        // Check that we can distinguish parties by id
        XCTAssertEqual(ids.count, Set(ids).count, "All party IDs should be unique")
    }
    
    func testPartiesHaveMinimumThreeValues() {
        let parties = PoliticalPartyGuidance.parties
        for party in parties {
            XCTAssertGreaterThanOrEqual(party.coreValues.count, 3, "\(party.name) should have at least 3 core values")
        }
    }
}
