//
//  CreateEventView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 26, 2026.
//

import SwiftUI

struct CreateEventView: View {
    @ObservedObject var eventManager: EventsViewModel
    @ObservedObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var eventDate = Date()
    @State private var hasEndTime = false
    @State private var endDate = Date()
    @State private var location = ""
    @State private var address = ""
    @State private var selectedChapter: Chapter?
    @State private var eventType: Event.EventType = .meeting
    @State private var isVirtual = false
    @State private var virtualMeetingURL = ""
    @State private var hasCapacity = false
    @State private var capacity = 50
    @State private var requiresRSVP = true
    @State private var tags = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCreating = false
    
    private var canSubmit: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        selectedChapter != nil &&
        (!isVirtual || !virtualMeetingURL.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section("Event Details") {
                    TextField("Event Title", text: $title)
                    
                    Picker("Event Type", selection: $eventType) {
                        ForEach(Event.EventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Event Description")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                        .padding(.top, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // Chapter Selection
                Section("Chapter") {
                    Picker("Select Chapter", selection: $selectedChapter) {
                        Text("Select a chapter...").tag(nil as Chapter?)
                        ForEach(chapterManager.chapters) { chapter in
                            Text(chapter.displayName).tag(chapter as Chapter?)
                        }
                    }
                    
                    if let chapter = selectedChapter {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                            Text("\(chapter.city), \(chapter.state)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Date & Time Section
                Section("Date & Time") {
                    DatePicker("Event Date & Time", selection: $eventDate, in: Date()...)
                        .datePickerStyle(.compact)
                    
                    Toggle("Has End Time", isOn: $hasEndTime)
                    
                    if hasEndTime {
                        DatePicker("End Date & Time", selection: $endDate, in: eventDate...)
                            .datePickerStyle(.compact)
                    }
                }
                
                // Location Section
                Section("Location") {
                    Toggle("Virtual Event", isOn: $isVirtual)
                    
                    if isVirtual {
                        TextField("Meeting Link (Zoom, Teams, etc.)", text: $virtualMeetingURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }
                    
                    TextField("Location Name", text: $location)
                        .placeholder(when: location.isEmpty) {
                            Text(isVirtual ? "e.g., Zoom Meeting" : "e.g., Student Center Room 204")
                        }
                    
                    if !isVirtual {
                        TextField("Full Address (Optional)", text: $address)
                            .textInputAutocapitalization(.words)
                    }
                }
                
                // RSVP Settings
                Section("RSVP Settings") {
                    Toggle("Require RSVP", isOn: $requiresRSVP)
                    
                    if requiresRSVP {
                        Toggle("Set Capacity Limit", isOn: $hasCapacity)
                        
                        if hasCapacity {
                            Stepper("Capacity: \(capacity)", value: $capacity, in: 1...500, step: 5)
                        }
                    }
                }
                
                // Additional Info
                Section("Additional Info") {
                    TextField("Tags (comma-separated)", text: $tags)
                        .textInputAutocapitalization(.words)
                    
                    Text("Examples: Networking, Fundraiser, Social")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Preview Section
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: eventType.icon)
                                .foregroundColor(.blue)
                            Text(title.isEmpty ? "Event Title" : title)
                                .fontWeight(.semibold)
                        }
                        
                        if let chapter = selectedChapter {
                            Text(chapter.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Label(formatDate(eventDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(location.isEmpty ? "Location" : location, systemImage: isVirtual ? "video" : "mappin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            await createEvent()
                        }
                    }
                    .disabled(!canSubmit || isCreating)
                }
            }
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isCreating {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView("Creating event...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func createEvent() async {
        guard let chapter = selectedChapter,
              let user = authManager.currentUser else {
            alertMessage = "Please select a chapter and ensure you're logged in"
            showingAlert = true
            return
        }
        
        isCreating = true
        
        // Parse tags
        let tagArray = tags
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let newEvent = Event(
            title: title,
            description: description,
            eventDate: eventDate,
            endDate: hasEndTime ? endDate : nil,
            location: location,
            address: address.isEmpty ? nil : address,
            latitude: chapter.latitude,
            longitude: chapter.longitude,
            chapterID: chapter.id,
            chapterName: chapter.displayName,
            state: chapter.state,
            university: chapter.university,
            organizerName: user.fullName,
            organizerEmail: user.email,
            capacity: hasCapacity ? capacity : nil,
            eventType: eventType,
            isVirtual: isVirtual,
            virtualMeetingURL: virtualMeetingURL.isEmpty ? nil : virtualMeetingURL,
            requiresRSVP: requiresRSVP,
            createdBy: user.email,
            tags: tagArray
        )
        
        do {
            try await eventManager.createEvent(newEvent)
            isCreating = false
            alertMessage = "Event created successfully! 🎉"
            showingAlert = true
        } catch {
            isCreating = false
            alertMessage = "Failed to create event: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Helper extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
