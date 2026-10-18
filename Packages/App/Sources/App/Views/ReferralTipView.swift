//
//  ReferralTipView.swift
//  App
//
//  Created on October 18, 2026.
//

import SwiftUI

public struct ReferralTipView: View {
    @State private var showTip = true
    
    public init() {}
    
    public var body: some View {
        if showTip {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Pro Tip: Share Everywhere")
                            .font(.system(.body, design: .default))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Your referral link works seamlessly across Messages, Email, social media, and more.")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showTip = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(.body, design: .default))
                            .foregroundColor(.secondary)
                            .opacity(0.6)
                    }
                }
                .padding(14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.12),
                            Color.orange.opacity(0.06)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    ReferralTipView()
}
