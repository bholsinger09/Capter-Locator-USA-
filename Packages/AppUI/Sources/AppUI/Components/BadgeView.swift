//
//  BadgeView.swift
//  AppUI
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI

public struct BadgeView: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    public init(
        text: String,
        backgroundColor: Color = .blue,
        foregroundColor: Color = .white
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
    }
}

#Preview {
    HStack(spacing: 10) {
        BadgeView(text: "New")
        BadgeView(text: "Featured", backgroundColor: .orange)
        BadgeView(text: "Urgent", backgroundColor: .red)
    }
    .padding()
}
