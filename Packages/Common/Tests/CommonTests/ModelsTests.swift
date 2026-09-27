import XCTest
@testable import Common

final class UserTests: XCTestCase {
    func testUserInitialization() {
        let user = User(
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            state: "California"
        )
        
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.state, "California")
        XCTAssertEqual(user.fullName, "John Doe")
    }
    
    func testUserCodable() throws {
        let user = User(
            email: "test@example.com",
            firstName: "Jane",
            lastName: "Smith",
            state: "Texas"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.email, decodedUser.email)
        XCTAssertEqual(user.fullName, decodedUser.fullName)
    }
}

final class UniversityTests: XCTestCase {
    func testUniversityInitialization() {
        let university = University(
            name: "University of California",
            state: "California",
            city: "Berkeley",
            hasChapter: true
        )
        
        XCTAssertEqual(university.name, "University of California")
        XCTAssertEqual(university.state, "California")
        XCTAssertEqual(university.city, "Berkeley")
        XCTAssertTrue(university.hasChapter)
        XCTAssertEqual(university.displayLocation, "Berkeley, California")
    }
}

final class NotificationPreferencesTests: XCTestCase {
    func testDefaultPreferences() {
        let prefs = NotificationPreferences()
        
        XCTAssertTrue(prefs.eventReminders)
        XCTAssertTrue(prefs.newEventNotifications)
        XCTAssertTrue(prefs.soundEnabled)
        XCTAssertFalse(prefs.newBlogPosts)
    }
    
    func testHasAnyEnabled() {
        let prefs = NotificationPreferences(eventReminders: true)
        XCTAssertTrue(prefs.hasAnyEnabled)
        
        let allDisabled = NotificationPreferences(
            eventReminders: false,
            newEventNotifications: false,
            chapterAnnouncements: false,
            newBlogPosts: false
        )
        XCTAssertFalse(allDisabled.hasAnyEnabled)
    }
    
    func testEnabledCount() {
        let prefs = NotificationPreferences()
        XCTAssertGreaterThan(prefs.enabledCount, 0)
    }
}
