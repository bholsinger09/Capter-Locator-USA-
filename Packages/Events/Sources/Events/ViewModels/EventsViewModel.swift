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
        // Clear any stale cache to start fresh
        self.cacheService.clear(key: self.cacheKey)
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
            
            // Start with empty events array
            let events: [Event] = []
            
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
    
    // MARK: - Add Event
    public func addEvent(_ event: Event) {
        var updatedEvents = events
        updatedEvents.append(event)
        events = updatedEvents
        
        do {
            try cacheService.save(key: cacheKey, value: events)
        } catch {
            print("Error saving event: \(error)")
        }
    }
    
    // MARK: - Delete Event
    public func deleteEvents(at indexSet: IndexSet) {
        let sortedEvents = filteredEvents.sorted { $0.eventDate < $1.eventDate }
        for index in indexSet {
            if index < sortedEvents.count {
                let eventToDelete = sortedEvents[index]
                events.removeAll { $0.id == eventToDelete.id }
            }
        }
        
        do {
            try cacheService.save(key: cacheKey, value: events)
        } catch {
            print("Error saving events: \(error)")
        }
    }
    
    // MARK: - Update Event
    public func updateEvent(id: UUID, title: String, description: String, location: String, eventDate: Date) {
        if let index = events.firstIndex(where: { $0.id == id }) {
            events[index].title = title
            events[index].description = description
            events[index].location = location
            events[index].eventDate = eventDate
            
            do {
                try cacheService.save(key: cacheKey, value: events)
            } catch {
                print("Error saving event: \(error)")
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
