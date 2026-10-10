import XCTest
@testable import Common

final class FavoritesServiceTests: XCTestCase {
    var favoritesService: FavoritesServiceImpl!
    var mockCacheService: MockFavoritesTestCacheService!
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockFavoritesTestCacheService()
        favoritesService = FavoritesServiceImpl(cacheService: mockCacheService)
    }
    
    override func tearDown() {
        favoritesService = nil
        mockCacheService = nil
        super.tearDown()
    }
    
    // MARK: - Add Favorite Tests
    func testAddFavoriteSucceeds() {
        let testId = UUID()
        
        let result = favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        XCTAssertTrue(result)
    }
    
    func testAddFavoriteSavesToCache() {
        let testId = UUID()
        
        let _ = favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        XCTAssertTrue(mockCacheService.saveWasCalled)
    }
    
    func testAddDuplicateFavoriteDoesNotCreateDuplicate() {
        let testId = UUID()
        
        let _ = favoritesService.addFavorite(id: testId, key: "test_favorites")
        let _ = favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        let favorites: [UUID] = favoritesService.getFavorites(key: "test_favorites")
        let count = favorites.filter { $0 == testId }.count
        
        XCTAssertEqual(count, 1)
    }
    
    // MARK: - Remove Favorite Tests
    func testRemoveFavoriteSucceeds() {
        let testId = UUID()
        favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        let result = favoritesService.removeFavorite(id: testId, key: "test_favorites")
        
        XCTAssertTrue(result)
    }
    
    func testRemoveFavoriteRemovesFromCache() {
        let testId = UUID()
        favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        let _ = favoritesService.removeFavorite(id: testId, key: "test_favorites")
        
        XCTAssertTrue(mockCacheService.saveWasCalled)
    }
    
    func testRemoveNonExistentFavoriteFails() {
        let testId = UUID()
        
        let result = favoritesService.removeFavorite(id: testId, key: "test_favorites")
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Get Favorites Tests
    func testGetFavoritesReturnsEmptyArrayWhenNoFavorites() {
        let favorites: [UUID] = favoritesService.getFavorites(key: "test_favorites")
        
        XCTAssertEqual(favorites.count, 0)
    }
    
    func testGetFavoritesReturnsAllAddedFavorites() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        
        favoritesService.addFavorite(id: id1, key: "test_favorites")
        favoritesService.addFavorite(id: id2, key: "test_favorites")
        favoritesService.addFavorite(id: id3, key: "test_favorites")
        
        let favorites: [UUID] = favoritesService.getFavorites(key: "test_favorites")
        
        XCTAssertEqual(favorites.count, 3)
        XCTAssertTrue(favorites.contains(id1))
        XCTAssertTrue(favorites.contains(id2))
        XCTAssertTrue(favorites.contains(id3))
    }
    
    // MARK: - Is Favorited Tests
    func testIsFavoritedReturnsTrueForAddedFavorite() {
        let testId = UUID()
        favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        let result = favoritesService.isFavorited(id: testId, key: "test_favorites")
        
        XCTAssertTrue(result)
    }
    
    func testIsFavoritedReturnsFalseForNonAddedFavorite() {
        let testId = UUID()
        
        let result = favoritesService.isFavorited(id: testId, key: "test_favorites")
        
        XCTAssertFalse(result)
    }
    
    func testIsFavoritedReturnsFalseAfterRemovingFavorite() {
        let testId = UUID()
        favoritesService.addFavorite(id: testId, key: "test_favorites")
        favoritesService.removeFavorite(id: testId, key: "test_favorites")
        
        let result = favoritesService.isFavorited(id: testId, key: "test_favorites")
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Multiple Keys Tests
    func testDifferentKeysMaintainSeparateFavorites() {
        let id1 = UUID()
        let id2 = UUID()
        
        favoritesService.addFavorite(id: id1, key: "chapters_favorites")
        favoritesService.addFavorite(id: id2, key: "universities_favorites")
        
        let chaptersIds: [UUID] = favoritesService.getFavorites(key: "chapters_favorites")
        let universitiesIds: [UUID] = favoritesService.getFavorites(key: "universities_favorites")
        
        XCTAssertTrue(chaptersIds.contains(id1))
        XCTAssertFalse(chaptersIds.contains(id2))
        
        XCTAssertFalse(universitiesIds.contains(id1))
        XCTAssertTrue(universitiesIds.contains(id2))
    }
    
    // MARK: - Persistence Tests
    func testFavoritesPersistedBetweenInstances() {
        let testId = UUID()
        favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        // Create new service instance with same cache
        let newService = FavoritesServiceImpl(cacheService: mockCacheService)
        let result = newService.isFavorited(id: testId, key: "test_favorites")
        
        XCTAssertTrue(result)
    }
    
    // MARK: - Toggle Favorite Tests
    func testToggleFavoriteAddsWhenNotPresent() {
        let testId = UUID()
        
        let result = favoritesService.toggleFavorite(id: testId, key: "test_favorites")
        
        XCTAssertTrue(result) // Should return true if now favorited
        XCTAssertTrue(favoritesService.isFavorited(id: testId, key: "test_favorites"))
    }
    
    func testToggleFavoriteRemovesWhenPresent() {
        let testId = UUID()
        favoritesService.addFavorite(id: testId, key: "test_favorites")
        
        let result = favoritesService.toggleFavorite(id: testId, key: "test_favorites")
        
        XCTAssertFalse(result) // Should return false if now unfavorited
        XCTAssertFalse(favoritesService.isFavorited(id: testId, key: "test_favorites"))
    }
    
    // MARK: - Clear Favorites Tests
    func testClearFavoritesRemovesAll() {
        let id1 = UUID()
        let id2 = UUID()
        
        favoritesService.addFavorite(id: id1, key: "test_favorites")
        favoritesService.addFavorite(id: id2, key: "test_favorites")
        
        favoritesService.clearFavorites(key: "test_favorites")
        
        let favorites: [UUID] = favoritesService.getFavorites(key: "test_favorites")
        XCTAssertEqual(favorites.count, 0)
    }
}

// MARK: - Mock Cache Service
class MockFavoritesTestCacheService: CacheService {
    private var storage: [String: Data] = [:]
    var saveWasCalled = false
    var retrieveWasCalled = false
    
    func save<T: Codable>(key: String, value: T) throws {
        saveWasCalled = true
        let data = try JSONEncoder().encode(value)
        storage[key] = data
    }
    
    func retrieve<T: Codable>(key: String, defaultValue: T?) throws -> T? {
        retrieveWasCalled = true
        guard let data = storage[key] else {
            return defaultValue
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func clear(key: String) {
        storage.removeValue(forKey: key)
    }
    
    func clearAll() {
        storage.removeAll()
    }
    
    func isExpired(key: String) -> Bool {
        return !storage.keys.contains(key)
    }
}
