//
//  CongressServiceFallbackTests.swift
//  SwiftChapterUSA Finder Tests
//

import XCTest
@testable import SwiftChapterUSA_finder

final class CongressServiceFallbackTests: XCTestCase {
    struct MockUnavailableCongressService: CongressServiceProtocol {
        func fetchOfficials(forState state: String, university: University?) async throws -> [ElectedOfficial] {
            throw CongressServiceError.networkError(NSError(domain: "Mock", code: 410, userInfo: nil))
        }
    }

    private var chapterService: MockChapterService!
    private var viewModel: AdvocacyViewModel!

    override func setUp() {
        super.setUp()
        chapterService = MockChapterService()
        viewModel = AdvocacyViewModel(chapterService: chapterService, congressService: MockUnavailableCongressService())
    }

    override func tearDown() {
        chapterService = nil
        viewModel = nil
        super.tearDown()
    }

    func testFetchOfficialsFallsBackToLocalDataWhenCongressGovUnavailable() async {
        let university = University(name: "Stanford University", state: "California", city: "Stanford", hasChapter: true, studentPopulation: 17249, website: "stanford.edu")

        let results = await viewModel.fetchOfficials(for: "California", university: university)

        let expected = AdvocacyData.officials(forState: "California", university: university)

        XCTAssertEqual(results.count, expected.count)
        // Ensure at least one expected official is present in the fallback
        for official in expected {
            XCTAssertTrue(results.contains(where: { $0.name == official.name }))
        }
    }
}
