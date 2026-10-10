//
//  EventsViewModel.swift
//  Events
//

import Foundation
import Common
import Combine

public class EventsViewModel: ObservableObject {
    @Published public var loadingState: LoadingState<[Event]> = .idle
    @Published public var events: [Event] = []
    @Published public var selectedDate: Date = Date()
    @Published public var selectedChapter: String? = nil
    @Published public var searchText: String = ""
    
    private let cacheService: CacheService
    private let cacheKey = "events_cache"
    
    public init(cacheService: CacheService? = nil) {
        if let cacheService = cacheService {
            self.cacheService = cacheService
        } else {
            self.cacheService = UserDefaultsCacheService()
        }
    }
    
    // MARK: - Loading Events with LoadingState
    public func loadEvents() async {
        await MainActor.run {
            self.loadingState = .loading
        }
        
        do {
            // Try to retrieve from cache first
            if let cached: [Event] = try cacheService.retrieve(
                key: cacheKey,
                defaultValue: nil
            ) {
                await MainActor.run {
                    self.events = cached
                    self.loadingState = .success(cached)
                }
                return
            }
            
            // If not in cache, use sample data
            let events = [
                Event(
                    title: "Chapter Kickoff Meeting",
                    description: "Welcome new members",
                    eventDate: Date().addingTimeInterval(86400),
                    location: "Student Center",
                    organizerName: "John Smith",
                    capacity: 50
                )
            ]
            
            try cacheService.save(key: cacheKey, value: events)
            
            await MainActor.run {
                self.events = events
                self.loadingState = .success(events)
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
        await loadEvents()
    }
    
    public var filteredEvents: [Event] {
        var filtered = events
        
        if !searchText.isEmpty {
            filtered = filtered.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.eventDate < $1.eventDate }
    }
    
    public func loadSampleData() {
        Task {
            await loadEvents()
        }
    }
}
