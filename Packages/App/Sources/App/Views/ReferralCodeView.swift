//
//  ReferralCodeView.swift
//  App
//
//  Created on October 18, 2026.
//  UI Refinements: October 18, 2026.
//

import SwiftUI
import Common
import Authentication

public struct ReferralCodeView: View {
    @ObservedObject var viewModel: ReferralViewModel
    @State private var showShareSheet = false
    @State private var showCopiedAlert = false
    @State private var qrAppeared = false
    @State private var shareButtonPressed = false
    @State private var showWelcomeOverlay = false
    @State private var showExpandedRecruitList = false
    
    public init(viewModel: ReferralViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Professional Gradient Header - Display Only (not clickable)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Grow the Movement")
                            .font(.system(.headline, design: .default))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Build your chapter community through personal referrals")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0),
                            Color(red: 0.0, green: 0.35, blue: 0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // QR Code Section
                    if let qrImage = viewModel.getQRImage() {

                        VStack(spacing: 16) {
                            // Section Header
                            HStack(spacing: 10) {
                                Image(systemName: "qrcode")
                                    .font(.system(.headline, design: .default))
                                    .foregroundColor(.accentColor)
                                
                                Text("Your Referral Code")
                                    .font(.system(.headline, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // QR Code Container
                            VStack(spacing: 20) {
                                VStack(spacing: 0) {
                                    Image(uiImage: qrImage)
                                        .interpolation(.none)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 240)
                                        .padding(24)
                                        .background(Color.white)
                                        .cornerRadius(14)
                                        .shadow(
                                            color: Color.black.opacity(0.08),
                                            radius: 12,
                                            x: 0,
                                            y: 6
                                        )
                                }
                                .scaleEffect(qrAppeared ? 1 : 0.85)
                                .opacity(qrAppeared ? 1 : 0)
                                .onAppear {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                        qrAppeared = true
                                    }
                                }
                                
                                // Descriptive Text
                                VStack(spacing: 8) {
                                    Text("Share this code with your network")
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("Anyone who scans this will be directed to download the app")
                                        .font(.system(.caption, design: .default))
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.center)
                                    
                                    if let code = viewModel.referralCode {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            
                                            Text("ID: \(code.uppercased())")
                                                .font(.system(.caption, design: .monospaced))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemBackground))
                                .shadow(
                                    color: Color.black.opacity(0.04),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .padding(.horizontal, 16)
                    } else {
                        // Generate QR Button
                        VStack(spacing: 20) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 44))
                                .foregroundColor(.accentColor)
                                .opacity(0.5)
                            
                            VStack(spacing: 8) {
                                Text("Create Your Referral Code")
                                    .font(.system(.headline, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Generate a unique QR code to start inviting friends to your chapter")
                                    .font(.system(.caption, design: .default))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                            }
                            
                            Button(action: {
                                showWelcomeOverlay = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "qrcode")
                                        .font(.system(.body, design: .default))
                                    Text("Generate Referral Code")
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemBackground))
                                .shadow(
                                    color: Color.black.opacity(0.04),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Share & Copy Action Buttons
                    if viewModel.referralCode != nil {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                // Share Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        shareButtonPressed = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showShareSheet = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            shareButtonPressed = false
                                        }
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .font(.system(.body, design: .default))
                                        Text("Share")
                                            .font(.system(.body, design: .default))
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(
                                        shareButtonPressed ?
                                        Color.accentColor.opacity(0.9) :
                                        Color.accentColor
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .scaleEffect(shareButtonPressed ? 0.96 : 1.0)
                                
                                // Copy Link Button
                                if viewModel.referralLink != nil {
                                    Button(action: {
                                        UIPasteboard.general.string = viewModel.referralLink
                                        showCopiedAlert = true
                                        
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                            showCopiedAlert = false
                                        }
                                    }) {
                                        HStack(spacing: 10) {
                                            Image(systemName: "doc.on.doc.fill")
                                                .font(.system(.body, design: .default))
                                            Text("Copy")
                                                .font(.system(.body, design: .default))
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            
                            // Copied Confirmation Toast
                            if showCopiedAlert {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(.body, design: .default))
                                        .foregroundColor(.green)
                                    
                                    Text("Link copied to clipboard")
                                        .font(.system(.caption, design: .default))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(
                                    Color.green.opacity(0.1)
                                )
                                .foregroundColor(.green)
                                .cornerRadius(8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                    
                    // People You've Invited Section
                    if !viewModel.recruits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header with Statistics
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(.headline, design: .default))
                                        .foregroundColor(.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Your Network")
                                            .font(.system(.headline, design: .default))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text("Friends who joined through your referral")
                                            .font(.system(.caption, design: .default))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(viewModel.recruits.count)")
                                            .font(.system(.headline, design: .default))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.accentColor)
                                        
                                        Text("recruit\(viewModel.recruits.count != 1 ? "s" : "")")
                                            .font(.system(.caption, design: .default))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                            
                            // Recruits List
                            VStack(spacing: 10) {
                                ForEach(Array(viewModel.recruits.prefix(5)), id: \.id) { recruit in
                                    RecruitRowView(recruit: recruit)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // View All Button (if more than 5)
                            if viewModel.recruits.count > 5 {
                                Button(action: { showExpandedRecruitList = true }) {
                                    HStack(spacing: 8) {
                                        Text("View all \(viewModel.recruits.count) members")
                                            .font(.system(.body, design: .default))
                                            .fontWeight(.semibold)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(.caption, design: .default))
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(12)
                                    .foregroundColor(.accentColor)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            Spacer()
                                .frame(height: 8)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemBackground))
                                .shadow(
                                    color: Color.black.opacity(0.04),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .padding(.horizontal, 16)
                    } else if viewModel.currentUser != nil {
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.accentColor)
                                .opacity(0.7)
                            
                            VStack(spacing: 8) {
                                Text("Ready to Grow Your Chapter?")
                                    .font(.system(.headline, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Generate your referral code to invite friends and strengthen your community")
                                    .font(.system(.caption, design: .default))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor.opacity(0.15),
                                            Color.accentColor.opacity(0.08)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .background(Color(.systemBackground))
                                .cornerRadius(14)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showShareSheet) {
            CustomShareView(
                shareText: viewModel.getShareText(),
                referralIcon: ReferralIconGenerator.generateTPIcon()
            )
        }
        .sheet(isPresented: $showExpandedRecruitList) {
            ExpandedRecruitListView(viewModel: viewModel)
        }
        .overlay(
            ReferralWelcomeOverlay(isPresented: $showWelcomeOverlay) {
                withAnimation {
                    viewModel.createPersonalReferralCode()
                }
            },
            alignment: .center
        )
        .allowsHitTesting(true)
    }
}
}

// MARK: - Recruit Row Component

struct RecruitRowView: View {
    let recruit: ReferralLink
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar with Initial
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.accentColor.opacity(0.3),
                            Color.accentColor.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(recruit.refereeName.prefix(1)).uppercased())
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recruit.refereeName)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(.caption2, design: .default))
                        .foregroundColor(.secondary)
                    
                    Text(recruit.joinDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status Badge
            StatusBadge(status: recruit.status)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .scaleEffect(isHovering ? 1.01 : 1.0)
    }
}

// MARK: - Status Badge Component

struct StatusBadge: View {
    let status: ReferralStatus
    
    var statusColor: Color {
        switch status {
        case .joined:
            return Color.green.opacity(0.2)
        case .active:
            return Color.blue.opacity(0.2)
        case .inactive:
            return Color.gray.opacity(0.2)
        }
    }
    
    var statusTextColor: Color {
        switch status {
        case .joined:
            return Color.green
        case .active:
            return Color.blue
        case .inactive:
            return Color.gray
        }
    }
    
    var statusIcon: String {
        switch status {
        case .joined:
            return "star.circle.fill"
        case .active:
            return "checkmark.circle.fill"
        case .inactive:
            return "circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(statusTextColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor)
        .cornerRadius(6)
    }
}


#Preview {
    let referralService = ReferralService()
    let authManager = AuthenticationManager()
    let viewModel = ReferralViewModel(
        referralService: referralService,
        authenticationManager: authManager
    )
    
    return ReferralCodeView(viewModel: viewModel)
}
