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
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pro Tip: Share Everywhere")
                            .font(.headline)
                        Text("Referral links work in Messages, Email, Twitter, Instagram, and more!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showTip = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.15),
                            Color.orange.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    ReferralTipView()
}
