//
//  NotificationSettingsView.swift
//  Notifications
//

import SwiftUI
import UserNotifications
import Common

public struct NotificationSettingsView: View {
    @StateObject private var manager = NotificationManager()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Notification Access")) {
                    switch manager.authorizationStatus {
                    case .authorized:
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Notifications Enabled")
                        }
                    case .denied:
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Notifications Disabled")
                        }
                    default:
                        Button("Enable Notifications") {
                            Task {
                                try? await manager.requestAuthorization()
                            }
                        }
                    }
                }
                
                if manager.authorizationStatus == .authorized {
                    Section(header: Text("Notification Types")) {
                        Toggle("Event Reminders", isOn: Binding(
                            get: { manager.preferences.eventReminders },
                            set: { manager.preferences.eventReminders = $0 }
                        ))
                        
                        Toggle("Event Updates", isOn: Binding(
                            get: { manager.preferences.eventUpdates },
                            set: { manager.preferences.eventUpdates = $0 }
                        ))
                        
                        Toggle("Chapter Announcements", isOn: Binding(
                            get: { manager.preferences.chapterAnnouncements },
                            set: { manager.preferences.chapterAnnouncements = $0 }
                        ))
                    }
                    
                    Section(header: Text("General")) {
                        Toggle("Sound", isOn: Binding(
                            get: { manager.preferences.soundEnabled },
                            set: { manager.preferences.soundEnabled = $0 }
                        ))
                        
                        Toggle("Badge", isOn: Binding(
                            get: { manager.preferences.badgeEnabled },
                            set: { manager.preferences.badgeEnabled = $0 }
                        ))
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        manager.savePreferences(manager.preferences)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
}
