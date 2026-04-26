//
//  EventsViewModel.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import Foundation
import Combine

@MainActor
class EventsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedState = "All States"
    @Published var selectedEventType: Event.EventType?
    @Published var selectedDate: Date = Date()
    @Published var showPastEvents = false
    @Published var viewMode: ViewMode = .list
    @Published var showingCreateEvent = false
    
    private let eventManager: EventManager
    private let authManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    enum ViewMode {
        case list
        case calendar
        case map
    }
    
    init(eventManager: EventManager, authManager: AuthenticationManager) {
        self.eventManager = eventManager
        self.authManager = authManager
        
        // Auto-refresh when events change
        eventManager.$events
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var filteredEvents: [Event] {
        var events = eventManager.events
        
        // Filter by active status
        events = events.filter { $0.isActive }
        
        // Filter by past/future
        if !showPastEvents {
            events = events.filter { !$0.isPast }
        }
        
        // Filter by state
        if selectedState != "All States" {
            events = events.filter { $0.state == selectedState }
        }
        
        // Filter by event type
        if let eventType = selectedEventType {
            events = events.filter { $0.eventType == eventType }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            events = eventManager.searchEvents(query: searchText)
            
            // Reapply filters after search
            if selectedState != "All States" {
                events = events.filter { $0.state == selectedState }
            }
            if let eventType = selectedEventType {
                events = events.filter { $0.eventType == eventType }
            }
            if !showPastEvents {
                events = events.filter { !$0.isPast }
            }
        }
        
        return events.sorted { $0.eventDate < $1.eventDate }
    }
    
    var upcomingEvents: [Event] {
        eventManager.getUpcomingEvents(limit: 10)
    }
    
    var todaysEvents: [Event] {
        eventManager.getTodaysEvents()
    }
    
    var myUpcomingRSVPs: [EventRSVP] {
        eventManager.myRSVPs.filter { rsvp in
            if let event = eventManager.events.first(where: { $0.id == rsvp.eventID }) {
                return !event.isPast && rsvp.status == .confirmed
            }
            return false
        }
    }
    
    var hasEvents: Bool {
        !filteredEvents.isEmpty
    }
    
    var isLoading: Bool {
        eventManager.isLoading
    }
    
    var errorMessage: String? {
        eventManager.errorMessage
    }
    
    // MARK: - Actions
    
    func loadEvents() async {
        await eventManager.fetchEvents()
        if let userEmail = authManager.currentUser?.email {
            await eventManager.fetchMyRSVPs(userEmail: userEmail)
        }
    }
    
    func refreshEvents() async {
        await loadEvents()
    }
    
    func clearFilters() {
        searchText = ""
        selectedState = "All States"
        selectedEventType = nil
        showPastEvents = false
    }
    
    func createEvent(_ event: Event) async throws {
        try await eventManager.createEvent(event)
    }
    
    func updateEvent(_ event: Event) async throws {
        try await eventManager.updateEvent(event)
    }
    
    func deleteEvent(_ event: Event) async throws {
        try await eventManager.deleteEvent(event)
    }
    
    func rsvpToEvent(_ event: Event, guestCount: Int = 1, notes: String? = nil) async throws {
        guard let user = authManager.currentUser else {
            throw NSError(domain: "EventsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        // Check if already RSVP'd
        if let _ = await eventManager.hasRSVP(eventID: event.id, userEmail: user.email) {
            throw NSError(domain: "EventsViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "You've already RSVP'd to this event"])
        }
        
        // Check capacity
        if let capacity = event.capacity, event.rsvpCount + guestCount > capacity {
            throw NSError(domain: "EventsViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Event is full"])
        }
        
        let rsvp = EventRSVP(
            eventID: event.id,
            eventTitle: event.title,
            userEmail: user.email,
            userName: user.fullName,
            status: .confirmed,
            guestCount: guestCount,
            notes: notes
        )
        
        try await eventManager.createRSVP(rsvp, for: event)
        
        // Schedule event reminders
        let notificationManager = NotificationManager.shared
        try await notificationManager.scheduleEventReminders(for: event, userRSVP: rsvp)
        
        // Send RSVP confirmation notification
        try await notificationManager.sendRSVPConfirmation(for: event, guestCount: guestCount)
        
        // Subscribe to event updates
        try await notificationManager.subscribeToEventUpdates(eventID: event.id.uuidString)
    }
    
    func cancelRSVP(_ rsvp: EventRSVP) async throws {
        guard let event = eventManager.events.first(where: { $0.id == rsvp.eventID }) else {
            throw NSError(domain: "EventsViewModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "Event not found"])
        }
        
        try await eventManager.cancelRSVP(rsvp, for: event)
        
        // Cancel event reminders
        let notificationManager = NotificationManager.shared
        await notificationManager.cancelEventReminders(eventID: event.id.uuidString)
        
        // Unsubscribe from event updates
        await notificationManager.unsubscribeFromEventUpdates(eventID: event.id.uuidString)
    }
    
    func hasUserRSVP(for event: Event) -> EventRSVP? {
        guard let userEmail = authManager.currentUser?.email else { return nil }
        return eventManager.myRSVPs.first { $0.eventID == event.id && $0.userEmail == userEmail }
    }
    
    func getEventsByMonth(year: Int, month: Int) -> [Event] {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        
        guard let startDate = Calendar.current.date(from: dateComponents),
              let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            return []
        }
        
        return filteredEvents.filter { event in
            event.eventDate >= startDate && event.eventDate <= endDate
        }
    }
    
    func getEventsForDate(_ date: Date) -> [Event] {
        filteredEvents.filter { event in
            Calendar.current.isDate(event.eventDate, inSameDayAs: date)
        }
    }
    
    // MARK: - Helper Methods
    
    func canCreateEvent() -> Bool {
        // In a real app, you'd check if user is a chapter admin
        // For now, anyone can create events
        return authManager.currentUser != nil
    }
    
    func canEditEvent(_ event: Event) -> Bool {
        guard let userEmail = authManager.currentUser?.email else { return false }
        return event.createdBy == userEmail
    }
}
