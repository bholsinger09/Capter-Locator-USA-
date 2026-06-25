//
//  GeospatialServiceTests.swift
//  SwiftChapterUSA Finder Tests
//
//  Unit tests for GeospatialService demonstrating:
//  - Distance calculation accuracy
//  - Spatial indexing performance
//  - Query correctness
//  - Analytics calculations
//

import XCTest
@testable import SwiftChapterUSA_Finder

class GeospatialServiceTests: XCTestCase {
    var service: GeospatialService!
    var testChapters: [Chapter]!
    var testEvents: [Event]!
    
    override func setUp() {
        super.setUp()
        service = GeospatialService()
        setupTestData()
    }
    
    override func tearDown() {
        service = nil
        testChapters = nil
        testEvents = nil
        super.tearDown()
    }
    
    // MARK: - Test Data Setup
    private func setupTestData() {
        // Create sample chapters at known locations
        testChapters = [
            // Denver, CO (39.7392, -104.9903)
            Chapter(
                id: UUID(),
                name: "Denver Chapter",
                state: "CO",
                city: "Denver",
                university: "University of Denver",
                presidentName: "John Doe",
                contactEmail: "denver@example.com",
                description: "Colorado chapter",
                memberCount: 45,
                dateEstablished: Date(),
                latitude: 39.7392,
                longitude: -104.9903
            ),
            // Boulder, CO (40.0150, -105.2705)
            Chapter(
                id: UUID(),
                name: "Boulder Chapter",
                state: "CO",
                city: "Boulder",
                university: "University of Colorado",
                presidentName: "Jane Smith",
                contactEmail: "boulder@example.com",
                description: "Colorado chapter",
                memberCount: 32,
                dateEstablished: Date(),
                latitude: 40.0150,
                longitude: -105.2705
            ),
            // San Francisco, CA (37.7749, -122.4194)
            Chapter(
                id: UUID(),
                name: "San Francisco Chapter",
                state: "CA",
                city: "San Francisco",
                university: "UC San Francisco",
                presidentName: "Mike Johnson",
                contactEmail: "sf@example.com",
                description: "California chapter",
                memberCount: 58,
                dateEstablished: Date(),
                latitude: 37.7749,
                longitude: -122.4194
            ),
            // LA, CA (34.0522, -118.2437)
            Chapter(
                id: UUID(),
                name: "Los Angeles Chapter",
                state: "CA",
                city: "Los Angeles",
                university: "UCLA",
                presidentName: "Sarah Wilson",
                contactEmail: "la@example.com",
                description: "California chapter",
                memberCount: 72,
                dateEstablished: Date(),
                latitude: 34.0522,
                longitude: -118.2437
            ),
            // NYC (40.7128, -74.0060)
            Chapter(
                id: UUID(),
                name: "New York Chapter",
                state: "NY",
                city: "New York",
                university: "Columbia University",
                presidentName: "David Lee",
                contactEmail: "ny@example.com",
                description: "New York chapter",
                memberCount: 85,
                dateEstablished: Date(),
                latitude: 40.7128,
                longitude: -74.0060
            )
        ]
        
        testEvents = []
    }
    
    // MARK: - Distance Calculation Tests
    
    func testHaversineDistance_DenverToBoulder() {
        // Denver to Boulder is approximately 50km
        let distance = service.distance(
            from: (39.7392, -104.9903),
            to: (40.0150, -105.2705)
        )
        
        // Assert within 1km accuracy (should be ~49km)
        XCTAssertEqual(distance, 49.1, accuracy: 1.0)
    }
    
    func testHaversineDistance_DenverToSanFrancisco() {
        // Denver to San Francisco is approximately 1270km
        let distance = service.distance(
            from: (39.7392, -104.9903),
            to: (37.7749, -122.4194)
        )
        
        XCTAssertEqual(distance, 1270.0, accuracy: 50.0)
    }
    
    func testHaversineDistance_SameLocation() {
        let distance = service.distance(
            from: (39.7392, -104.9903),
            to: (39.7392, -104.9903)
        )
        
        XCTAssertEqual(distance, 0.0, accuracy: 0.01)
    }
    
    func testHaversineDistance_EquatorAntipode() {
        // Distance from a point to its antipode should be ~20000km (half Earth circumference)
        let distance = service.distance(
            from: (0.0, 0.0),
            to: (0.0, 180.0)
        )
        
        XCTAssertEqual(distance, 20015.0, accuracy: 100.0)
    }
    
    // MARK: - Spatial Indexing Tests
    
    func testQuadtreeIndexing_InsertAndQuery() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        // Query should return nearby Denver chapter
        let nearby = service.findNearby(
            latitude: 39.74,
            longitude: -104.99,
            radiusKm: 10
        )
        
