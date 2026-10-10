// AppUI Package - Reusable UI components
import SwiftUI

private struct AppUIDebug {
    static let initialized: Void = {
        print("📦 [DEBUG] AppUI package initializing")
        return ()
    }()
}

// MARK: - Component Exports
// Button components
public typealias PrimaryButtonComponent = PrimaryButton
public typealias SecondaryButtonComponent = SecondaryButton
public typealias DangerButtonComponent = DangerButton

// Detail view components
public typealias DetailRowComponent = DetailRow
public typealias DetailHeaderCardComponent = DetailHeaderCard
public typealias FormSectionComponent = FormSection
