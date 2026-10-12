import SwiftUI

/// Reusable row component for displaying labeled values in detail views
public struct DetailRow: View {
    let label: String
    let value: String
    let icon: String?
    let valueColor: Color
    
    public init(
        label: String,
        value: String,
        icon: String? = nil,
        valueColor: Color = .primary
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.valueColor = valueColor
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(valueColor)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

/// Header card for detail views showing primary information
public struct DetailHeaderCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    
    public init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = .blue
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(iconColor)
                    .frame(width: 56, height: 56)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

/// Reusable form section wrapper
public struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    public init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                content
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Previews

#Preview("DetailRow") {
    VStack(spacing: 12) {
        DetailRow(label: "Chapter", value: "Texas State")
        Divider()
        DetailRow(
            label: "Status",
            value: "Active",
            icon: "checkmark.circle.fill",
            valueColor: .green
        )
        Divider()
        DetailRow(
            label: "Members",
            value: "245",
            icon: "person.3.fill"
        )
    }
    .padding()
}

#Preview("DetailHeaderCard") {
    VStack {
        DetailHeaderCard(
            title: "UCLA Chapter",
            subtitle: "Los Angeles, California",
            icon: "building.2.fill"
        )
        
        Spacer()
    }
    .padding()
}

#Preview("FormSection") {
    FormSection(title: "Contact Information") {
        VStack(spacing: 12) {
            Text("This is form content")
            Text("Multiple items can go here")
        }
    }
    .padding()
}
