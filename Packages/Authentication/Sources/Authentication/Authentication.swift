// Authentication Package - User authentication and account management
import Foundation
import Combine
import SwiftUI
import Common

private struct AuthenticationDebug {
    static let initialized: Void = {
        print("📦 [DEBUG] Authentication package initializing")
        return ()
    }()
}

/// The Authentication package provides user registration, login, and account management
/// including support for traditional email/password auth and Sign in with Apple.
