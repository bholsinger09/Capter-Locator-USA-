//
//  EventsView.swift
//  Events
//

import SwiftUI
import Common

public struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Upcoming Events")) {
                    if viewModel.filteredEvents.isEmpty {
                        Text("No events scheduled")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .fontWeight(.semibold)
                                    Text(event.location)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Events")
        }
    }
}

public struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(event.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    infoRow(icon: "calendar", label: "Date", value: event.eventDate.formatted())
                    infoRow(icon: "mappin", label: "Location", value: event.location)
                    if let capacity = event.capacity {
                        infoRow(icon: "person.2", label: "Capacity", value: "\(capacity)")
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
                Text(event.description)
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Event Details")
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(value)
            }
            Spacer()
        }
    }
}

#Preview {
    EventsView()
}
