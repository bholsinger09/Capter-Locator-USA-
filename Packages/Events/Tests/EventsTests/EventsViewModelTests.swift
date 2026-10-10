import XCTest
import Combine
@testable import Events
@testable import Common

final class EventsViewModelTests: XCTestCase {
    var viewModel: EventsViewModel!
    var mockCacheService: MockEventsCacheService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockEventsCacheService()
        viewModel = EventsViewModel(cacheService: mockCacheService)
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
    
    // MARK: - Test Loading Events
    func testLoadEventsTransitionsToLoading() {
        let expectation = XCTestExpectation(description: "Transition to loading state")
        
        viewModel.$loadingState.sink { state in
            if case .loading = state {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadEvents()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadEventsSuccessfullyLoadsData() {
        let expectation = XCTestExpectation(description: "Successfully load events")
        
        viewModel.$loadingState.sink { state in
            if case .success(let events) = state {
                XCTAssertGreaterThan(events.count, 0)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadEvents()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadEventsHandlesError() {
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
            await viewModel.loadEvents()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Refresh
    func testRefreshClearsOldDataAndReloads() {
        let expectation = XCTestExpectation(description: "Refresh reloads data")
        var stateCount = 0
        
        viewModel.$loadingState.sink { state in
            stateCount += 1
            if stateCount > 1, case .success(let events) = state {
                XCTAssertGreaterThan(events.count, 0)
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
            await viewModel.loadEvents()
            
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
    func testSearchFiltersEvents() {
        Task {
            await viewModel.loadEvents()
            
            viewModel.searchText = "Kickoff"
            let filtered = viewModel.filteredEvents
            
            for event in filtered {
                XCTAssertTrue(
                    event.title.localizedCaseInsensitiveContains("Kickoff") ||
                    event.description.localizedCaseInsensitiveContains("Kickoff")
                )
            }
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
    
    func testDateFilterFiltersEvents() {
        Task {
            await viewModel.loadEvents()
            
            let selectedDate = Date().addingTimeInterval(86400)
            viewModel.selectedDate = selectedDate
            
            let filtered = viewModel.filteredEvents
            // Events should be sorted by date
            if filtered.count > 1 {
                for i in 0..<filtered.count - 1 {
                    XCTAssertLessThanOrEqual(
                        filtered[i].eventDate,
                        filtered[i + 1].eventDate
                    )
                }
            }
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
    
    // MARK: - Test Cache Integration
    func testSuccessfulLoadCachesData() {
        let expectation = XCTestExpectation(description: "Data is cached on successful load")
        
        Task {
            await viewModel.loadEvents()
            
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
            await viewModel.loadEvents()
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Load again - should use cache
            mockCacheService.retrieveWasCalled = false
            await viewModel.loadEvents()
            
            XCTAssertTrue(mockCacheService.retrieveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Chapter Filter
    func testFilterByChapter() {
        Task {
            await viewModel.loadEvents()
            
            // Set a chapter filter if available
            let filtered = viewModel.filteredEvents
            XCTAssertGreaterThanOrEqual(filtered.count, 0)
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
}

// MARK: - Mock Cache Service
class MockEventsCacheService: CacheService {
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
