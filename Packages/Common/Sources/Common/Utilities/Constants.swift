//
//  Constants.swift
//  Common
//
//  Application-wide constants
//

import Foundation

public struct AppConstants {
    /// API Configuration
    public struct API {
        public static let timeout: TimeInterval = 30.0
        public static let retryAttempts: Int = 3
    }
    
    /// Validation Rules
    public struct Validation {
        public static let minPasswordLength: Int = 8
        public static let maxNameLength: Int = 50
        public static let maxEmailLength: Int = 100
    }
    
    /// UI Constants
    public struct UI {
        public static let defaultCornerRadius: CGFloat = 12
        public static let defaultPadding: CGFloat = 16
        public static let smallPadding: CGFloat = 8
    }
    
    /// User Defaults Keys
    public struct UserDefaults {
        public static let lastLoggedInEmail = "lastLoggedInEmail"
        public static let userDataKey = "userData"
        public static let notificationPreferencesKey = "notificationPreferences"
    }
    
    /// State List (US)
    public static let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California",
        "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
        "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
        "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
        "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
        "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
        "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
        "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]
}
