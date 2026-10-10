import Foundation
import Combine
import Common

public class UniversitiesViewModel: ObservableObject {
    @Published public var loadingState: LoadingState<[University]> = .idle
    @Published public var universities: [University] = []
    @Published public var searchText: String = ""
    @Published public var selectedState: String = "All States"
    
    // MARK: - Pagination
    @Published public var currentPage: Int = 1
    @Published public var itemsPerPage: Int = 20
    
    // MARK: - Favorites
    @Published public var favoriteIds: Set<UUID> = []
    
    private let cacheService: CacheService
    private let favoritesService: FavoritesService
    private let cacheKey = "universities_cache"
    private let paginationCacheKey = "universities_pagination_state"
    private let favoritesKey = "universities_favorites"
    
    public init(cacheService: CacheService? = nil, favoritesService: FavoritesService? = nil) {
        if let cacheService = cacheService {
            self.cacheService = cacheService
        } else {
            self.cacheService = UserDefaultsCacheService()
        }
        
        if let favoritesService = favoritesService {
            self.favoritesService = favoritesService
        } else {
            self.favoritesService = FavoritesServiceImpl(cacheService: self.cacheService)
        }
    }
    
    // MARK: - Loading Universities with LoadingState
    public func loadUniversities() async {
        await MainActor.run {
            self.loadingState = .loading
        }
        
        do {
            // Try to retrieve from cache first
            if let cached: [University] = try cacheService.retrieve(
                key: cacheKey,
                defaultValue: nil
            ) {
                await MainActor.run {
                    self.universities = cached
                    self.loadingState = .success(cached)
                }
                return
            }
            
            // If not in cache, use sample data
            let universities = University.samples
            try cacheService.save(key: cacheKey, value: universities)
            
            await MainActor.run {
                self.universities = universities
                self.loadingState = .success(universities)
            }
        } catch {
            let appError = error as? AppError ?? .unknown(error.localizedDescription)
            await MainActor.run {
                self.loadingState = .failure(appError)
            }
        }
    }
    
    // MARK: - Refresh
    public func refresh() async {
        cacheService.clear(key: cacheKey)
        await loadUniversities()
    }
    
    public var filteredUniversities: [University] {
        var filtered = universities
        
        if selectedState != "All States" {
            filtered = filtered.filter { $0.state == selectedState }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { university in
                university.name.localizedCaseInsensitiveContains(searchText) ||
                university.city.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    public var stateOptions: [String] {
        let states = Set(universities.map { $0.state })
        return ["All States"] + states.sorted()
    }
    
    // MARK: - Pagination Methods
    
    /// Returns the paginated universities for the current page
    public var paginatedUniversities: [University] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, universities.count)
        
        guard startIndex < universities.count else { return [] }
        return Array(universities[startIndex..<endIndex])
    }
    
    /// Whether there is more data available after the current page
    public var hasMoreData: Bool {
        let totalItems = universities.count
        let displayedItems = currentPage * itemsPerPage
        return displayedItems < totalItems
    }
    
    /// Total number of pages based on current universities
    public var totalPages: Int {
        guard universities.count > 0 else { return 0 }
        return (universities.count + itemsPerPage - 1) / itemsPerPage
    }
    
    /// Load the next page of universities
    public func loadNextPage() async {
        if hasMoreData {
            await MainActor.run {
                self.currentPage += 1
            }
        }
    }
    
    /// Reset pagination to the first page
    public func resetPagination() {
        currentPage = 1
    }
    
    // MARK: - Favorites Methods
    
    /// Load favorites from cache
    public func loadFavorites() async {
        await MainActor.run {
            let favorites = self.favoritesService.getFavorites(key: self.favoritesKey)
            self.favoriteIds = Set(favorites)
        }
    }
    
    /// Toggle favorite status for a university
    public func toggleFavorite(_ university: University) {
        let isNowFavorited = favoritesService.toggleFavorite(id: university.id, key: favoritesKey)
        
        if isNowFavorited {
            favoriteIds.insert(university.id)
        } else {
            favoriteIds.remove(university.id)
        }
    }
    
    /// Add a university to favorites
    public func addFavorite(_ university: University) {
        if favoritesService.addFavorite(id: university.id, key: favoritesKey) {
            favoriteIds.insert(university.id)
        }
    }
    
    /// Remove a university from favorites
    public func removeFavorite(_ university: University) {
        if favoritesService.removeFavorite(id: university.id, key: favoritesKey) {
            favoriteIds.remove(university.id)
        }
    }
    
    /// Check if a university is favorited
    public func isFavorited(_ university: University) -> Bool {
        return favoriteIds.contains(university.id)
    }
    
    /// Get count of favorite universities
    public var favoriteCount: Int {
        return favoriteIds.count
    }
    
    /// Get favorited universities
    public var favoritedUniversities: [University] {
        return universities.filter { favoriteIds.contains($0.id) }
    }
}

// MARK: - Sample Data
extension University {
    public static var samples: [University] {
        [
            University(
                name: "University of California, Los Angeles",
                state: "California",
                city: "Los Angeles",
                hasChapter: true,
                studentPopulation: 45000
            ),
            University(
                name: "University of Texas at Austin",
                state: "Texas",
                city: "Austin",
                hasChapter: true,
                studentPopulation: 52000
            ),
            University(
                name: "Stanford University",
                state: "California",
                city: "Palo Alto",
                hasChapter: true,
                studentPopulation: 17000
            ),
            University(
                name: "MIT",
                state: "Massachusetts",
                city: "Cambridge",
                hasChapter: false,
                studentPopulation: 11000
            ),
            University(
                name: "Harvard University",
                state: "Massachusetts",
                city: "Cambridge",
                hasChapter: true,
                studentPopulation: 23000
            )
        ]
    }
}
