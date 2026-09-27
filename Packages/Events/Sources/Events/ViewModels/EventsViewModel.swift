//
//  EventsViewModel.swift
//  Events
//

import Foundation
import Common
import Combine

public class EventsViewModel: ObservableObject {
    @Published public var events: [Event] = []
    @Published public var selectedDate: Date = Date()
    @Published public var searchText: String = ""
    
    public init() {
        loadSampleData()
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
        events = [
            Event(
                title: "Chapter Kickoff Meeting",
                description: "Welcome new members",
                eventDate: Date().addingTimeInterval(86400),
                location: "Student Center",
                organizerName: "John Smith",
                capacity: 50
            )
        ]
    }
}
