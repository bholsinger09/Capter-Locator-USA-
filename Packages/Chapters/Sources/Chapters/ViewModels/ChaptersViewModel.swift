//
//  ChaptersViewModel.swift
//  Chapters
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation
import Combine
import Common

public class ChaptersViewModel: ObservableObject {
    @Published public var loadingState: LoadingState<[Chapter]> = .idle
    @Published public var chapters: [Chapter] = []
    @Published public var universities: [University] = []
    @Published public var searchText: String = ""
    @Published public var selectedState: String = "All States"
    @Published public var filterByDistance: Bool = false
    @Published public var userLocation: (latitude: Double, longitude: Double)?
    
    // MARK: - Pagination
    @Published public var currentPage: Int = 1
    @Published public var itemsPerPage: Int = 20
    
    // MARK: - Favorites
    @Published public var favoriteIds: Set<UUID> = []
    
    private let cacheService: CacheService
    private let favoritesService: FavoritesService
    private let cacheKey = "chapters_cache"
    private let paginationCacheKey = "chapters_pagination_state"
    private let favoritesKey = "chapters_favorites"
    
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
    
    // MARK: - Loading Chapters with LoadingState
    public func loadChapters() async {
        await MainActor.run {
            self.loadingState = .loading
        }
        
        do {
            // Try to retrieve from cache first
            if let cached: [Chapter] = try cacheService.retrieve(
                key: cacheKey,
                defaultValue: nil
            ) {
                await MainActor.run {
                    self.chapters = cached
                    self.loadingState = .success(cached)
                }
                return
            }
            
            // If not in cache, use sample data
            let chapters = Chapter.samples
            try cacheService.save(key: cacheKey, value: chapters)
            
            await MainActor.run {
                self.chapters = chapters
                self.loadingState = .success(chapters)
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
        await loadChapters()
    }
    
    public var filteredChapters: [Chapter] {
        var filtered = chapters
        
        if selectedState != "All States" {
            filtered = filtered.filter { $0.state == selectedState }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { chapter in
                chapter.name.localizedCaseInsensitiveContains(searchText) ||
                chapter.city.localizedCaseInsensitiveContains(searchText) ||
                (chapter.university?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    public var stateOptions: [String] {
        let states = Set(chapters.map { $0.state })
        return ["All States"] + states.sorted()
    }
    
    public func addChapter(_ chapter: Chapter) {
        chapters.append(chapter)
    }
    
    public func updateChapter(_ chapter: Chapter) {
        if let index = chapters.firstIndex(where: { $0.id == chapter.id }) {
            chapters[index] = chapter
        }
    }
    
    // MARK: - Pagination Methods
    
    /// Returns the paginated chapters for the current page
    public var paginatedChapters: [Chapter] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, chapters.count)
        
        guard startIndex < chapters.count else { return [] }
        return Array(chapters[startIndex..<endIndex])
    }
    
    /// Returns paginated chapters from filtered results
    public var paginatedChaptersFromFiltered: [Chapter] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let filtered = filteredChapters
        let endIndex = min(startIndex + itemsPerPage, filtered.count)
        
        guard startIndex < filtered.count else { return [] }
        return Array(filtered[startIndex..<endIndex])
    }
    
    /// Whether there is more data available after the current page
    public var hasMoreData: Bool {
        let totalItems = chapters.count
        let displayedItems = currentPage * itemsPerPage
        return displayedItems < totalItems
    }
    
    /// Total number of pages based on current chapters
    public var totalPages: Int {
        guard chapters.count > 0 else { return 0 }
        return (chapters.count + itemsPerPage - 1) / itemsPerPage
    }
    
    /// Load the next page of chapters
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
    
    /// Save pagination state to cache
    public func savePaginationState() async {
        let state = PaginationState(currentPage: currentPage, itemsPerPage: itemsPerPage)
        do {
            try cacheService.save(key: paginationCacheKey, value: state)
        } catch {
            // Silently fail - pagination is not critical
        }
    }
    
    /// Load pagination state from cache
    public func loadPaginationState() async -> Bool {
        do {
            if let state: PaginationState = try cacheService.retrieve(
                key: paginationCacheKey,
                defaultValue: nil
            ) {
                await MainActor.run {
                    self.currentPage = state.currentPage
                    self.itemsPerPage = state.itemsPerPage
                }
                return true
            }
        } catch {
            // Silently fail - use defaults
        }
        return false
    }
    
    // MARK: - Favorites Methods
    
    /// Load favorites from cache
    public func loadFavorites() async {
        await MainActor.run {
            let favorites = self.favoritesService.getFavorites(key: self.favoritesKey)
            self.favoriteIds = Set(favorites)
        }
    }
    
    /// Toggle favorite status for a chapter
    public func toggleFavorite(_ chapter: Chapter) {
        let isNowFavorited = favoritesService.toggleFavorite(id: chapter.id, key: favoritesKey)
        
        if isNowFavorited {
            favoriteIds.insert(chapter.id)
        } else {
            favoriteIds.remove(chapter.id)
        }
    }
    
    /// Add a chapter to favorites
    public func addFavorite(_ chapter: Chapter) {
        if favoritesService.addFavorite(id: chapter.id, key: favoritesKey) {
            favoriteIds.insert(chapter.id)
        }
    }
    
    /// Remove a chapter from favorites
    public func removeFavorite(_ chapter: Chapter) {
        if favoritesService.removeFavorite(id: chapter.id, key: favoritesKey) {
            favoriteIds.remove(chapter.id)
        }
    }
    
    /// Check if a chapter is favorited
    public func isFavorited(_ chapter: Chapter) -> Bool {
        return favoriteIds.contains(chapter.id)
    }
    
    /// Get count of favorite chapters
    public var favoriteCount: Int {
        return favoriteIds.count
    }
    
    /// Get favorited chapters
    public var favoritedChapters: [Chapter] {
        return chapters.filter { favoriteIds.contains($0.id) }
    }
}

// MARK: - Sample Data
extension Chapter {
    public static var samples: [Chapter] {
        [
            // Alabama
            Chapter(name: "Auburn Chapter", state: "Alabama", city: "Auburn", university: "Auburn University", presidentName: "Michael Brown", contactEmail: "auburn@tpusa.org", description: "Growing chapter at Auburn", memberCount: 85, dateEstablished: Date()),
            // Alaska
            Chapter(name: "Anchorage Chapter", state: "Alaska", city: "Anchorage", university: nil, presidentName: "David Wilson", contactEmail: "anchorage@tpusa.org", description: "Active in Alaska", memberCount: 45, dateEstablished: Date()),
            // Arizona
            Chapter(name: "ASU Chapter", state: "Arizona", city: "Tempe", university: "Arizona State University", presidentName: "Emily Garcia", contactEmail: "asu@tpusa.org", description: "One of the largest chapters", memberCount: 220, dateEstablished: Date()),
            // Arkansas
            Chapter(name: "University of Arkansas Chapter", state: "Arkansas", city: "Fayetteville", university: "University of Arkansas", presidentName: "James Taylor", contactEmail: "uark@tpusa.org", description: "Active Razorback chapter", memberCount: 78, dateEstablished: Date()),
            // California
            Chapter(name: "UCLA Chapter", state: "California", city: "Los Angeles", university: "UCLA", presidentName: "John Smith", contactEmail: "ucla@tpusa.org", description: "Largest chapter in California", memberCount: 350, dateEstablished: Date()),
            // Colorado
            Chapter(name: "University of Colorado Chapter", state: "Colorado", city: "Boulder", university: "University of Colorado Boulder", presidentName: "Sarah Lee", contactEmail: "cu@tpusa.org", description: "Strong chapter in Boulder", memberCount: 125, dateEstablished: Date()),
            // Connecticut
            Chapter(name: "Yale Chapter", state: "Connecticut", city: "New Haven", university: "Yale University", presidentName: "Christopher Davis", contactEmail: "yale@tpusa.org", description: "Chapter at Yale", memberCount: 95, dateEstablished: Date()),
            // Delaware
            Chapter(name: "University of Delaware Chapter", state: "Delaware", city: "Newark", university: "University of Delaware", presidentName: "Amanda Martinez", contactEmail: "udel@tpusa.org", description: "Growing chapter", memberCount: 65, dateEstablished: Date()),
            // Florida
            Chapter(name: "University of Florida Chapter", state: "Florida", city: "Gainesville", university: "University of Florida", presidentName: "Robert Johnson", contactEmail: "uf@tpusa.org", description: "Largest chapter in Florida", memberCount: 280, dateEstablished: Date()),
            // Georgia
            Chapter(name: "Georgia Tech Chapter", state: "Georgia", city: "Atlanta", university: "Georgia Tech", presidentName: "Jennifer White", contactEmail: "gatech@tpusa.org", description: "Strong tech student chapter", memberCount: 165, dateEstablished: Date()),
            // Hawaii
            Chapter(name: "University of Hawaii Chapter", state: "Hawaii", city: "Honolulu", university: "University of Hawaii", presidentName: "Daniel Kim", contactEmail: "uhawaii@tpusa.org", description: "Chapter in Hawaii", memberCount: 52, dateEstablished: Date()),
            // Idaho
            Chapter(name: "Boise State Chapter", state: "Idaho", city: "Boise", university: "Boise State University", presidentName: "Lisa Anderson", contactEmail: "boisestate@tpusa.org", description: "Active in Boise", memberCount: 68, dateEstablished: Date()),
            // Illinois
            Chapter(name: "Northwestern Chapter", state: "Illinois", city: "Evanston", university: "Northwestern University", presidentName: "Steven Brown", contactEmail: "northwestern@tpusa.org", description: "Chapter at Northwestern", memberCount: 110, dateEstablished: Date()),
            // Indiana
            Chapter(name: "Purdue Chapter", state: "Indiana", city: "West Lafayette", university: "Purdue University", presidentName: "Michelle Rodriguez", contactEmail: "purdue@tpusa.org", description: "Growing Purdue chapter", memberCount: 145, dateEstablished: Date()),
            // Iowa
            Chapter(name: "University of Iowa Chapter", state: "Iowa", city: "Iowa City", university: "University of Iowa", presidentName: "Kevin Nelson", contactEmail: "uiowa@tpusa.org", description: "Active Hawkeye chapter", memberCount: 92, dateEstablished: Date()),
            // Kansas
            Chapter(name: "University of Kansas Chapter", state: "Kansas", city: "Lawrence", university: "University of Kansas", presidentName: "Tracy Campbell", contactEmail: "ukansas@tpusa.org", description: "Chapter at Kansas", memberCount: 75, dateEstablished: Date()),
            // Kentucky
            Chapter(name: "University of Kentucky Chapter", state: "Kentucky", city: "Lexington", university: "University of Kentucky", presidentName: "Ryan Mitchell", contactEmail: "uky@tpusa.org", description: "Wildcat chapter", memberCount: 118, dateEstablished: Date()),
            // Louisiana
            Chapter(name: "LSU Chapter", state: "Louisiana", city: "Baton Rouge", university: "Louisiana State University", presidentName: "Jessica Moore", contactEmail: "lsu@tpusa.org", description: "Chapter at LSU", memberCount: 135, dateEstablished: Date()),
            // Maine
            Chapter(name: "University of Maine Chapter", state: "Maine", city: "Orono", university: "University of Maine", presidentName: "Nathan Hall", contactEmail: "umaine@tpusa.org", description: "Active in Maine", memberCount: 58, dateEstablished: Date()),
            // Maryland
            Chapter(name: "University of Maryland Chapter", state: "Maryland", city: "College Park", university: "University of Maryland", presidentName: "Ashley Green", contactEmail: "umd@tpusa.org", description: "Chapter in College Park", memberCount: 128, dateEstablished: Date()),
            // Massachusetts
            Chapter(name: "Harvard Chapter", state: "Massachusetts", city: "Cambridge", university: "Harvard University", presidentName: "Marcus King", contactEmail: "harvard@tpusa.org", description: "Chapter at Harvard", memberCount: 105, dateEstablished: Date()),
            // Michigan
            Chapter(name: "University of Michigan Chapter", state: "Michigan", city: "Ann Arbor", university: "University of Michigan", presidentName: "Lauren Wright", contactEmail: "umich@tpusa.org", description: "Large chapter in Michigan", memberCount: 175, dateEstablished: Date()),
            // Minnesota
            Chapter(name: "University of Minnesota Chapter", state: "Minnesota", city: "Minneapolis", university: "University of Minnesota", presidentName: "Jordan Lopez", contactEmail: "umn@tpusa.org", description: "Gopher chapter", memberCount: 142, dateEstablished: Date()),
            // Mississippi
            Chapter(name: "University of Mississippi Chapter", state: "Mississippi", city: "Oxford", university: "University of Mississippi", presidentName: "Brittany Hayes", contactEmail: "olemiss@tpusa.org", description: "Chapter at Ole Miss", memberCount: 87, dateEstablished: Date()),
            // Missouri
            Chapter(name: "University of Missouri Chapter", state: "Missouri", city: "Columbia", university: "University of Missouri", presidentName: "Derek Clark", contactEmail: "mizzou@tpusa.org", description: "Tiger chapter", memberCount: 152, dateEstablished: Date()),
            // Montana
            Chapter(name: "University of Montana Chapter", state: "Montana", city: "Missoula", university: "University of Montana", presidentName: "Heather Scott", contactEmail: "umontana@tpusa.org", description: "Chapter in Missoula", memberCount: 61, dateEstablished: Date()),
            // Nebraska
            Chapter(name: "University of Nebraska Chapter", state: "Nebraska", city: "Lincoln", university: "University of Nebraska", presidentName: "Andrew Martinez", contactEmail: "unl@tpusa.org", description: "Husker chapter", memberCount: 98, dateEstablished: Date()),
            // Nevada
            Chapter(name: "University of Nevada Chapter", state: "Nevada", city: "Las Vegas", university: "University of Nevada Las Vegas", presidentName: "Stephanie White", contactEmail: "unlv@tpusa.org", description: "Chapter in Las Vegas", memberCount: 73, dateEstablished: Date()),
            // New Hampshire
            Chapter(name: "Dartmouth Chapter", state: "New Hampshire", city: "Hanover", university: "Dartmouth College", presidentName: "Brandon Taylor", contactEmail: "dartmouth@tpusa.org", description: "Chapter at Dartmouth", memberCount: 89, dateEstablished: Date()),
            // New Jersey
            Chapter(name: "Rutgers Chapter", state: "New Jersey", city: "New Brunswick", university: "Rutgers University", presidentName: "Nicole Johnson", contactEmail: "rutgers@tpusa.org", description: "Chapter at Rutgers", memberCount: 115, dateEstablished: Date()),
            // New Mexico
            Chapter(name: "University of New Mexico Chapter", state: "New Mexico", city: "Albuquerque", university: "University of New Mexico", presidentName: "Carlos Rivera", contactEmail: "unm@tpusa.org", description: "Chapter in Albuquerque", memberCount: 66, dateEstablished: Date()),
            // New York
            Chapter(name: "NYU Chapter", state: "New York", city: "New York", university: "New York University", presidentName: "Victoria Anderson", contactEmail: "nyu@tpusa.org", description: "Major chapter in NYC", memberCount: 195, dateEstablished: Date()),
            // North Carolina
            Chapter(name: "UNC Chapel Hill Chapter", state: "North Carolina", city: "Chapel Hill", university: "University of North Carolina", presidentName: "Anthony Moore", contactEmail: "unc@tpusa.org", description: "Large chapter at UNC", memberCount: 188, dateEstablished: Date()),
            // North Dakota
            Chapter(name: "University of North Dakota Chapter", state: "North Dakota", city: "Grand Forks", university: "University of North Dakota", presidentName: "Katrina Olson", contactEmail: "und@tpusa.org", description: "Chapter in North Dakota", memberCount: 54, dateEstablished: Date()),
            // Ohio
            Chapter(name: "Ohio State Chapter", state: "Ohio", city: "Columbus", university: "Ohio State University", presidentName: "Kevin Hayes", contactEmail: "osu@tpusa.org", description: "Major Buckeye chapter", memberCount: 265, dateEstablished: Date()),
            // Oklahoma
            Chapter(name: "University of Oklahoma Chapter", state: "Oklahoma", city: "Norman", university: "University of Oklahoma", presidentName: "Samantha Green", contactEmail: "ou@tpusa.org", description: "Chapter at OU", memberCount: 127, dateEstablished: Date()),
            // Oregon
            Chapter(name: "University of Oregon Chapter", state: "Oregon", city: "Eugene", university: "University of Oregon", presidentName: "Eric Palmer", contactEmail: "uoregon@tpusa.org", description: "Duck chapter", memberCount: 104, dateEstablished: Date()),
            // Pennsylvania
            Chapter(name: "University of Pennsylvania Chapter", state: "Pennsylvania", city: "Philadelphia", university: "University of Pennsylvania", presidentName: "Rachel Stewart", contactEmail: "upenn@tpusa.org", description: "Chapter at Penn", memberCount: 132, dateEstablished: Date()),
            // Rhode Island
            Chapter(name: "Brown University Chapter", state: "Rhode Island", city: "Providence", university: "Brown University", presidentName: "Gregory Phillips", contactEmail: "brown@tpusa.org", description: "Chapter at Brown", memberCount: 72, dateEstablished: Date()),
            // South Carolina
            Chapter(name: "University of South Carolina Chapter", state: "South Carolina", city: "Columbia", university: "University of South Carolina", presidentName: "Megan Thompson", contactEmail: "usc@tpusa.org", description: "Gamecock chapter", memberCount: 141, dateEstablished: Date()),
            // South Dakota
            Chapter(name: "University of South Dakota Chapter", state: "South Dakota", city: "Vermillion", university: "University of South Dakota", presidentName: "Tyler Jackson", contactEmail: "usd@tpusa.org", description: "Chapter in South Dakota", memberCount: 59, dateEstablished: Date()),
            // Tennessee
            Chapter(name: "University of Tennessee Chapter", state: "Tennessee", city: "Knoxville", university: "University of Tennessee", presidentName: "Rachel Boyd", contactEmail: "utk@tpusa.org", description: "Volunteer chapter", memberCount: 162, dateEstablished: Date()),
            // Texas
            Chapter(name: "UT Austin Chapter", state: "Texas", city: "Austin", university: "University of Texas", presidentName: "Sarah Jones", contactEmail: "utaustin@tpusa.org", description: "Active chapter in the heart of Texas", memberCount: 250, dateEstablished: Date()),
            // Utah
            Chapter(name: "University of Utah Chapter", state: "Utah", city: "Salt Lake City", university: "University of Utah", presidentName: "Daniel Anderson", contactEmail: "uutah@tpusa.org", description: "Chapter in Salt Lake City", memberCount: 115, dateEstablished: Date()),
            // Vermont
            Chapter(name: "University of Vermont Chapter", state: "Vermont", city: "Burlington", university: "University of Vermont", presidentName: "Olivia Bennett", contactEmail: "uvm@tpusa.org", description: "Chapter at UVM", memberCount: 68, dateEstablished: Date()),
            // Virginia
            Chapter(name: "University of Virginia Chapter", state: "Virginia", city: "Charlottesville", university: "University of Virginia", presidentName: "Tyler Morris", contactEmail: "uva@tpusa.org", description: "Chapter at UVA", memberCount: 155, dateEstablished: Date()),
            // Washington
            Chapter(name: "University of Washington Chapter", state: "Washington", city: "Seattle", university: "University of Washington", presidentName: "Sophie Lee", contactEmail: "uw@tpusa.org", description: "Chapter at UW", memberCount: 138, dateEstablished: Date()),
            // West Virginia
            Chapter(name: "West Virginia University Chapter", state: "West Virginia", city: "Morgantown", university: "West Virginia University", presidentName: "Justin Barnes", contactEmail: "wvu@tpusa.org", description: "Chapter at WVU", memberCount: 99, dateEstablished: Date()),
            // Wisconsin
            Chapter(name: "University of Wisconsin Chapter", state: "Wisconsin", city: "Madison", university: "University of Wisconsin", presidentName: "Amanda Foster", contactEmail: "uw@tpusa.org", description: "Badger chapter", memberCount: 147, dateEstablished: Date()),
            // Wyoming
            Chapter(name: "University of Wyoming Chapter", state: "Wyoming", city: "Laramie", university: "University of Wyoming", presidentName: "Lucas Young", contactEmail: "uwyo@tpusa.org", description: "Chapter in Wyoming", memberCount: 71, dateEstablished: Date())
        ]
    }
}

// MARK: - Pagination State Model
struct PaginationState: Codable {
    let currentPage: Int
    let itemsPerPage: Int
}
