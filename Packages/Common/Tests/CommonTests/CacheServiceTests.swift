import XCTest
@testable import Common

// Mock UserDefaults for testing
final class MockUserDefaults: UserDefaults {
    var dictionary: [String: Any] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        dictionary[defaultName] = value
    }
    
    override func object(forKey defaultName: String) -> Any? {
        dictionary[defaultName]
    }
    
    override func data(forKey defaultName: String) -> Data? {
        dictionary[defaultName] as? Data
    }
    
    override func removeObject(forKey defaultName: String) {
        dictionary.removeValue(forKey: defaultName)
    }
    
    override func dictionaryRepresentation() -> [String: Any] {
        dictionary
    }
}

// Test model
struct TestCacheModel: Codable, Equatable {
    let id: Int
    let name: String
    let timestamp: Date
}

final class CacheServiceTests: XCTestCase {
    var mockUserDefaults: MockUserDefaults!
    var cacheService: UserDefaultsCacheService!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        cacheService = UserDefaultsCacheService(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        super.tearDown()
        cacheService = nil
        mockUserDefaults = nil
    }
    
    // MARK: - Save and Retrieve Tests
    
    func testSaveAndRetrieveCodableObject() throws {
        let testModel = TestCacheModel(id: 1, name: "Test Chapter", timestamp: Date())
        
        try cacheService.save(key: "test_chapter", value: testModel)
        let retrieved: TestCacheModel? = try cacheService.retrieve(key: "test_chapter")
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, testModel.id)
        XCTAssertEqual(retrieved?.name, testModel.name)
    }
    
    func testSaveAndRetrieveString() throws {
        let testString = "Hello, Cache!"
        
        try cacheService.save(key: "test_string", value: testString)
        let retrieved: String? = try cacheService.retrieve(key: "test_string")
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, testString)
    }
    
    func testSaveAndRetrieveInt() throws {
        let testInt = 42
        
        try cacheService.save(key: "test_int", value: testInt)
        let retrieved: Int? = try cacheService.retrieve(key: "test_int")
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, testInt)
    }
    
    func testSaveAndRetrieveArray() throws {
        let testArray = [1, 2, 3, 4, 5]
        
        try cacheService.save(key: "test_array", value: testArray)
        let retrieved: [Int]? = try cacheService.retrieve(key: "test_array")
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, testArray)
    }
    
    func testRetrieveNonExistentKeyReturnsNil() throws {
        let retrieved: String? = try cacheService.retrieve(key: "nonexistent_key")
        XCTAssertNil(retrieved)
    }
    
    func testRetrieveNonExistentKeyWithDefaultValue() throws {
        let defaultValue = "default"
        let retrieved: String? = try cacheService.retrieve(key: "nonexistent_key", defaultValue: defaultValue)
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, defaultValue)
    }
    
    // MARK: - Expiration Tests
    
    func testCacheExpirationAfter24Hours() throws {
        let testModel = TestCacheModel(id: 1, name: "Test Chapter", timestamp: Date())
        
        try cacheService.save(key: "expiring_cache", value: testModel)
        
        let now = Date()
        // Simulate time passing by directly manipulating the stored data
        let encoder = JSONEncoder()
        let cacheData = try encoder.encode(CacheEntry(value: testModel, expiresAt: now.addingTimeInterval(-1)))
        mockUserDefaults.dictionary["expiring_cache"] = cacheData
        
        let retrieved: TestCacheModel? = try cacheService.retrieve(key: "expiring_cache")
        XCTAssertNil(retrieved, "Cache should be expired and return nil")
    }
    
    func testCacheNotExpiredWithin24Hours() throws {
        let testModel = TestCacheModel(id: 1, name: "Test Chapter", timestamp: Date())
        
        try cacheService.save(key: "valid_cache", value: testModel)
        
        let retrieved: TestCacheModel? = try cacheService.retrieve(key: "valid_cache")
        
        XCTAssertNotNil(retrieved, "Cache should still be valid")
        XCTAssertEqual(retrieved?.id, testModel.id)
    }
    
    func testIsExpiredReturnsTrueForExpiredCache() throws {
        let testModel = TestCacheModel(id: 1, name: "Test Chapter", timestamp: Date())
        
        try cacheService.save(key: "expired_key", value: testModel)
        
        let now = Date()
        let cacheData = try JSONEncoder().encode(CacheEntry(value: testModel, expiresAt: now.addingTimeInterval(-1)))
        mockUserDefaults.dictionary["expired_key"] = cacheData
        
        let isExpired = cacheService.isExpired(key: "expired_key")
        XCTAssertTrue(isExpired)
    }
    
    func testIsExpiredReturnsFalseForValidCache() throws {
        let testModel = TestCacheModel(id: 1, name: "Test Chapter", timestamp: Date())
        
        try cacheService.save(key: "valid_key", value: testModel)
        
        let isExpired = cacheService.isExpired(key: "valid_key")
        XCTAssertFalse(isExpired)
    }
    
    func testIsExpiredReturnsTrueForNonExistentKey() {
        let isExpired = cacheService.isExpired(key: "nonexistent_key")
        XCTAssertTrue(isExpired, "Non-existent keys should be considered expired")
    }
    
    // MARK: - Clear Tests
    
    func testClearSpecificKey() throws {
        let testModel = TestCacheModel(id: 1, name: "Test Chapter", timestamp: Date())
        
        try cacheService.save(key: "to_clear", value: testModel)
        XCTAssertNotNil(try cacheService.retrieve(key: "to_clear") as TestCacheModel?)
        
        cacheService.clear(key: "to_clear")
        
        let retrieved: TestCacheModel? = try cacheService.retrieve(key: "to_clear")
        XCTAssertNil(retrieved)
    }
    
    func testClearAllCache() throws {
        let testModel1 = TestCacheModel(id: 1, name: "Chapter 1", timestamp: Date())
        let testModel2 = TestCacheModel(id: 2, name: "Chapter 2", timestamp: Date())
        
        try cacheService.save(key: "cache_1", value: testModel1)
        try cacheService.save(key: "cache_2", value: testModel2)
        try cacheService.save(key: "string_cache", value: "test string")
        
        XCTAssertNotNil(try cacheService.retrieve(key: "cache_1") as TestCacheModel?)
        XCTAssertNotNil(try cacheService.retrieve(key: "cache_2") as TestCacheModel?)
        XCTAssertNotNil(try cacheService.retrieve(key: "string_cache") as String?)
        
        cacheService.clearAll()
        
        let retrieved1: TestCacheModel? = try cacheService.retrieve(key: "cache_1")
        let retrieved2: TestCacheModel? = try cacheService.retrieve(key: "cache_2")
        let retrievedString: String? = try cacheService.retrieve(key: "string_cache")
        
        XCTAssertNil(retrieved1)
        XCTAssertNil(retrieved2)
        XCTAssertNil(retrievedString)
    }
    
    // MARK: - Error Handling Tests
    
    func testRetrievingInvalidCacheDataGracefullyReturnsNil() throws {
        // Store invalid data
        mockUserDefaults.dictionary["invalid_cache"] = Data(bytes: [0x00, 0xFF, 0xFE], count: 3)
        
        let retrieved: TestCacheModel? = try cacheService.retrieve(key: "invalid_cache")
        XCTAssertNil(retrieved, "Invalid cache data should return nil gracefully")
    }
    
    // MARK: - Multiple Data Types Test
    
    func testCacheMultipleTypesIndependently() throws {
        let stringValue = "test string"
        let intValue = 123
        let doubleValue = 3.14
        let boolValue = true
        let arrayValue = ["a", "b", "c"]
        
        try cacheService.save(key: "string", value: stringValue)
        try cacheService.save(key: "int", value: intValue)
        try cacheService.save(key: "double", value: doubleValue)
        try cacheService.save(key: "bool", value: boolValue)
        try cacheService.save(key: "array", value: arrayValue)
        
        let retrievedString: String? = try cacheService.retrieve(key: "string")
        let retrievedInt: Int? = try cacheService.retrieve(key: "int")
        let retrievedDouble: Double? = try cacheService.retrieve(key: "double")
        let retrievedBool: Bool? = try cacheService.retrieve(key: "bool")
        let retrievedArray: [String]? = try cacheService.retrieve(key: "array")
        
        XCTAssertEqual(retrievedString, stringValue)
        XCTAssertEqual(retrievedInt, intValue)
        XCTAssertEqual(retrievedDouble, doubleValue)
        XCTAssertEqual(retrievedBool, boolValue)
        XCTAssertEqual(retrievedArray, arrayValue)
    }
    
    // MARK: - Overwrite Test
    
    func testOverwritingExistingCacheKey() throws {
        let originalModel = TestCacheModel(id: 1, name: "Original", timestamp: Date())
        let updatedModel = TestCacheModel(id: 2, name: "Updated", timestamp: Date())
        
        try cacheService.save(key: "model", value: originalModel)
        var retrieved: TestCacheModel? = try cacheService.retrieve(key: "model")
        XCTAssertEqual(retrieved?.name, "Original")
        
        try cacheService.save(key: "model", value: updatedModel)
        retrieved = try cacheService.retrieve(key: "model")
        XCTAssertEqual(retrieved?.name, "Updated")
    }
}
