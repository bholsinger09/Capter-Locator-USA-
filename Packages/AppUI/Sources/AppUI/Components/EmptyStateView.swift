//
//  EmptyStateView.swift
//  AppUI
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI

public struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionLabel: String
    
    public init(
        icon: String = "folder",
        title: String,
        message: String,
        action: (() -> Void)? = nil,
        actionLabel: String = "Try Again"
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
        self.actionLabel = actionLabel
    }
    
    public var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "No Results",
        message: "Try adjusting your search criteria"
    )
}
