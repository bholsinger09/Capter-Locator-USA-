//
//  AdvocacyViewModelTests.swift
//  SwiftChapterUSA Finder Tests
//

import XCTest
@testable import SwiftChapterUSA_finder

final class AdvocacyViewModelTests: XCTestCase {
    private var chapterService: MockChapterService!
    private var viewModel: AdvocacyViewModel!

    override func setUp() {
        super.setUp()
        chapterService = MockChapterService()
        viewModel = AdvocacyViewModel(chapterService: chapterService)
    }

    override func tearDown() {
        chapterService = nil
        viewModel = nil
        super.tearDown()
    }

    func testFilteredUniversities_AllStatesReturnsAllItems() {
        let universities = viewModel.filteredUniversities(state: "All States", query: "")

        XCTAssertEqual(universities.count, 3)
        XCTAssertTrue(universities.contains(where: { $0.name == "UCLA" }))
        XCTAssertTrue(universities.contains(where: { $0.name == "UT Austin" }))
        XCTAssertTrue(universities.contains(where: { $0.name == "MIT" }))
    }

    func testFilteredUniversities_StateFilterReturnsOnlySelectedState() {
        let universities = viewModel.filteredUniversities(state: "Texas", query: "")

        XCTAssertEqual(universities.count, 1)
        XCTAssertEqual(universities.first?.name, "UT Austin")
    }

    func testElectedOfficialsForKnownUniversityReturnsDistrictOfficials() {
        let university = University(name: "Stanford University", state: "California", city: "Stanford", hasChapter: true, studentPopulation: 17249, website: "stanford.edu")
        let officials = viewModel.electedOfficials(for: "California", university: university)

        XCTAssertEqual(officials.count, 3)
        XCTAssertTrue(officials.contains(where: { $0.office == "U.S. Representative" && $0.district == "CA-17" }))
        XCTAssertTrue(officials.contains(where: { $0.office == "U.S. Senator" }))
    }

    func testEmailSubjectIncludesDistrictForHouseOfficial() {
        let official = ElectedOfficial(name: "Rep. California 17", office: "U.S. Representative", chamber: "House", party: "Republican", state: "California", district: "CA-17", phone: "202-225-1111", email: "ca17.rep@house.gov", website: "house.gov")
        let subject = viewModel.emailSubject(for: .chapterSupport, official: official)

        XCTAssertEqual(subject, "Request support for our TPUSA chapter — CA-17")
    }

    func testEmailBodyContainsUserAndCampusInformation() {
        let user = User(email: "student@example.com", firstName: "Test", lastName: "Student", state: "California", university: "Stanford University")
        let university = University(name: "Stanford University", state: "California", city: "Stanford", hasChapter: true, studentPopulation: 17249, website: "stanford.edu")
        let official = ElectedOfficial(name: "Rep. California 17", office: "U.S. Representative", chamber: "House", party: "Republican", state: "California", district: "CA-17", phone: "202-225-1111", email: "ca17.rep@house.gov", website: "house.gov")

        let body = viewModel.emailBody(for: .campusFreeSpeech, user: user, university: university, official: official)

        XCTAssertTrue(body.contains("Dear Rep. California 17,"))
        XCTAssertTrue(body.contains("Stanford University"))
        XCTAssertTrue(body.contains("I am a student and member of TPUSA"))
    }

    func testMakeMailURLEncodesSubjectAndBody() {
        let email = "test@example.com"
        let subject = "Campus Free Speech"
        let body = "Please support our campus chapter."

        let url = viewModel.makeMailURL(to: email, subject: subject, body: body)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "mailto")
        XCTAssertTrue(url?.absoluteString.contains("subject=Campus%20Free%20Speech") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("body=Please%20support%20our%20campus%20chapter.") ?? false)
    }
}
