import XCTest
import Combine
@testable import Chapters
@testable import Common

final class ChaptersViewModelTests: XCTestCase {
    var viewModel: ChaptersViewModel!
    var mockCacheService: MockCacheService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockCacheService()
        viewModel = ChaptersViewModel(cacheService: mockCacheService)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockCacheService = nil
        cancellables.removeAll()
    }
    
    // MARK: - Test Initial State
    func testInitialStateIsIdle() {
        if case .idle = viewModel.loadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be idle, got: \(viewModel.loadingState)")
        }
    }
    
    // MARK: - Test Loading Chapters
    func testLoadChaptersTransitionsToLoading() {
        let expectation = XCTestExpectation(description: "Transition to loading state")
        
        viewModel.$loadingState.sink { state in
            if case .loading = state {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadChapters()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadChaptersSuccessfullyLoadsData() {
        let expectation = XCTestExpectation(description: "Successfully load chapters")
        
        viewModel.$loadingState.sink { state in
            if case .success(let chapters) = state {
                XCTAssertGreaterThan(chapters.count, 0)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadChapters()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadChaptersHandlesError() {
        let expectation = XCTestExpectation(description: "Handle error during load")
        mockCacheService.shouldFail = true
        
        viewModel.$loadingState.sink { state in
            if case .failure(let error) = state {
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadChapters()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Refresh
    func testRefreshClearsOldDataAndReloads() {
        let expectation = XCTestExpectation(description: "Refresh reloads data")
        var stateCount = 0
        
        viewModel.$loadingState.sink { state in
            stateCount += 1
            if stateCount > 1, case .success(let chapters) = state {
                XCTAssertGreaterThan(chapters.count, 0)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.refresh()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRefreshClearsCacheBeforeReload() {
        let expectation = XCTestExpectation(description: "Refresh clears cache")
        
        Task {
            mockCacheService.shouldFail = false
            await viewModel.loadChapters()
            
            // Verify cache was called
            XCTAssertTrue(mockCacheService.saveWasCalled)
            
            // Reset and refresh
            mockCacheService.clearWasCalled = false
            await viewModel.refresh()
            
            XCTAssertTrue(mockCacheService.clearWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Search/Filter
    func testSearchFiltersChapters() {
        Task {
            await viewModel.loadChapters()
            
            viewModel.searchText = "UCLA"
            let filtered = viewModel.filteredChapters
            
            for chapter in filtered {
                XCTAssertTrue(
                    chapter.name.localizedCaseInsensitiveContains("UCLA") ||
                    chapter.city.localizedCaseInsensitiveContains("UCLA") ||
                    (chapter.university?.localizedCaseInsensitiveContains("UCLA") ?? false)
                )
            }
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
    
    func testStateFilterFiltersChapters() {
        Task {
            await viewModel.loadChapters()
            
            if let firstState = viewModel.chapters.first?.state {
                viewModel.selectedState = firstState
                let filtered = viewModel.filteredChapters
                
                for chapter in filtered {
                    XCTAssertEqual(chapter.state, firstState)
                }
            }
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
    
    // MARK: - Test Cache Integration
    func testSuccessfulLoadCachesData() {
        let expectation = XCTestExpectation(description: "Data is cached on successful load")
        
        Task {
            await viewModel.loadChapters()
            
            // Wait for state to update
            try? await Task.sleep(nanoseconds: 100_000_000)
            XCTAssertTrue(mockCacheService.saveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadRetrievesFromCache() {
        let expectation = XCTestExpectation(description: "Data is retrieved from cache")
        
        Task {
            await viewModel.loadChapters()
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Load again - should use cache
            mockCacheService.retrieveWasCalled = false
            await viewModel.loadChapters()
            
            XCTAssertTrue(mockCacheService.retrieveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Cache Service
class MockCacheService: CacheService {
    var saveWasCalled = false
    var retrieveWasCalled = false
    var clearWasCalled = false
    var shouldFail = false
    
    func save<T: Codable>(key: String, value: T) throws {
        saveWasCalled = true
        if shouldFail {
            throw CacheServiceError.encodingFailed("Mock error")
        }
    }
    
    func retrieve<T: Codable>(key: String, defaultValue: T?) throws -> T? {
        retrieveWasCalled = true
        if shouldFail {
            throw CacheServiceError.decodingFailed("Mock error")
        }
        return defaultValue
    }
    
    func clear(key: String) {
        clearWasCalled = true
    }
    
    func clearAll() {
        clearWasCalled = true
    }
    
    func isExpired(key: String) -> Bool {
        return true
    }
}
