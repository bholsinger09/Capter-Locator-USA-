import XCTest
@testable import Chapters
import Common

final class PaginationTests: XCTestCase {
    var viewModel: ChaptersViewModel!
    var mockCacheService: MockCacheService!
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockCacheService()
        viewModel = ChaptersViewModel(cacheService: mockCacheService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockCacheService = nil
        super.tearDown()
    }
    
    // MARK: - Initial Load Tests
    func testInitialPageIsOne() {
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testItemsPerPageDefaultIsTwenty() {
        XCTAssertEqual(viewModel.itemsPerPage, 20)
    }
    
    func testInitialLoadShowsFirstTwentyItems() async {
        await viewModel.loadChapters()
        
        // Set up enough chapters for pagination testing
        viewModel.chapters = Chapter.generateSamples(count: 50)
        
        let paginated = viewModel.paginatedChapters
        XCTAssertEqual(paginated.count, 20)
    }
    
    // MARK: - Pagination Logic Tests
    func testPaginatedChaptersReturnsCorrectItemsForPage() async {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        let page1 = viewModel.paginatedChapters
        XCTAssertEqual(page1.count, 20)
        
        viewModel.currentPage = 2
        let page2 = viewModel.paginatedChapters
        XCTAssertEqual(page2.count, 20)
        
        viewModel.currentPage = 3
        let page3 = viewModel.paginatedChapters
        XCTAssertEqual(page3.count, 10) // Only 10 left
    }
    
    func testLoadNextPageIncrementsCurrentPage() async {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.currentPage = 1
        
        await viewModel.loadNextPage()
        
        XCTAssertEqual(viewModel.currentPage, 2)
    }
    
    func testLoadNextPageDoesNotExceedMaxPages() async {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.currentPage = 3
        viewModel.itemsPerPage = 20
        
        await viewModel.loadNextPage()
        
        XCTAssertEqual(viewModel.currentPage, 3) // Should stay at 3
    }
    
    func testHasMoreDataReturnsTrueWhenMoreDataExists() {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        XCTAssertTrue(viewModel.hasMoreData)
    }
    
    func testHasMoreDataReturnsFalseOnLastPage() {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.currentPage = 3
        viewModel.itemsPerPage = 20
        
        XCTAssertFalse(viewModel.hasMoreData)
    }
    
    func testHasMoreDataReturnsFalseWhenFewerItemsThanPerPage() {
        viewModel.chapters = Chapter.generateSamples(count: 10)
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        XCTAssertFalse(viewModel.hasMoreData)
    }
    
    func testTotalPageCountCalculation() {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.itemsPerPage = 20
        
        XCTAssertEqual(viewModel.totalPages, 3)
    }
    
    func testTotalPageCountWithExactDivision() {
        viewModel.chapters = Chapter.generateSamples(count: 40)
        viewModel.itemsPerPage = 20
        
        XCTAssertEqual(viewModel.totalPages, 2)
    }
    
    // MARK: - Empty and Edge Cases
    func testPaginationWithEmptyChapters() {
        viewModel.chapters = []
        viewModel.currentPage = 1
        
        let paginated = viewModel.paginatedChapters
        XCTAssertEqual(paginated.count, 0)
    }
    
    func testHasMoreDataReturnsFalseWithEmptyChapters() {
        viewModel.chapters = []
        viewModel.currentPage = 1
        
        XCTAssertFalse(viewModel.hasMoreData)
    }
    
    func testResetPaginationReturnsToPageOne() {
        viewModel.currentPage = 3
        
        viewModel.resetPagination()
        
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    // MARK: - Pagination State Persistence Tests
    func testPaginationStatePersistsInCache() async {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.currentPage = 2
        viewModel.itemsPerPage = 20
        
        await viewModel.savePaginationState()
        
        // Create new view model and verify it loads the saved state
        let newViewModel = ChaptersViewModel(cacheService: mockCacheService)
        let success = await newViewModel.loadPaginationState()
        
        XCTAssertTrue(success)
    }
    
    func testLoadPaginationStateReturnsFalseIfNotSaved() async {
        let success = await viewModel.loadPaginationState()
        
        XCTAssertFalse(success)
    }
    
    // MARK: - Multiple Load Tests
    func testMultipleConsecutivePageLoads() async {
        viewModel.chapters = Chapter.generateSamples(count: 100)
        
        let page1 = viewModel.paginatedChapters
        XCTAssertEqual(page1.count, 20)
        
        await viewModel.loadNextPage()
        let page2 = viewModel.paginatedChapters
        XCTAssertEqual(page2.count, 20)
        
        await viewModel.loadNextPage()
        let page3 = viewModel.paginatedChapters
        XCTAssertEqual(page3.count, 20)
    }
    
    func testPaginationWorksWithFilteredResults() {
        viewModel.chapters = Chapter.generateSamples(count: 50)
        viewModel.selectedState = "California"
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        let filtered = viewModel.filteredChapters
        let paginated = viewModel.paginatedChaptersFromFiltered
        
        // Verify pagination applies to filtered results
        if filtered.count > 0 {
            XCTAssertLessThanOrEqual(paginated.count, viewModel.itemsPerPage)
        }
    }
}

// MARK: - Sample Data Generator
extension Chapter {
    static func generateSamples(count: Int) -> [Chapter] {
        var chapters: [Chapter] = []
        let states = ["California", "Texas", "New York", "Florida", "Illinois"]
        
        for i in 0..<count {
            let state = states[i % states.count]
            let chapter = Chapter(
                name: "Chapter \(i + 1)",
                state: state,
                city: "City \(i + 1)",
                university: "University \(i + 1)",
                presidentName: "President \(i + 1)",
                contactEmail: "chapter\(i + 1)@example.com",
                description: "Sample chapter \(i + 1)",
                memberCount: 50 + i,
                dateEstablished: Date()
            )
            chapters.append(chapter)
        }
        
        return chapters
    }
}

