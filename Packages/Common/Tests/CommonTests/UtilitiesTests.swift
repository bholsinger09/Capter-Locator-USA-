import XCTest
@testable import Common

final class ValidatorsTests: XCTestCase {
    func testValidEmail() {
        XCTAssertTrue(Validators.isValidEmail("test@example.com"))
        XCTAssertTrue(Validators.isValidEmail("user+tag@domain.co.uk"))
        XCTAssertFalse(Validators.isValidEmail("invalid"))
        XCTAssertFalse(Validators.isValidEmail("test@"))
    }
    
    func testValidPassword() {
        XCTAssertTrue(Validators.isValidPassword("password123"))
        XCTAssertFalse(Validators.isValidPassword("short"))
        XCTAssertFalse(Validators.isValidPassword(""))
    }
    
    func testPasswordsMatch() {
        XCTAssertTrue(Validators.passwordsMatch("password", "password"))
        XCTAssertFalse(Validators.passwordsMatch("password", "different"))
        XCTAssertFalse(Validators.passwordsMatch("", ""))
    }
    
    func testIsNotEmpty() {
        XCTAssertTrue(Validators.isNotEmpty("text"))
        XCTAssertFalse(Validators.isNotEmpty(""))
        XCTAssertFalse(Validators.isNotEmpty("   "))
    }
}

final class StringExtensionsTests: XCTestCase {
    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed(), "hello")
        XCTAssertEqual("hello".trimmed(), "hello")
    }
    
    func testIsEmptyOrWhitespace() {
        XCTAssertTrue("   ".isEmptyOrWhitespace)
        XCTAssertTrue("".isEmptyOrWhitespace)
        XCTAssertFalse("text".isEmptyOrWhitespace)
    }
}

final class DateExtensionsTests: XCTestCase {
    func testIsToday() {
        XCTAssertTrue(Date().isToday)
    }
    
    func testIsFuture() {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        XCTAssertTrue(futureDate.isFuture)
        
        let pastDate = Date().addingTimeInterval(-3600)
        XCTAssertFalse(pastDate.isFuture)
    }
}

final class ConstantsTests: XCTestCase {
    func testUSStatesAvailable() {
        XCTAssertGreaterThan(AppConstants.usStates.count, 0)
        XCTAssertTrue(AppConstants.usStates.contains("California"))
        XCTAssertTrue(AppConstants.usStates.contains("Texas"))
    }
    
    func testValidationConstants() {
        XCTAssertGreaterThan(AppConstants.Validation.minPasswordLength, 0)
        XCTAssertGreaterThan(AppConstants.Validation.maxNameLength, 0)
    }
}
