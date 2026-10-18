//
//  ReferralWelcomeOverlay.swift
//  App
//
//  Created on October 18, 2026.
//

import SwiftUI

public struct ReferralWelcomeOverlay: View {
    @Binding var isPresented: Bool
    let onGetStarted: () -> Void
    
    public init(isPresented: Binding<Bool>, onGetStarted: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onGetStarted = onGetStarted
    }
    
    public var body: some View {
        if isPresented {
            ZStack {
                // Professional Backdrop
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                
                // Card
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Icon with Background
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.accentColor.opacity(0.9),
                                        Color.accentColor.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                        
                        // Title & Description
                        VStack(spacing: 10) {
                            Text("Create Your Referral Code")
                                .font(.system(.title2, design: .default))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Generate a unique QR code to invite friends to your chapter. Every friend who joins through your code is tracked in your network.")
                                .font(.system(.body, design: .default))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                        }
                    }
                    
                    // Benefits Section
                    VStack(spacing: 12) {
                        BenefitRow(
                            icon: "qrcode",
                            title: "Scannable QR Code",
                            description: "Friends can scan directly from their camera"
                        )
                        
                        BenefitRow(
                            icon: "square.and.arrow.up.fill",
                            title: "Share Everywhere",
                            description: "Works across Messages, Email, and social media"
                        )
                        
                        BenefitRow(
                            icon: "person.2.fill",
                            title: "Track Your Network",
                            description: "See all the friends you've invited"
                        )
                    }
                    .padding(16)
                    .background(Color(.systemGray6).opacity(0.6))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            onGetStarted()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPresented = false
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "qrcode")
                                    .font(.system(.body, design: .default))
                                Text("Generate Code")
                                    .font(.system(.body, design: .default))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPresented = false
                            }
                        }) {
                            Text("Not Right Now")
                                .font(.system(.body, design: .default))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(18)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 16,
                    x: 0,
                    y: 8
                )
                .padding(.horizontal, 24)
                .scaleEffect(isPresented ? 1 : 0.85)
                .opacity(isPresented ? 1 : 0)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        }
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(.title3, design: .default))
                .foregroundColor(.accentColor)
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        
        ReferralWelcomeOverlay(isPresented: .constant(true)) {
            print("Get started tapped")
        }
    }
}
