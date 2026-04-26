//
//  EventDetailView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    @ObservedObject var viewModel: EventsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingRSVPSheet = false
    @State private var showingCancelAlert = false
    @State private var showingShareSheet = false
    @State private var guestCount = 1
    @State private var rsvpNotes = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    private var userRSVP: EventRSVP? {
        viewModel.hasUserRSVP(for: event)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with event type and date
                    headerSection
                    
                    Divider()
                    
                    // Event details
                    detailsSection
                    
                    Divider()
                    
                    // Location section
                    locationSection
                    
                    if let description = event.description.isEmpty ? nil : event.description {
                        Divider()
                        descriptionSection(description)
                    }
                    
                    Divider()
                    
                    // Organizer section
                    organizerSection
                    
                    // RSVP status section
                    if event.requiresRSVP {
                        Divider()
                        rsvpStatusSection
                    }
                    
                    // Tags
                    if !event.tags.isEmpty {
                        Divider()
                        tagsSection
                    }
                }
                .padding()
            }
            .navigationTitle(event.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingShareSheet = true }) {
                            Label("Share Event", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { addToCalendar() }) {
                            Label("Add to Calendar", systemImage: "calendar.badge.plus")
                        }
                        
                        if viewModel.canEditEvent(event) {
                            Button(action: { /* Edit event */ }) {
                                Label("Edit Event", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: { deleteEvent() }) {
                                Label("Delete Event", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !event.isPast {
                    rsvpButton
                        .padding()
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
                }
            }
            .sheet(isPresented: $showingRSVPSheet) {
                rsvpSheet
            }
            .alert("Confirm Cancellation", isPresented: $showingCancelAlert) {
                Button("Cancel RSVP", role: .destructive) {
                    Task {
                        await cancelRSVP()
                    }
                }
                Button("Keep RSVP", role: .cancel) {}
            } message: {
                Text("Are you sure you want to cancel your RSVP to this event?")
            }
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.eventType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(event.eventType.rawValue)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if event.isToday {
                    Text("TODAY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                } else if event.isPast {
                    Text("PAST EVENT")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            
            Text(event.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(event.chapterName)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(event.eventDate))
                        .font(.body)
                    
                    if let endDate = event.endDate {
                        Text("Until \(formatTime(endDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(formatTime(event.eventDate))
                    .font(.body)
            }
        }
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: event.isVirtual ? "video.fill" : "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.location)
                        .font(.body)
                    
                    if let address = event.address {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if event.isVirtual, let virtualURL = event.virtualMeetingURL {
                        Link("Join Virtual Meeting", destination: URL(string: virtualURL)!)
                            .font(.caption)
                    }
                }
            }
            
            // Mini map if coordinates available
            if let latitude = event.latitude, let longitude = event.longitude, !event.isVirtual {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), annotationItems: [event]) { event in
                    MapMarker(coordinate: CLLocationCoordinate2D(
                        latitude: event.latitude ?? 0,
                        longitude: event.longitude ?? 0
                    ), tint: .blue)
                }
                .frame(height: 150)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Description Section
    
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Organizer Section
    
    private var organizerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organizer")
                .font(.headline)
            
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.organizerName)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        if let url = URL(string: "mailto:\(event.organizerEmail)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(event.organizerEmail)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    // MARK: - RSVP Status Section
    
    private var rsvpStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendance")
                .font(.headline)
            
            if let capacity = event.capacity {
                HStack {
                    ProgressView(value: Double(event.rsvpCount), total: Double(capacity))
                        .progressViewStyle(LinearProgressViewStyle(tint: event.isFull ? .red : .blue))
                    
                    Text("\(event.rsvpCount)/\(capacity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if event.isFull {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Event is at full capacity")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } else if let remaining = event.spotsRemaining, remaining <= 5 {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                        Text("Only \(remaining) spot\(remaining == 1 ? "" : "s") remaining")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                    Text("\(event.rsvpCount) people going")
                        .font(.body)
                }
            }
            
            if let rsvp = userRSVP {
                HStack {
                    Image(systemName: rsvp.status.icon)
                        .foregroundColor(Color(rsvp.status.color))
                    Text("You're \(rsvp.status.rawValue.lowercased())")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if rsvp.guestCount > 1 {
                        Text("(+\(rsvp.guestCount - 1) guest\(rsvp.guestCount == 2 ? "" : "s"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(rsvp.status.color).opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(event.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    // MARK: - RSVP Button
    
    private var rsvpButton: some View {
        Group {
            if userRSVP != nil {
                Button(action: {
                    showingCancelAlert = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel RSVP")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            } else if event.isFull {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "person.fill.xmark")
                        Text("Event Full")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(true)
            } else {
                Button(action: {
                    showingRSVPSheet = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("RSVP to Event")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - RSVP Sheet
    
    private var rsvpSheet: some View {
        NavigationView {
            Form {
                Section("Guest Count") {
                    Stepper("\(guestCount) \(guestCount == 1 ? "person" : "people")", value: $guestCount, in: 1...10)
                    
                    if let remaining = event.spotsRemaining {
                        if guestCount > remaining {
                            Text("Only \(remaining) spot\(remaining == 1 ? "" : "s") available")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $rsvpNotes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Confirm RSVP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingRSVPSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        Task {
                            await confirmRSVP()
                        }
                    }
                    .disabled({
                        if let remaining = event.spotsRemaining {
                            return guestCount > remaining
                        }
                        return false
                    }())
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func confirmRSVP() async {
        do {
            try await viewModel.rsvpToEvent(event, guestCount: guestCount, notes: rsvpNotes.isEmpty ? nil : rsvpNotes)
            showingRSVPSheet = false
            alertMessage = "Successfully RSVP'd to \(event.title)!"
            showingAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func cancelRSVP() async {
        guard let rsvp = userRSVP else { return }
        
        do {
            try await viewModel.cancelRSVP(rsvp)
            alertMessage = "Your RSVP has been cancelled"
            showingAlert = true
        } catch {
            alertMessage = "Failed to cancel RSVP: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func addToCalendar() {
        // TODO: Implement calendar integration
        alertMessage = "Calendar integration coming soon!"
        showingAlert = true
    }
    
    private func deleteEvent() {
        Task {
            do {
                try await viewModel.deleteEvent(event)
                dismiss()
            } catch {
                alertMessage = "Failed to delete event: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
