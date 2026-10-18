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
            // Gradient Header - Display Only (not clickable)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grow the Movement")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Invite friends to join your chapter")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.8),
                            Color.blue.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // QR Code Section
                    if let qrImage = viewModel.getQRImage() {

                        VStack(spacing: 16) {
                            // Header
                            HStack(spacing: 8) {
                                Image(systemName: "qrcode")
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                Text("Your Referral Code")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // QR Code
                            VStack(spacing: 16) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 240)
                                    .padding(20)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .scaleEffect(qrAppeared ? 1 : 0.8)
                                    .opacity(qrAppeared ? 1 : 0)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                            qrAppeared = true
                                        }
                                    }
                                
                                // Subtext
                                VStack(spacing: 6) {
                                    Text("Scan this QR code to invite friends")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if let code = viewModel.referralCode {
                                        Text("Code: \(code)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .monospaced()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        // Generate QR Button
                        VStack(spacing: 16) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 40))
                                .foregroundColor(.accentColor)
                                .opacity(0.6)
                            
                            VStack(spacing: 4) {
                                Text("No QR Code Yet")
                                    .font(.headline)
                                Text("Create your personal referral code to start inviting friends")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: {
                                showWelcomeOverlay = true
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
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Share & Copy Buttons
                    if viewModel.referralCode != nil {
                        HStack(spacing: 12) {
                            // Share Button
                            Button(action: {
                                withAnimation {
                                    shareButtonPressed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showShareSheet = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        shareButtonPressed = false
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up.fill")
                                    Text("Share")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(
                                    shareButtonPressed ?
                                    Color.accentColor.opacity(0.8) :
                                    Color.accentColor
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            // Copy Link Button
                            if viewModel.referralLink != nil {
                                Button(action: {
                                    UIPasteboard.general.string = viewModel.referralLink
                                    showCopiedAlert = true
                                    
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showCopiedAlert = false
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text("Copy")
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
                        .padding(.horizontal)
                        
                        // Copied Toast
                        if showCopiedAlert {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Link copied to clipboard!")
                                        .font(.caption)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    
                    // People I've Invited Section
                    if !viewModel.recruits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            // Header with count
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.accentColor)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("People You've Invited")
                                        .font(.headline)
                                    Text("Active members from your referrals")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(viewModel.recruits.count)")
                                        .font(.headline)
                                        .foregroundColor(.accentColor)
                                    Text("recruits")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Recruits List
                            VStack(spacing: 8) {
                                ForEach(Array(viewModel.recruits.prefix(5)), id: \.id) { recruit in
                                    RecruitRowView(recruit: recruit)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                            
                            // View All button (if more than 5)
                            if viewModel.recruits.count > 5 {
                                Button(action: { showExpandedRecruitList = true }) {
                                    HStack(spacing: 6) {
                                        Text("View all \(viewModel.recruits.count) recruits")
                                            .fontWeight(.semibold)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .foregroundColor(.accentColor)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else if viewModel.currentUser != nil {
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 32))
                                .foregroundColor(.accentColor.opacity(0.6))
                            
                            VStack(spacing: 4) {
                                Text("Start Inviting")
                                    .font(.headline)
                                
                                Text("Share your referral code to invite friends and watch your network grow")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor.opacity(0.2),
                                            Color.accentColor.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                        .frame(height: 16)
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(
                items: [viewModel.getShareText()],
                excludedActivityTypes: [.addToReadingList, .print]
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

// MARK: - Recruit Row Component

struct RecruitRowView: View {
    let recruit: ReferralLink
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(recruit.refereeName.prefix(1)))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(recruit.refereeName)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(recruit.joinDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status Badge
            StatusBadge(status: recruit.status)
        }
        .padding(12)
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
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

// MARK: - ShareSheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let excluded = excludedActivityTypes {
            controller.excludedActivityTypes = excluded
        }
        
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ShareSheet>
    ) {}
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
