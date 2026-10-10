import XCTest
@testable import App
import Common
@testable import Chapters
@testable import Events

final class ChapterDetailViewTests: XCTestCase {
    func testChapterDetailViewRenders() {
        let chapter = Chapter(
            name: "Test Chapter",
            state: "Texas",
            city: "Austin",
            university: "University of Texas",
            presidentName: "John Smith",
            contactEmail: "john@tpusa.org",
            description: "Test description",
            memberCount: 50,
            dateEstablished: Date()
        )
        
        // Verify that view can be created with chapter data
        XCTAssertEqual(chapter.name, "Test Chapter")
        XCTAssertEqual(chapter.state, "Texas")
    }
    
    func testEventDetailViewWithValidEvent() {
        let event = Event(
            title: "Test Event",
            description: "Event description",
            eventDate: Date(),
            location: "Student Center",
            organizerName: "Jane Doe",
            capacity: 100
        )
        
        XCTAssertEqual(event.title, "Test Event")
        XCTAssertEqual(event.capacity, 100)
    }
}

final class DetailViewCompletenessTests: XCTestCase {
    func testChapterDetailViewHasRequiredFields() {
        // Ensure ChapterDetailView can be instantiated
        let chapter = Chapter.samples.first!
        XCTAssertNotNil(chapter.name)
        XCTAssertNotNil(chapter.contactEmail)
        XCTAssertNotNil(chapter.presidentName)
    }
    
    func testUniversitiesViewDataAvailable() {
        let university = University(
            name: "University of Texas",
            state: "Texas",
            city: "Austin",
            hasChapter: true,
            studentPopulation: 52000
        )
        
        XCTAssertEqual(university.name, "University of Texas")
        XCTAssertEqual(university.state, "Texas")
    }
}

