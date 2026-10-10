import Foundation

/// UserDefaults-based implementation of CacheService with automatic 24-hour expiration
public class UserDefaultsCacheService: CacheService {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// Cache expiration duration (24 hours in seconds)
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60
    
    /// Initializer with optional UserDefaults instance
    /// - Parameter userDefaults: The UserDefaults instance to use (defaults to standard)
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - CacheService Implementation
    
    public func save<T: Codable>(key: String, value: T) throws {
        do {
            let expiresAt = Date().addingTimeInterval(cacheExpirationInterval)
            let entry = CacheEntry(value: value, expiresAt: expiresAt)
            let encodedData = try encoder.encode(entry)
            userDefaults.set(encodedData, forKey: key)
        } catch let error as EncodingError {
            throw CacheServiceError.encodingFailed(error.localizedDescription)
        } catch {
            throw CacheServiceError.encodingFailed("Unknown encoding error: \(error.localizedDescription)")
        }
    }
    
    public func retrieve<T: Codable>(key: String, defaultValue: T? = nil) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return defaultValue
        }
        
        do {
            let entry = try decoder.decode(CacheEntry<T>.self, from: data)
            
            // Check if cache has expired
            if entry.expiresAt < Date() {
                userDefaults.removeObject(forKey: key)
                return defaultValue
            }
            
            return entry.value
        } catch is DecodingError {
            // Gracefully handle invalid cache data by removing it and returning default
            userDefaults.removeObject(forKey: key)
            return defaultValue
        } catch {
            // For any other error, remove the cache and return default
            userDefaults.removeObject(forKey: key)
            return defaultValue
        }
    }
    
    public func clear(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    public func clearAll() {
        let keys = userDefaults.dictionaryRepresentation().keys
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    public func isExpired(key: String) -> Bool {
        guard let data = userDefaults.data(forKey: key) else {
            return true
        }
        
        do {
            // We need to decode as AnyDecodable to check expiration without knowing the type
            let entry = try decoder.decode(GenericCacheEntry.self, from: data)
            return entry.expiresAt < Date()
        } catch {
            return true
        }
    }
}

/// Helper struct for checking expiration without knowing the generic type
private struct GenericCacheEntry: Codable {
    let expiresAt: Date
}
