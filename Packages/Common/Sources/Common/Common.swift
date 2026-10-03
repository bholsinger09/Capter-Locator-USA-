// Common Package - Foundation module
import Foundation

/// Common module provides shared types, protocols, and utilities
/// used across all feature packages in the SwiftChapterUSA application.

private struct CommonDebug {
    static let initialized: Void = {
        print("📦 [DEBUG] Common package initializing")
        return ()
    }()
}
