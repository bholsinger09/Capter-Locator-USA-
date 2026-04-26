//
//  EventManager.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import Foundation
import CloudKit
import Combine

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var myRSVPs: [EventRSVP] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    init() {
        container = CKContainer(identifier: "iCloud.ChapterFinder")
        publicDatabase = container.publicCloudDatabase
    }
    
    // MARK: - Event Operations
    
    /// Fetch all active events
    func fetchEvents() async {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let predicate = NSPredicate(format: "isActive == %d", 1)
        let query = CKQuery(recordType: "Event", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedEvents = allRecords.compactMap { Event.fromRecord($0) }
            
            await MainActor.run {
                self.events = fetchedEvents
                self.errorMessage = nil
            }
            
            print("✅ [EventManager] Fetched \(fetchedEvents.count) events")
        } catch {
            print("❌ [EventManager] Failed to fetch events: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to load events: \(error.localizedDescription)"
            }
        }
    }
    
    /// Fetch events for a specific date range
    func fetchEvents(from startDate: Date, to endDate: Date) async -> [Event] {
        let predicate = NSPredicate(format: "isActive == %d AND eventDate >= %@ AND eventDate <= %@", 1, startDate as NSDate, endDate as NSDate)
        let query = CKQuery(recordType: "Event", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedEvents = allRecords.compactMap { Event.fromRecord($0) }
            print("✅ [EventManager] Fetched \(fetchedEvents.count) events for date range")
            return fetchedEvents
        } catch {
            print("❌ [EventManager] Failed to fetch events: \(error)")
            return []
        }
    }
    
    /// Fetch events by state
    func fetchEvents(forState state: String) async -> [Event] {
        let predicate = NSPredicate(format: "isActive == %d AND state == %@", 1, state)
        let query = CKQuery(recordType: "Event", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedEvents = allRecords.compactMap { Event.fromRecord($0) }
            print("✅ [EventManager] Fetched \(fetchedEvents.count) events for \(state)")
            return fetchedEvents
        } catch {
            print("❌ [EventManager] Failed to fetch events: \(error)")
            return []
        }
    }
    
    /// Create a new event
    func createEvent(_ event: Event) async throws {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        print("📤 [EventManager] Creating new event: \(event.title)")
        
        let record = event.toRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ [EventManager] Successfully created event: \(savedRecord.recordID.recordName)")
            
            if let savedEvent = Event.fromRecord(savedRecord) {
                await MainActor.run {
                    self.events.append(savedEvent)
                    self.events.sort { $0.eventDate < $1.eventDate }
                    self.errorMessage = nil
                }
            }
        } catch {
            print("❌ [EventManager] Failed to create event: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to create event: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Update an existing event
    func updateEvent(_ event: Event) async throws {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        print("📤 [EventManager] Updating event: \(event.title)")
        
        let record = event.toRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ [EventManager] Successfully updated event")
            
            if let updatedEvent = Event.fromRecord(savedRecord) {
                await MainActor.run {
                    if let index = self.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                        self.events[index] = updatedEvent
                    }
                    self.errorMessage = nil
                }
            }
        } catch {
            print("❌ [EventManager] Failed to update event: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to update event: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Delete an event
    func deleteEvent(_ event: Event) async throws {
        guard let recordName = event.recordName else {
            throw NSError(domain: "EventManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Event has no record name"])
        }
        
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        print("📤 [EventManager] Deleting event: \(event.title)")
        
        let recordID = CKRecord.ID(recordName: recordName)
        
        do {
            _ = try await publicDatabase.deleteRecord(withID: recordID)
            print("✅ [EventManager] Successfully deleted event")
            
            await MainActor.run {
                self.events.removeAll { $0.id == event.id }
                self.errorMessage = nil
            }
        } catch {
            print("❌ [EventManager] Failed to delete event: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - RSVP Operations
    
    /// Fetch user's RSVPs
    func fetchMyRSVPs(userEmail: String) async {
        let predicate = NSPredicate(format: "userEmail == %@", userEmail)
        let query = CKQuery(recordType: "EventRSVP", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "rsvpDate", ascending: false)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedRSVPs = allRecords.compactMap { EventRSVP.fromRecord($0) }
            
            await MainActor.run {
                self.myRSVPs = fetchedRSVPs
            }
            
            print("✅ [EventManager] Fetched \(fetchedRSVPs.count) RSVPs for user")
        } catch {
            print("❌ [EventManager] Failed to fetch RSVPs: \(error)")
        }
    }
    
    /// Check if user has RSVP'd to an event
    func hasRSVP(eventID: UUID, userEmail: String) async -> EventRSVP? {
        let predicate = NSPredicate(format: "eventID == %@ AND userEmail == %@", eventID.uuidString, userEmail)
        let query = CKQuery(recordType: "EventRSVP", predicate: predicate)
        
        do {
            let (records, _) = try await fetchRecordsWithCursor(query: query, cursor: nil)
            return records.compactMap { EventRSVP.fromRecord($0) }.first
        } catch {
            print("❌ [EventManager] Failed to check RSVP: \(error)")
            return nil
        }
    }
    
    /// Create an RSVP
    func createRSVP(_ rsvp: EventRSVP, for event: Event) async throws {
        print("📤 [EventManager] Creating RSVP for event: \(event.title)")
        
        let record = rsvp.toRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ [EventManager] Successfully created RSVP")
            
            // Update event RSVP count
            var updatedEvent = event
            updatedEvent.rsvpCount += rsvp.guestCount
            try await updateEvent(updatedEvent)
            
            if let savedRSVP = EventRSVP.fromRecord(savedRecord) {
                await MainActor.run {
                    self.myRSVPs.insert(savedRSVP, at: 0)
                }
            }
        } catch {
            print("❌ [EventManager] Failed to create RSVP: \(error)")
            throw error
        }
    }
    
    /// Cancel an RSVP
    func cancelRSVP(_ rsvp: EventRSVP, for event: Event) async throws {
        guard let recordName = rsvp.recordName else {
            throw NSError(domain: "EventManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "RSVP has no record name"])
        }
        
        print("📤 [EventManager] Cancelling RSVP")
        
        let recordID = CKRecord.ID(recordName: recordName)
        
        do {
            _ = try await publicDatabase.deleteRecord(withID: recordID)
            print("✅ [EventManager] Successfully cancelled RSVP")
            
            // Update event RSVP count
            var updatedEvent = event
            updatedEvent.rsvpCount = max(0, updatedEvent.rsvpCount - rsvp.guestCount)
            try await updateEvent(updatedEvent)
            
            await MainActor.run {
                self.myRSVPs.removeAll { $0.id == rsvp.id }
            }
        } catch {
            print("❌ [EventManager] Failed to cancel RSVP: \(error)")
            throw error
        }
    }
    
    /// Fetch RSVPs for an event (for organizers)
    func fetchRSVPs(forEvent eventID: UUID) async -> [EventRSVP] {
        let predicate = NSPredicate(format: "eventID == %@", eventID.uuidString)
        let query = CKQuery(recordType: "EventRSVP", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "rsvpDate", ascending: true)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let rsvps = allRecords.compactMap { EventRSVP.fromRecord($0) }
            print("✅ [EventManager] Fetched \(rsvps.count) RSVPs for event")
            return rsvps
        } catch {
            print("❌ [EventManager] Failed to fetch RSVPs: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchRecordsWithCursor(query: CKQuery, cursor: CKQueryOperation.Cursor?) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        let (matchResults, nextCursor): ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?)
        
        if let cursor = cursor {
            (matchResults, nextCursor) = try await publicDatabase.records(continuingMatchFrom: cursor)
        } else {
            (matchResults, nextCursor) = try await publicDatabase.records(matching: query)
        }
        
        // Extract successful records from results
        let records = matchResults.compactMap { (_, result) -> CKRecord? in
            try? result.get()
        }
        
        return (records, nextCursor)
    }
    
    /// Get upcoming events (next 30 days)
    func getUpcomingEvents(limit: Int = 10) -> [Event] {
        let now = Date()
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        
        return events
            .filter { $0.eventDate >= now && $0.eventDate <= thirtyDaysFromNow }
            .sorted { $0.eventDate < $1.eventDate }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get events happening today
    func getTodaysEvents() -> [Event] {
        events.filter { $0.isToday }
    }
    
    /// Search events
    func searchEvents(query: String) -> [Event] {
        guard !query.isEmpty else { return events }
        
        let lowercasedQuery = query.lowercased()
        return events.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.description.lowercased().contains(lowercasedQuery) ||
            $0.chapterName.lowercased().contains(lowercasedQuery) ||
            $0.location.lowercased().contains(lowercasedQuery) ||
            $0.tags.contains(where: { $0.lowercased().contains(lowercasedQuery) })
        }
    }
}
