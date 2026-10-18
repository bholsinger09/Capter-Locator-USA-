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
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Card
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    // Icon
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                    
                    // Title
                    Text("Start Inviting Friends")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Description
                    Text("Create your personal referral code and share it with friends. When they sign up using your code, you'll see them in your profile.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Benefits
                VStack(spacing: 12) {
                    BenefitRow(
                        icon: "qrcode",
                        title: "QR Codes",
                        description: "Easy scanning from camera app"
                    )
                    
                    BenefitRow(
                        icon: "square.and.arrow.up",
                        title: "Share Everywhere",
                        description: "Messages, Email, Social Media"
                    )
                    
                    BenefitRow(
                        icon: "person.2",
                        title: "Track Growth",
                        description: "See who you've invited"
                    )
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Buttons
                VStack(spacing: 10) {
                    Button(action: {
                        onGetStarted()
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Generate QR Code")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Maybe Later")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 30)
            .scaleEffect(isPresented ? 1 : 0.8)
            .opacity(isPresented ? 1 : 0)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isPresented)
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
