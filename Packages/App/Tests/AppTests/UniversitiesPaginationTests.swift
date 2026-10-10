import XCTest
@testable import App
import Common

final class UniversitiesPaginationTests: XCTestCase {
    var viewModel: UniversitiesViewModel!
    var mockCacheService: MockCacheService!
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockCacheService()
        viewModel = UniversitiesViewModel(cacheService: mockCacheService)
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
        await viewModel.loadUniversities()
        
        // Verify pagination applies
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        let paginated = viewModel.paginatedUniversities
        XCTAssertLessThanOrEqual(paginated.count, 20)
    }
    
    // MARK: - Pagination Logic Tests
    func testPaginatedUniversitiesReturnsCorrectItemsForPage() {
        viewModel.universities = University.generateSamples(count: 50)
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        let page1 = viewModel.paginatedUniversities
        XCTAssertEqual(page1.count, 20)
        
        viewModel.currentPage = 2
        let page2 = viewModel.paginatedUniversities
        XCTAssertEqual(page2.count, 20)
        
        viewModel.currentPage = 3
        let page3 = viewModel.paginatedUniversities
        XCTAssertEqual(page3.count, 10) // Only 10 left
    }
    
    func testLoadNextPageIncrementsCurrentPage() async {
        viewModel.universities = University.generateSamples(count: 50)
        viewModel.currentPage = 1
        
        await viewModel.loadNextPage()
        
        XCTAssertEqual(viewModel.currentPage, 2)
    }
    
    func testHasMoreDataReturnsTrueWhenMoreDataExists() {
        viewModel.universities = University.generateSamples(count: 50)
        viewModel.currentPage = 1
        viewModel.itemsPerPage = 20
        
        XCTAssertTrue(viewModel.hasMoreData)
    }
    
    func testHasMoreDataReturnsFalseOnLastPage() {
        viewModel.universities = University.generateSamples(count: 50)
        viewModel.currentPage = 3
        viewModel.itemsPerPage = 20
        
        XCTAssertFalse(viewModel.hasMoreData)
    }
    
    func testTotalPageCountCalculation() {
        viewModel.universities = University.generateSamples(count: 50)
        viewModel.itemsPerPage = 20
        
        XCTAssertEqual(viewModel.totalPages, 3)
    }
    
    // MARK: - Edge Cases
    func testPaginationWithEmptyUniversities() {
        viewModel.universities = []
        viewModel.currentPage = 1
        
        let paginated = viewModel.paginatedUniversities
        XCTAssertEqual(paginated.count, 0)
    }
    
    func testResetPaginationReturnsToPageOne() {
        viewModel.currentPage = 3
        
        viewModel.resetPagination()
        
        XCTAssertEqual(viewModel.currentPage, 1)
    }
}

// MARK: - Sample Data Generator
extension University {
    static func generateSamples(count: Int) -> [University] {
        var universities: [University] = []
        let states = ["California", "Texas", "New York", "Florida", "Illinois"]
        
        for i in 0..<count {
            let state = states[i % states.count]
            let university = University(
                name: "University \(i + 1)",
                state: state,
                city: "City \(i + 1)",
                hasChapter: i % 2 == 0,
                studentPopulation: 10000 + i * 100
            )
            universities.append(university)
        }
        
        return universities
    }
}

