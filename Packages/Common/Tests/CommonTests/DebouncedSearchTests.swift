import XCTest
import Combine
@testable import Common

final class DebouncedSearchTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    override func tearDown() {
        cancellable?.cancel()
        super.tearDown()
    }
    
    func testDebouncedSearchInitialization() {
        let search = DebouncedSearch()
        XCTAssertEqual(search.searchText, "")
        XCTAssertEqual(search.debouncedText, "")
    }
    
    func testDebouncedSearchWithCustomDelay() {
        let search = DebouncedSearch(delayMs: 500)
        XCTAssertEqual(search.searchText, "")
    }
    
    func testDebouncedSearchDelay() {
        let search = DebouncedSearch(delayMs: 100)
        let expectation = XCTestExpectation(description: "Debounce delay")
        
        search.searchText = "test"
        
        // Should not have updated yet
        XCTAssertNotEqual(search.debouncedText, "test")
        
        // Wait for debounce to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertEqual(search.debouncedText, "test")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDebouncedSearchRemovesDuplicates() {
        let search = DebouncedSearch(delayMs: 50)
        var debouncedValues: [String] = []
        
        cancellable = search.$debouncedText.sink { value in
            debouncedValues.append(value)
        }
        
        // Set same value multiple times
        search.searchText = "test"
        search.searchText = "test"
        search.searchText = "test"
        
        let expectation = XCTestExpectation(description: "Duplicate removal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should have received empty string and "test" only once
            XCTAssertLessThanOrEqual(debouncedValues.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDebouncedSearchMultipleInputs() {
        let search = DebouncedSearch(delayMs: 50)
        let expectation = XCTestExpectation(description: "Multiple inputs")
        
        search.searchText = "a"
        search.searchText = "ab"
        search.searchText = "abc"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(search.debouncedText, "abc")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