        XCTAssertEqual(nearby.count, 1)
        XCTAssertEqual(nearby.first?.title, "Denver Chapter")
    }
    
    func testQuadtreeIndexing_LargeRadius() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        // Query with large radius should return all chapters (all within ~2500km)
        let nearby = service.findNearby(
            latitude: 39.74,
            longitude: -104.99,
            radiusKm: 3000
        )
        
        XCTAssertEqual(nearby.count, 5)
    }
    
    func testQuadtreeIndexing_StateSpecificQuery() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        // Denver - only nearby chapter is in Colorado
        let nearby = service.findNearby(
            latitude: 39.74,
            longitude: -104.99,
            radiusKm: 200
        )
        
        // Should find Denver and Boulder chapters
        XCTAssertEqual(nearby.count, 2)
        XCTAssert(nearby.allSatisfy { $0.title.contains("Chapter") })
    }
    
    // MARK: - Nearby Search Tests
    
    func testFindNearbyChapters_WithinRadius() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let nearby = service.findNearbyChapters(
            latitude: 39.74,
            longitude: -104.99,
            radiusKm: 100
        )
        
        // Denver area: should find Denver and Boulder
        XCTAssertEqual(nearby.count, 2)
        
        // First result should be closest (Denver)
        XCTAssertEqual(nearby.first?.chapter.city, "Denver")
        XCTAssertLessThan(nearby.first?.distanceKm ?? 1000, nearby.last?.distanceKm ?? 0)
    }
    
    func testFindNearbyChapters_SortedByDistance() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let nearby = service.findNearbyChapters(
            latitude: 39.74,
            longitude: -104.99,
            radiusKm: 100
        )
        
        // Verify results are sorted by distance
        for i in 0..<(nearby.count - 1) {
            XCTAssertLessThanOrEqual(
                nearby[i].distanceKm,
                nearby[i + 1].distanceKm
            )
        }
    }
    
    func testFindNearbyChapters_EmptyResult() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        // Query far from any chapter
        let nearby = service.findNearbyChapters(
            latitude: 0.0,
            longitude: 0.0,
            radiusKm: 100
        )
        
        XCTAssertEqual(nearby.count, 0)
    }
    
    // MARK: - Regional Statistics Tests
    
    func testRegionStatistics_Calculation() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let stats = service.calculateRegionStatistics()
        
        // Should have statistics for CO, CA, and NY
        XCTAssertEqual(stats.count, 3)
        
        // Find California stats
        if let caStats = stats.first(where: { $0.state == "CA" }) {
            XCTAssertEqual(caStats.chapterCount, 2) // SF and LA
            XCTAssertEqual(caStats.eventCount, 0)
            
            // Average members: (58 + 72) / 2 = 65
            XCTAssertEqual(caStats.averageMemberCount, 65)
        } else {
            XCTFail("California statistics not found")
        }
    }
    
    func testRegionStatistics_AllStates() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let stats = service.calculateRegionStatistics()
        let stateNames = Set(stats.map { $0.state })
        
        XCTAssertEqual(stateNames, ["CO", "CA", "NY"])
    }
    
    func testRegionStatistics_CoordinateAveraging() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let stats = service.calculateRegionStatistics()
        
        // Find Colorado stats
        if let coStats = stats.first(where: { $0.state == "CO" }) {
            // Average of Denver (39.7392) and Boulder (40.0150)
            let expectedLat = (39.7392 + 40.0150) / 2
            XCTAssertEqual(coStats.centerLatitude, expectedLat, accuracy: 0.01)
        }
    }
    
    // MARK: - Ranking Algorithm Tests
    
    func testRankingAlgorithm_ByEngagement() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let ranked = service.rankChapters(
            chapters: testChapters,
            events: testEvents
        )
        
        // LA (72 members) should rank higher than Boulder (32 members)
        guard let laIndex = ranked.firstIndex(where: { $0.chapter.city == "Los Angeles" }),
              let boulderIndex = ranked.firstIndex(where: { $0.chapter.city == "Boulder" }) else {
            XCTFail("Could not find chapters in rankings")
            return
        }
        
        XCTAssertLessThan(laIndex, boulderIndex)
    }
    
    func testRankingAlgorithm_ScoresArePositive() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let ranked = service.rankChapters(
            chapters: testChapters,
            events: testEvents
        )
        
        for item in ranked {
            XCTAssertGreaterThanOrEqual(item.score, 0.0)
        }
    }
    
    func testRankingAlgorithm_TopRankedHasHighestScore() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        let ranked = service.rankChapters(
            chapters: testChapters,
            events: testEvents
        )
        
        for i in 0..<(ranked.count - 1) {
            XCTAssertGreaterThanOrEqual(ranked[i].score, ranked[i + 1].score)
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_IndexingLargeDataset() {
        // Create 1000 chapters
        let largeDataset = (0..<1000).map { i -> Chapter in
            let lat = 24.5 + Double(i % 2500) * (49.4 - 24.5) / 2500
            let lon = -125.0 + Double(i / 2500) * (-66.9 + 125.0) / 100
            
            return Chapter(
                id: UUID(),
                name: "Chapter \(i)",
                state: "CA",
                city: "City \(i)",
                presidentName: "President \(i)",
                contactEmail: "chapter\(i)@example.com",
                description: "Test chapter",
                memberCount: Int.random(in: 10...100),
                dateEstablished: Date(),
                latitude: lat,
                longitude: lon
            )
        }
        
        measure {
            service.indexLocations(chapters: largeDataset, events: [])
        }
    }
    
    func testPerformance_QueryingIndexedData() {
        service.indexLocations(chapters: testChapters, events: testEvents)
        
        measure {
            _ = service.findNearby(
                latitude: 39.74,
                longitude: -104.99,
                radiusKm: 100
            )
        }
    }
}
