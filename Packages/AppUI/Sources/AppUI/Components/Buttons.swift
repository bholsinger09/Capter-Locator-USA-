import SwiftUI

/// Primary action button with consistent styling
public struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

/// Secondary action button
public struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
    }
}

/// Danger/destructive action button
public struct DangerButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.red.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: 16) {
        PrimaryButton("Primary Action", icon: "checkmark") {
            print("Tapped")
        }
        
        PrimaryButton("Without Icon") {
            print("Tapped")
        }
    }
    .padding()
}

#Preview("Secondary & Danger") {
    VStack(spacing: 16) {
        SecondaryButton("Cancel", icon: "xmark") {
            print("Tapped")
        }
        
        DangerButton("Delete", icon: "trash") {
            print("Tapped")
        }
    }
    .padding()
}
