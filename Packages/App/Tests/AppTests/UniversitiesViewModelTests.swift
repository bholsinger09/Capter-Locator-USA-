import XCTest
import Combine
@testable import App
@testable import Common

final class UniversitiesViewModelTests: XCTestCase {
    var viewModel: UniversitiesViewModel!
    var mockCacheService: MockUniversitiesCacheService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockUniversitiesCacheService()
        viewModel = UniversitiesViewModel(cacheService: mockCacheService)
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
    
    // MARK: - Test Loading Universities
    func testLoadUniversitiesTransitionsToLoading() {
        let expectation = XCTestExpectation(description: "Transition to loading state")
        
        viewModel.$loadingState.sink { state in
            if case .loading = state {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadUniversities()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadUniversitiesSuccessfullyLoadsData() {
        let expectation = XCTestExpectation(description: "Successfully load universities")
        
        viewModel.$loadingState.sink { state in
            if case .success(let universities) = state {
                XCTAssertGreaterThan(universities.count, 0)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadUniversities()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadUniversitiesHandlesError() {
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
            await viewModel.loadUniversities()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Refresh
    func testRefreshClearsOldDataAndReloads() {
        let expectation = XCTestExpectation(description: "Refresh reloads data")
        var stateCount = 0
        
        viewModel.$loadingState.sink { state in
            stateCount += 1
            if stateCount > 1, case .success(let universities) = state {
                XCTAssertGreaterThan(universities.count, 0)
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
            await viewModel.loadUniversities()
            
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
    func testSearchFiltersUniversities() {
        Task {
            await viewModel.loadUniversities()
            
            viewModel.searchText = "University"
            let filtered = viewModel.filteredUniversities
            
            for university in filtered {
                XCTAssertTrue(
                    university.name.localizedCaseInsensitiveContains("University") ||
                    university.city.localizedCaseInsensitiveContains("University")
                )
            }
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
    
    func testStateFilterFiltersUniversities() {
        Task {
            await viewModel.loadUniversities()
            
            if let firstState = viewModel.universities.first?.state {
                viewModel.selectedState = firstState
                let filtered = viewModel.filteredUniversities
                
                for university in filtered {
                    XCTAssertEqual(university.state, firstState)
                }
            }
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
    }
    
    // MARK: - Test Cache Integration
    func testSuccessfulLoadCachesData() {
        let expectation = XCTestExpectation(description: "Data is cached on successful load")
        
        Task {
            await viewModel.loadUniversities()
            
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
            await viewModel.loadUniversities()
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Load again - should use cache
            mockCacheService.retrieveWasCalled = false
            await viewModel.loadUniversities()
            
            XCTAssertTrue(mockCacheService.retrieveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Cache Service
class MockUniversitiesCacheService: CacheService {
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
