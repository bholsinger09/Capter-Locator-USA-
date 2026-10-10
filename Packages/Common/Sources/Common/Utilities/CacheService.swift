import Foundation

/// Protocol defining a cache service with automatic expiration support
public protocol CacheService {
    /// Save a Codable value to the cache with automatic expiration after 24 hours
    /// - Parameters:
    ///   - key: The cache key
    ///   - value: The value to cache (must conform to Codable)
    /// - Throws: CacheServiceError if encoding fails
    func save<T: Codable>(key: String, value: T) throws
    
    /// Retrieve a cached value by key
    /// - Parameters:
    ///   - key: The cache key
    ///   - defaultValue: Optional default value to return if key doesn't exist or cache is expired
    /// - Returns: The cached value if found and not expired, nil or defaultValue otherwise
    /// - Throws: CacheServiceError if decoding fails
    func retrieve<T: Codable>(key: String, defaultValue: T?) throws -> T?
    
    /// Clear a specific cache entry
    /// - Parameter key: The cache key to clear
    func clear(key: String)
    
    /// Clear all cached data
    func clearAll()
    
    /// Check if a cache entry has expired
    /// - Parameter key: The cache key
    /// - Returns: True if the cache has expired or doesn't exist, false if valid
    func isExpired(key: String) -> Bool
}

/// Errors that can occur during cache operations
public enum CacheServiceError: LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let message):
            return "Failed to encode cache data: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode cache data: \(message)"
        case .invalidData:
            return "Cache contains invalid data"
        }
    }
}

/// Internal structure for storing cache entries with expiration metadata
struct CacheEntry<T: Codable>: Codable {
    let value: T
    let expiresAt: Date
}
