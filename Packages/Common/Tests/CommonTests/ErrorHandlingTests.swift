import XCTest
@testable import Common

final class AppErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let networkError = AppError.networkError("Connection timeout")
        XCTAssertNotNil(networkError.errorDescription)
        XCTAssertTrue(networkError.errorDescription!.contains("Network Error"))
        
        let decodingError = AppError.decodingError("Invalid JSON")
        XCTAssertNotNil(decodingError.errorDescription)
        
        let validationError = AppError.validationError("Email invalid")
        XCTAssertNotNil(validationError.errorDescription)
    }
    
    func testErrorRecoverySuggestions() {
        let error = AppError.networkError("Connection failed")
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion!.contains("connection"))
    }
    
    func testErrorIdentifiable() {
        let error = AppError.notFound("Chapter not found")
        XCTAssertNotNil(error.id)
        XCTAssertEqual(error.id, error.errorDescription)
    }
    
    func testUnknownError() {
        let error = AppError.unknown("Something weird happened")
        XCTAssertTrue(error.errorDescription!.contains("unknown"))
    }
    
    func testServerError() {
        let error = AppError.serverError(500, "Internal Server Error")
        XCTAssertTrue(error.errorDescription!.contains("500"))
    }
}

final class LoadingStateTests: XCTestCase {
    func testLoadingStateIdle() {
        let state: LoadingState<String> = .idle
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.value)
        XCTAssertNil(state.error)
    }
    
    func testLoadingStateLoading() {
        let state: LoadingState<String> = .loading
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.value)
        XCTAssertNil(state.error)
    }
    
    func testLoadingStateSuccess() {
        let state: LoadingState<String> = .success("Test Value")
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.value, "Test Value")
        XCTAssertNil(state.error)
    }
    
    func testLoadingStateFailure() {
        let error = AppError.networkError("Failed")
        let state: LoadingState<String> = .failure(error)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.value)
        XCTAssertNotNil(state.error)
        XCTAssertEqual(state.error?.id, error.id)
    }
}
