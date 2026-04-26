//
//  NotificationPreferences.swift
//  SwiftChapterUSA_finder
//
//  Created on 4/26/26.
//

import Foundation

/// User's notification preferences
struct NotificationPreferences: Codable {
    // Event Reminders
    var eventReminders: Bool = true
    var reminder24Hours: Bool = true
    var reminder1Hour: Bool = true
    
    // Event Notifications
    var newEventNotifications: Bool = true
    var eventUpdates: Bool = true
    var rsvpConfirmations: Bool = true
    
    // Chapter Notifications
    var chapterAnnouncements: Bool = true
    var newChapterApprovals: Bool = false // Admin only
    
    // Blog Notifications
    var newBlogPosts: Bool = false
    
    // General Settings
    var soundEnabled: Bool = true
    var badgeEnabled: Bool = true
    
    /// Check if any notifications are enabled
    var hasAnyEnabled: Bool {
        eventReminders || newEventNotifications || eventUpdates ||
        rsvpConfirmations || chapterAnnouncements || newBlogPosts
    }
    
    /// Get summary of enabled notifications
    var enabledCount: Int {
        var count = 0
        if eventReminders { count += 1 }
        if newEventNotifications { count += 1 }
        if eventUpdates { count += 1 }
        if rsvpConfirmations { count += 1 }
        if chapterAnnouncements { count += 1 }
        if newBlogPosts { count += 1 }
        return count
    }
}
