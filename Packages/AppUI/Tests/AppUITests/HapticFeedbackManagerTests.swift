import XCTest
@testable import AppUI
import UIKit

final class HapticFeedbackManagerTests: XCTestCase {
    var hapticManager: HapticFeedbackManager!
    
    override func setUp() {
        super.setUp()
        hapticManager = HapticFeedbackManager.shared
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Impact Feedback Tests
    func testTapFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.tapFeedback()
        XCTAssertTrue(true)
    }
    
    func testMediumTapFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.mediumTapFeedback()
        XCTAssertTrue(true)
    }
    
    func testHeavyTapFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.heavyTapFeedback()
        XCTAssertTrue(true)
    }
    
    // MARK: - Notification Feedback Tests
    func testSuccessFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.successFeedback()
        XCTAssertTrue(true)
    }
    
    func testWarningFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.warningFeedback()
        XCTAssertTrue(true)
    }
    
    func testErrorFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.errorFeedback()
        XCTAssertTrue(true)
    }
    
    // MARK: - Selection Feedback Tests
    func testSelectionFeedbackDoesNotCrash() {
        // Should not throw
        hapticManager.selectionFeedback()
        XCTAssertTrue(true)
    }
    
    // MARK: - Multiple Haptics Tests
    func testMultipleHapticsInSequenceDoNotCrash() {
        hapticManager.tapFeedback()
        hapticManager.mediumTapFeedback()
        hapticManager.successFeedback()
        hapticManager.selectionFeedback()
        
        XCTAssertTrue(true)
    }
    
    // MARK: - Shared Instance Tests
    func testSharedInstanceReturnsConsistentObject() {
        let instance1 = HapticFeedbackManager.shared
        let instance2 = HapticFeedbackManager.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
}
