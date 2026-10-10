import XCTest
import Combine
@testable import App
@testable import Common

final class ProfileViewModelTests: XCTestCase {
    var viewModel: ProfileViewModel!
    var mockCacheService: MockProfileCacheService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockProfileCacheService()
        viewModel = ProfileViewModel(cacheService: mockCacheService)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockCacheService = nil
        cancellables.removeAll()
    }
    
    // MARK: - Test Initial State
    func testInitialStateIsIdle() {
        if case .idle = viewModel.userLoadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be idle, got: \(viewModel.userLoadingState)")
        }
    }
    
    // MARK: - Test Loading Profile
    func testLoadProfileTransitionsToLoading() {
        let expectation = XCTestExpectation(description: "Transition to loading state")
        
        viewModel.$userLoadingState.sink { state in
            if case .loading = state {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadProfile()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadProfileSuccessfullyLoadsData() {
        let expectation = XCTestExpectation(description: "Successfully load profile")
        
        viewModel.$userLoadingState.sink { state in
            if case .success(let user) = state {
                XCTAssertNotNil(user)
                XCTAssertFalse(user.email.isEmpty)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadProfile()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadProfileHandlesError() {
        let expectation = XCTestExpectation(description: "Handle error during load")
        mockCacheService.shouldFail = true
        
        viewModel.$userLoadingState.sink { state in
            if case .failure(let error) = state {
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadProfile()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Refresh
    func testRefreshClearsOldDataAndReloads() {
        let expectation = XCTestExpectation(description: "Refresh reloads profile")
        var stateCount = 0
        
        viewModel.$userLoadingState.sink { state in
            stateCount += 1
            if stateCount > 1, case .success(let user) = state {
                XCTAssertNotNil(user)
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
            await viewModel.loadProfile()
            
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
    
    // MARK: - Test Update Profile
    func testUpdateProfileTransitionsCorrectly() {
        let expectation = XCTestExpectation(description: "Update profile transitions correctly")
        var transitionCount = 0
        
        viewModel.$userLoadingState.sink { state in
            if case .loading = state {
                transitionCount += 1
                if transitionCount == 2 { // First load, then update
                    expectation.fulfill()
                }
            }
        }
        .store(in: &cancellables)
        
        Task {
            await viewModel.loadProfile()
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
        let updatedUser = User(
                email: "newemail@example.com",
                firstName: "Jane",
                lastName: "Smith",
                state: "California"
            )
            await viewModel.updateProfile(updatedUser)
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Test Cache Integration
    func testSuccessfulLoadCachesData() {
        let expectation = XCTestExpectation(description: "Profile data is cached on successful load")
        
        Task {
            await viewModel.loadProfile()
            
            // Wait for state to update
            try? await Task.sleep(nanoseconds: 100_000_000)
            XCTAssertTrue(mockCacheService.saveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadRetrievesFromCache() {
        let expectation = XCTestExpectation(description: "Profile data is retrieved from cache")
        
        Task {
            await viewModel.loadProfile()
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Load again - should use cache
            mockCacheService.retrieveWasCalled = false
            await viewModel.loadProfile()
            
            XCTAssertTrue(mockCacheService.retrieveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Logout
    func testLogoutClearsProfile() {
        let expectation = XCTestExpectation(description: "Logout clears profile")
        
        Task {
            await viewModel.loadProfile()
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Verify profile was loaded
            if case .success = viewModel.userLoadingState {
                await viewModel.logout()
                
                XCTAssertTrue(mockCacheService.clearWasCalled)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Cache Service
class MockProfileCacheService: CacheService {
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
