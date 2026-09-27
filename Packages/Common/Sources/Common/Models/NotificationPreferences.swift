//
//  NotificationPreferences.swift
//  SwiftChapterUSA_finder
//
//  Created on 4/26/26.
//

import Foundation

/// User's notification preferences
public struct NotificationPreferences: Codable {
    // Event Reminders
    public var eventReminders: Bool = true
    public var reminder24Hours: Bool = true
    public var reminder1Hour: Bool = true
    
    // Event Notifications
    public var newEventNotifications: Bool = true
    public var eventUpdates: Bool = true
    public var rsvpConfirmations: Bool = true
    
    // Chapter Notifications
    public var chapterAnnouncements: Bool = true
    public var newChapterApprovals: Bool = false // Admin only
    
    // Blog Notifications
    public var newBlogPosts: Bool = false
    
    // General Settings
    public var soundEnabled: Bool = true
    public var badgeEnabled: Bool = true
    
    public init(
        eventReminders: Bool = true,
        reminder24Hours: Bool = true,
        reminder1Hour: Bool = true,
        newEventNotifications: Bool = true,
        eventUpdates: Bool = true,
        rsvpConfirmations: Bool = true,
        chapterAnnouncements: Bool = true,
        newChapterApprovals: Bool = false,
        newBlogPosts: Bool = false,
        soundEnabled: Bool = true,
        badgeEnabled: Bool = true
    ) {
        self.eventReminders = eventReminders
        self.reminder24Hours = reminder24Hours
        self.reminder1Hour = reminder1Hour
        self.newEventNotifications = newEventNotifications
        self.eventUpdates = eventUpdates
        self.rsvpConfirmations = rsvpConfirmations
        self.chapterAnnouncements = chapterAnnouncements
        self.newChapterApprovals = newChapterApprovals
        self.newBlogPosts = newBlogPosts
        self.soundEnabled = soundEnabled
        self.badgeEnabled = badgeEnabled
    }
    
    /// Check if any notifications are enabled
    public var hasAnyEnabled: Bool {
        eventReminders || newEventNotifications || eventUpdates ||
        rsvpConfirmations || chapterAnnouncements || newBlogPosts
    }
    
    /// Get summary of enabled notifications
    public var enabledCount: Int {
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
