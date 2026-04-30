//
//  EventsView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel: EventsViewModel
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedEvent: Event?
    @State private var showingEventDetail = false
    
    init(eventManager: EventManager, authManager: AuthenticationManager) {
        _viewModel = StateObject(wrappedValue: EventsViewModel(eventManager: eventManager, authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.filteredEvents.isEmpty {
                    ProgressView("Loading events...")
                } else if !viewModel.hasEvents && viewModel.searchText.isEmpty {
                    emptyStateView
                } else {
                    eventsListView
                }
            }
            .navigationTitle("Events")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    viewModeMenu
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.canCreateEvent() {
                        Button(action: {
                            viewModel.showingCreateEvent = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    viewModeMenu
                }
                
                ToolbarItem(placement: .automatic) {
                    if viewModel.canCreateEvent() {
                        Button(action: {
                            viewModel.showingCreateEvent = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                #endif
            }
            .refreshable {
                await viewModel.refreshEvents()
            }
            .task {
                await viewModel.loadEvents()
            }
            .sheet(isPresented: $viewModel.showingCreateEvent) {
                CreateEventView(eventManager: viewModel, authManager: authManager)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Events List
    
    private var eventsListView: some View {
        VStack(spacing: 0) {
            // Filters
            filterBar
            
            // My RSVPs section if user has upcoming RSVPs
            if !viewModel.myUpcomingRSVPs.isEmpty {
                myRSVPsSection
            }
            
            // Events List
            if viewModel.filteredEvents.isEmpty {
                noResultsView
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(groupedEvents.keys.sorted(), id: \.self) { dateKey in
                            eventSection(for: dateKey, events: groupedEvents[dateKey] ?? [])
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // Group events by date
    private var groupedEvents: [String: [Event]] {
        Dictionary(grouping: viewModel.filteredEvents) { event in
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
            return formatter.string(from: event.eventDate)
        }
    }
    
    private func eventSection(for dateKey: String, events: [Event]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateKey)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(events) { event in
                EventRowView(event: event, hasRSVP: viewModel.hasUserRSVP(for: event) != nil)
                    .onTapGesture {
                        selectedEvent = event
                    }
            }
        }
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search events...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(width: 200)
                
                // State filter
                Menu {
                    Picker("State", selection: $viewModel.selectedState) {
                        Text("All States").tag("All States")
                        ForEach(USStates.allStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedState)
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedState != "All States" ? Color.blue : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.selectedState != "All States" ? .white : .primary)
                    .cornerRadius(8)
                }
                
                // Event type filter
                Menu {
                    Button("All Types") {
                        viewModel.selectedEventType = nil
                    }
                    ForEach(Event.EventType.allCases, id: \.self) { type in
                        Button(action: {
                            viewModel.selectedEventType = type
                        }) {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                } label: {
                    HStack {
                        if let eventType = viewModel.selectedEventType {
                            Image(systemName: eventType.icon)
                            Text(eventType.rawValue)
                        } else {
                            Text("Event Type")
                        }
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedEventType != nil ? Color.blue : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.selectedEventType != nil ? .white : .primary)
                    .cornerRadius(8)
                }
                
                // Show past events toggle
                Button(action: {
                    viewModel.showPastEvents.toggle()
                }) {
                    HStack {
                        Image(systemName: viewModel.showPastEvents ? "checkmark.circle.fill" : "circle")
                        Text("Past Events")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(viewModel.showPastEvents ? Color.blue : Color.gray.opacity(0.1))
                    .foregroundColor(viewModel.showPastEvents ? .white : .primary)
                    .cornerRadius(8)
                }
                
                // Clear filters
                if viewModel.searchText != "" || viewModel.selectedState != "All States" || viewModel.selectedEventType != nil {
                    Button("Clear") {
                        viewModel.clearFilters()
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(white: 0.98))
    }
    
    // MARK: - My RSVPs Section
    
    private var myRSVPsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Upcoming Events")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.myUpcomingRSVPs) { rsvp in
                        if let event = viewModel.upcomingEvents.first(where: { $0.id == rsvp.eventID }) {
                            MyRSVPCard(event: event, rsvp: rsvp)
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Empty/No Results Views
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Events Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Be the first to create an event for your chapter!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if viewModel.canCreateEvent() {
                Button(action: {
                    viewModel.showingCreateEvent = true
                }) {
                    Label("Create Event", systemImage: "plus.circle.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Events Found")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Try adjusting your filters")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    // MARK: - View Mode Menu
    
    private var viewModeMenu: some View {
        Menu {
            Button(action: { viewModel.viewMode = .list }) {
                Label("List View", systemImage: "list.bullet")
            }
            Button(action: { viewModel.viewMode = .calendar }) {
                Label("Calendar View", systemImage: "calendar")
            }
            // Map view can be added later
            // Button(action: { viewModel.viewMode = .map }) {
            //     Label("Map View", systemImage: "map")
            // }
        } label: {
            Image(systemName: {
                switch viewModel.viewMode {
                case .list: return "list.bullet"
                case .calendar: return "calendar"
                case .map: return "map"
                }
            }())
        }
    }
}

// MARK: - Event Row View

struct EventRowView: View {
    let event: Event
    let hasRSVP: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Event type icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: event.eventType.icon)
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                    
                    if hasRSVP {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if event.isToday {
                        Text("TODAY")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                Text(event.chapterName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(event.formattedDate.components(separatedBy: " at ").last ?? "", systemImage: "clock")
                    
                    Label(event.location, systemImage: event.isVirtual ? "video" : "mappin")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Capacity info
                if let capacity = event.capacity {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                        Text("\(event.rsvpCount)/\(capacity)")
                        
                        if event.isFull {
                            Text("FULL")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        } else if let remaining = event.spotsRemaining, remaining <= 5 {
                            Text("\(remaining) left")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(white: 0.98))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - My RSVP Card

struct MyRSVPCard: View {
    let event: Event
    let rsvp: EventRSVP
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: event.eventType.icon)
                    .foregroundColor(.blue)
                Spacer()
                if event.isToday {
                    Text("TODAY")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(event.formattedDate.components(separatedBy: " at ").last ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Label(event.location, systemImage: event.isVirtual ? "video" : "mappin")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .frame(width: 200)
        .background(Color(white: 0.98))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Helper for states
struct USStates {
    static let allStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming"
    ]
}
