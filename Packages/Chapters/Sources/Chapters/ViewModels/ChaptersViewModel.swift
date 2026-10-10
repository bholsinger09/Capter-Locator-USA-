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
            let chapters = ChapterData.sampleChapters
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


// MARK: - Pagination State Model
struct PaginationState: Codable {
    let currentPage: Int
    let itemsPerPage: Int
}
