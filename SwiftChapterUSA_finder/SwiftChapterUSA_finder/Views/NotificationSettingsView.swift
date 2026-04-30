//
//  NotificationSettingsView.swift
//  SwiftChapterUSA_finder
//
//  Created on 4/26/26.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Authorization Status Section
                authorizationSection
                
                // Event Reminders Section
                if viewModel.authorizationStatus == .authorized {
                    eventRemindersSection
                    
                    // Event Notifications Section
                    eventNotificationsSection
                    
                    // Chapter & Blog Section
                    otherNotificationsSection
                    
                    // General Settings Section
                    generalSettingsSection
                    
                    // Management Section
                    managementSection
                }
            }
            .navigationTitle("Notifications")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - Authorization Section
    
    private var authorizationSection: some View {
        Section {
            switch viewModel.authorizationStatus {
            case .notDetermined:
                notificationPrompt
                
            case .denied:
                deniedView
                
            case .authorized, .provisional, .ephemeral:
                authorizedView
                
            @unknown default:
                EmptyView()
            }
        } header: {
            Text("Notification Access")
        } footer: {
            Text("Allow notifications to receive event reminders, updates, and important announcements.")
        }
    }
    
    private var notificationPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .padding(.top, 8)
            
            Text("Enable Notifications")
                .font(.headline)
            
            Text("Stay updated with event reminders and important announcements")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await viewModel.requestPermissions()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Enable Notifications")
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private var deniedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Notifications Disabled")
                .font(.headline)
            
            Text("Please enable notifications in Settings to receive updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                viewModel.openAppSettings()
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private var authorizedView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text("Notifications Enabled")
                    .font(.headline)
                
                if viewModel.preferences.hasAnyEnabled {
                    Text("\(viewModel.preferences.enabledCount) types enabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("All notifications are off")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            Button("Test") {
                Task {
                    await viewModel.sendTestNotification()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    
    // MARK: - Event Reminders Section
    
    private var eventRemindersSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.preferences.eventReminders },
                set: { viewModel.toggleEventReminders($0) }
            )) {
                Label("Event Reminders", systemImage: "calendar.badge.clock")
            }
            
            if viewModel.preferences.eventReminders {
                Toggle(isOn: Binding(
                    get: { viewModel.preferences.reminder24Hours },
                    set: { viewModel.toggle24HourReminder($0) }
                )) {
                    HStack {
                        Text("24 Hours Before")
                        Spacer()
                        Text("Day before event")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 32)
                
                Toggle(isOn: Binding(
                    get: { viewModel.preferences.reminder1Hour },
                    set: { viewModel.toggle1HourReminder($0) }
                )) {
                    HStack {
                        Text("1 Hour Before")
                        Spacer()
                        Text("Just before event")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 32)
            }
        } header: {
            Text("Event Reminders")
        } footer: {
            Text("Receive reminders for events you've RSVP'd to")
        }
    }
    
    // MARK: - Event Notifications Section
    
    private var eventNotificationsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.preferences.newEventNotifications },
                set: { viewModel.toggleNewEventNotifications($0) }
            )) {
                Label("New Events", systemImage: "sparkles")
                    .badge(Text("NEW"))
            }
            
            Toggle(isOn: Binding(
                get: { viewModel.preferences.eventUpdates },
                set: { viewModel.toggleEventUpdates($0) }
            )) {
                Label("Event Updates", systemImage: "arrow.triangle.2.circlepath")
            }
            
            Toggle(isOn: Binding(
                get: { viewModel.preferences.rsvpConfirmations },
                set: { viewModel.toggleRSVPConfirmations($0) }
            )) {
                Label("RSVP Confirmations", systemImage: "checkmark.circle")
            }
        } header: {
            Text("Event Notifications")
        } footer: {
            Text("Stay informed about new events and changes to events you're attending")
        }
    }
    
    // MARK: - Other Notifications Section
    
    private var otherNotificationsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.preferences.chapterAnnouncements },
                set: { viewModel.toggleChapterAnnouncements($0) }
            )) {
                Label("Chapter Announcements", systemImage: "megaphone")
            }
            
            Toggle(isOn: Binding(
                get: { viewModel.preferences.newBlogPosts },
                set: { viewModel.toggleBlogPosts($0) }
            )) {
                Label("New Blog Posts", systemImage: "newspaper")
            }
        } header: {
            Text("Other Notifications")
        } footer: {
            Text("Get updates from your chapter and read the latest blog posts")
        }
    }
    
    // MARK: - General Settings Section
    
    private var generalSettingsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.preferences.soundEnabled },
                set: { viewModel.toggleSound($0) }
            )) {
                Label("Sound", systemImage: "speaker.wave.2")
            }
            
            Toggle(isOn: Binding(
                get: { viewModel.preferences.badgeEnabled },
                set: { viewModel.toggleBadge($0) }
            )) {
                Label("Badge Icon", systemImage: "app.badge")
            }
        } header: {
            Text("General Settings")
        } footer: {
            Text("Control how notifications appear")
        }
    }
    
    // MARK: - Management Section
    
    private var managementSection: some View {
        Section {
            HStack {
                Label("Pending Notifications", systemImage: "clock.badge")
                Spacer()
                Text("\(viewModel.pendingNotificationsCount)")
                    .foregroundColor(.secondary)
            }
            
            Button(role: .destructive) {
                viewModel.clearAllNotifications()
            } label: {
                Label("Clear All Notifications", systemImage: "trash")
            }
        } header: {
            Text("Management")
        } footer: {
            Text("Clear all scheduled and delivered notifications")
        }
    }
}

#Preview {
    NotificationSettingsView()
}
