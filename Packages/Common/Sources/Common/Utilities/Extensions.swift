//
//  Extensions.swift
//  Common
//
//  Common extensions for Foundation types
//

import Foundation

public extension String {
    /// Remove leading and trailing whitespace
    func trimmed() -> String {
        trimmingCharacters(in: .whitespaces)
    }
    
    /// Check if string is empty after trimming
    var isEmptyOrWhitespace: Bool {
        trimmed().isEmpty
    }
}

public extension Date {
    /// Get formatted date string (e.g., "Jan 15, 2024")
    func formatted(_ format: String = "MMM dd, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is in the future
    var isFuture: Bool {
        self > Date()
    }
}

public extension UUID {
    /// Create empty UUID (all zeros)
    static var empty: UUID {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
    }
}
