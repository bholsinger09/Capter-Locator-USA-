//
//  EventsView.swift
//  Events
//

import SwiftUI
import Common
import AppUI

public struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    @State private var showAddEvent = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.loadingState {
                case .idle:
                    contentView
                case .loading:
                    LoadingView(message: "Loading events...")
                case .success:
                    contentView
                case .failure(let error):
                    ErrorView(
                        title: "Failed to Load Events",
                        message: error.errorDescription ?? "Unknown error",
                        retryAction: {
                            Task {
                                await viewModel.loadEvents()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddEvent = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventView(viewModel: viewModel, isPresented: $showAddEvent)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                Task {
                    await viewModel.loadEvents()
                }
            }
        }
    }
    
    private var contentView: some View {
        List {
            if viewModel.filteredEvents.isEmpty {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No Events")
                            .font(.headline)
                        Text("Tap the + button to create an event")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(20)
                }
            } else {
                Section(header: Text("Upcoming Events")) {
                    ForEach(viewModel.filteredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .fontWeight(.semibold)
                                Text(event.location)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: { indexSet in
                        viewModel.deleteEvents(at: indexSet)
                    })
                }
            }
        }
    }
}

public struct AddEventView: View {
    @ObservedObject var viewModel: EventsViewModel
    @Binding var isPresented: Bool
    
    @State private var eventName = ""
    @State private var place = ""
    @State private var details = ""
    @State private var showDetails = false
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Information")) {
                    TextField("Event Name", text: $eventName)
                    TextField("Place", text: $place)
                }
                
                Section {
                    Toggle("Add Details", isOn: $showDetails)
                }
                
                if showDetails {
                    Section(header: Text("Details")) {
                        TextEditor(text: $details)
                            .frame(height: 100)
                    }
                }
                
                Section {
                    Button(action: addEvent) {
                        Text("Create Event")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(eventName.isEmpty || place.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(eventName.isEmpty || place.isEmpty)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addEvent() {
        let newEvent = Event(
            title: eventName,
            description: details,
            eventDate: Date(),
            location: place,
            organizerName: "",
            capacity: nil
        )
        viewModel.addEvent(newEvent)
        isPresented = false
    }
}

public struct EventDetailView: View {
    let event: Event
    @ObservedObject var viewModel: EventsViewModel
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(event.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    infoRow(icon: "mappin", label: "Location", value: event.location)
                    if !event.description.isEmpty {
                        infoRow(icon: "doc.text", label: "Details", value: event.description)
                    }
                    if let capacity = event.capacity {
                        infoRow(icon: "person.2", label: "Capacity", value: "\(capacity)")
                    }
                }
                .padding()
                .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                .cornerRadius(12)
                
                if !event.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(event.description)
                            .font(.body)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Event Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
