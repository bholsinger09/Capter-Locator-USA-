import SwiftUI

/// Centralized design system for consistent theming across the app
public enum AppTheme {
    // MARK: - Colors
    
    /// Primary brand colors
    public enum Colors {
        /// Primary action color (TPUSA Blue)
        public static let primary = Color(red: 0.0, green: 0.4, blue: 1.0)
        
        /// Accent/secondary color (Alert/Warning)
        public static let accent = Color(red: 1.0, green: 0.4, blue: 0.4)
        
        /// Success state (green)
        public static let success = Color.green
        
        /// Warning state (orange)
        public static let warning = Color.orange
        
        /// Error state (red)
        public static let error = Color.red
        
        /// Neutral backgrounds
        public static let background = Color(red: 0.98, green: 0.98, blue: 0.98)
        
        /// Secondary backgrounds (cards, sections)
        public static let secondaryBackground = Color.white
        
        /// Divider/border color
        public static let divider = Color.gray.opacity(0.2)
        
        /// Placeholder text color
        public static let placeholder = Color.gray.opacity(0.6)
    }
    
    // MARK: - Typography
    
    /// Font sizes and styles
    public enum Typography {
        public static let title1 = Font.system(.title, design: .default).weight(.bold)
        public static let title2 = Font.system(.title2, design: .default).weight(.bold)
        public static let title3 = Font.system(.title3, design: .default).weight(.bold)
        
        public static let headline = Font.system(.headline, design: .default).weight(.semibold)
        public static let subheadline = Font.system(.subheadline, design: .default)
        
        public static let body = Font.system(.body, design: .default)
        public static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
        
        public static let caption = Font.system(.caption, design: .default)
        public static let caption2 = Font.system(.caption2, design: .default)
        
        public static let footnote = Font.system(.footnote, design: .default)
    }
    
    // MARK: - Spacing
    
    /// Consistent spacing values
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let xxl: CGFloat = 24
        public static let xxxl: CGFloat = 32
    }
    
    // MARK: - Sizing
    
    /// Common component sizes
    public enum Sizing {
        public static let cornerRadius: CGFloat = 12
        public static let cornerRadiusSm: CGFloat = 8
        public static let cornerRadiusLg: CGFloat = 16
        
        public static let borderWidth: CGFloat = 1
        
        public static let buttonHeight: CGFloat = 48
        public static let buttonHeightSmall: CGFloat = 40
        
        public static let iconSizeSmall: CGFloat = 16
        public static let iconSizeMedium: CGFloat = 24
        public static let iconSizeLarge: CGFloat = 32
    }
    
    // MARK: - Shadows
    
    /// Shadow effects
    public enum Shadows {
        public static let small = Shadow(color: .black, radius: 2, x: 0, y: 1)
        public static let medium = Shadow(color: .black, radius: 4, x: 0, y: 2)
        public static let large = Shadow(color: .black, radius: 8, x: 0, y: 4)
        
        public struct Shadow {
            public let color: Color
            public let radius: CGFloat
            public let x: CGFloat
            public let y: CGFloat
        }
    }
    
    // MARK: - Animations
    
    /// Common animation timing
    public enum Animations {
        public static let fast: TimeInterval = 0.2
        public static let normal: TimeInterval = 0.3
        public static let slow: TimeInterval = 0.5
    }
}

// MARK: - Theme View Modifier

/// Extension to apply theme defaults consistently
public extension View {
    func themedBackground() -> some View {
        self.background(AppTheme.Colors.background)
    }
    
    func themedCard() -> some View {
        self
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.Sizing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Sizing.cornerRadius)
                    .stroke(AppTheme.Colors.divider, lineWidth: AppTheme.Sizing.borderWidth)
            )
    }
    
    func themedButtonStyle() -> some View {
        self
            .frame(height: AppTheme.Sizing.buttonHeight)
            .cornerRadius(AppTheme.Sizing.cornerRadius)
            .font(AppTheme.Typography.bodyBold)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        // Title
        Text("Theme Preview")
            .font(AppTheme.Typography.title2)
            .foregroundColor(AppTheme.Colors.primary)
        
        // Color samples
        HStack(spacing: AppTheme.Spacing.md) {
            Circle()
                .fill(AppTheme.Colors.primary)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(AppTheme.Colors.success)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(AppTheme.Colors.warning)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(AppTheme.Colors.error)
                .frame(width: 40, height: 40)
        }
        
        // Spacing demo
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Card Example")
                .font(AppTheme.Typography.headline)
            
            Text("This demonstrates the themed card styling with consistent spacing and typography.")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
        }
        .themedCard()
        
        Spacer()
    }
    .padding(AppTheme.Spacing.lg)
    .themedBackground()
}
