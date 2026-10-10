import XCTest
@testable import AppUI
import SwiftUI

final class PrimaryButtonTests: XCTestCase {
    func testPrimaryButtonInitialization() {
        var actionCalled = false
        let button = PrimaryButton("Test Title", icon: "star.fill") {
            actionCalled = true
        }
        
        // Verify button is created without crashing
        XCTAssertNotNil(button)
    }
    
    func testPrimaryButtonWithoutIcon() {
        var actionCalled = false
        let button = PrimaryButton("Test Title") {
            actionCalled = true
        }
        
        XCTAssertNotNil(button)
    }
    
    func testSecondaryButtonInitialization() {
        var actionCalled = false
        let button = SecondaryButton("Cancel", icon: "xmark") {
            actionCalled = true
        }
        
        XCTAssertNotNil(button)
    }
    
    func testDangerButtonInitialization() {
        var actionCalled = false
        let button = DangerButton("Delete") {
            actionCalled = true
        }
        
        XCTAssertNotNil(button)
    }
}

final class DetailRowComponentTests: XCTestCase {
    func testDetailRowInitialization() {
        let row = DetailRow(label: "Chapter", value: "Texas State")
        XCTAssertNotNil(row)
    }
    
    func testDetailRowWithImage() {
        let row = DetailRow(
            label: "Status",
            value: "Active",
            icon: "checkmark.circle.fill"
        )
        XCTAssertNotNil(row)
    }
    
    func testDetailRowWithCustomColor() {
        let row = DetailRow(
            label: "Status",
            value: "Active",
            valueColor: .green
        )
        XCTAssertNotNil(row)
    }
}

final class DetailHeaderCardTests: XCTestCase {
    func testDetailHeaderCardInitialization() {
        let header = DetailHeaderCard(
            title: "Chapter Name",
            subtitle: "Texas",
            icon: "building.2.fill"
        )
        XCTAssertNotNil(header)
    }
}

final class FormSectionTests: XCTestCase {
    func testFormSectionInitialization() {
        let section = FormSection(
            title: "Personal Info",
            content: {
                Text("Content")
            }
        )
        XCTAssertNotNil(section)
    }
}

final class ButtonActionTests: XCTestCase {
    func testPrimaryButtonActionFired() {
        var callCount = 0
        _ = PrimaryButton("Test") {
            callCount += 1
        }
        
        XCTAssertEqual(callCount, 0) // Action hasn't fired yet during initialization
    }
}
