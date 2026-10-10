import Foundation

/// Protocol defining a favorites/bookmarks service
public protocol FavoritesService {
    /// Add a favorite by ID
    func addFavorite(id: UUID, key: String) -> Bool
    
    /// Remove a favorite by ID
    func removeFavorite(id: UUID, key: String) -> Bool
    
    /// Get all favorite IDs for a given key
    func getFavorites(key: String) -> [UUID]
    
    /// Check if an ID is favorited
    func isFavorited(id: UUID, key: String) -> Bool
    
    /// Toggle favorite status (add if not present, remove if present)
    func toggleFavorite(id: UUID, key: String) -> Bool
    
    /// Clear all favorites for a key
    func clearFavorites(key: String)
}

/// Default implementation of FavoritesService using CacheService
public class FavoritesServiceImpl: FavoritesService {
    private let cacheService: CacheService
    
    public init(cacheService: CacheService? = nil) {
        if let cacheService = cacheService {
            self.cacheService = cacheService
        } else {
            self.cacheService = UserDefaultsCacheService()
        }
    }
    
    public func addFavorite(id: UUID, key: String) -> Bool {
        var favorites = getFavorites(key: key)
        
        // Avoid duplicates
        if !favorites.contains(id) {
            favorites.append(id)
            do {
                try cacheService.save(key: key, value: favorites)
                return true
            } catch {
                return false
            }
        }
        
        return true
    }
    
    public func removeFavorite(id: UUID, key: String) -> Bool {
        var favorites = getFavorites(key: key)
        
        if let index = favorites.firstIndex(of: id) {
            favorites.remove(at: index)
            do {
                try cacheService.save(key: key, value: favorites)
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
    
    public func getFavorites(key: String) -> [UUID] {
        do {
            let favorites: [UUID]? = try cacheService.retrieve(key: key, defaultValue: nil)
            return favorites ?? []
        } catch {
            return []
        }
    }
    
    public func isFavorited(id: UUID, key: String) -> Bool {
        return getFavorites(key: key).contains(id)
    }
    
    public func toggleFavorite(id: UUID, key: String) -> Bool {
        if isFavorited(id: id, key: key) {
            return !removeFavorite(id: id, key: key)
        } else {
            return addFavorite(id: id, key: key)
        }
    }
    
    public func clearFavorites(key: String) {
        cacheService.clear(key: key)
    }
}
