//
//  ErrorView.swift
//  AppUI
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI

public struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    public init(title: String, message: String, retryAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let action = retryAction {
                Button(action: action) {
                    Text("Retry")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Button("Dismiss") {
                dismiss()
            }
            .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    ErrorView(title: "Error", message: "Something went wrong. Please try again.")
}
