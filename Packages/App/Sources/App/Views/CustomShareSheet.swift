//
//  CustomShareSheet.swift
//  App
//
//  Created on October 18, 2026.
//

import SwiftUI
import UIKit

struct CustomShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let excluded = excludedActivityTypes {
            controller.excludedActivityTypes = excluded
        }
        
        // Customize the completion handler if needed
        controller.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<CustomShareSheet>
    ) {}
}

// Custom Share UI that mimics iOS share sheet but with custom icon
struct CustomShareView: View {
    let shareText: String
    let referralIcon: UIImage
    @Environment(\.dismiss) var dismiss
    @State private var showNativeShare = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Custom Share Preview Card
                VStack(spacing: 16) {
                    // Header with custom icon
                    HStack(spacing: 12) {
                        Image(uiImage: referralIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Share Referral Code")
                                .font(.system(.headline, design: .default))
                                .fontWeight(.semibold)
                            
                            Text("Grow the movement")
                                .font(.system(.caption, design: .default))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(16)
                    
                    Divider()
                    
                    // Share Options Grid
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ShareOptionButton(
                                icon: "square.and.arrow.up.fill",
                                label: "Share",
                                action: {
                                    showNativeShare = true
                                }
                            )
                            
                            ShareOptionButton(
                                icon: "doc.on.doc.fill",
                                label: "Copy",
                                action: {
                                    UIPasteboard.general.string = shareText
                                    dismiss()
                                }
                            )
                        }
                        
                        HStack(spacing: 16) {
                            ShareOptionButton(
                                icon: "envelope.fill",
                                label: "Message",
                                action: {
                                    if let url = URL(string: "sms:") {
                                        UIApplication.shared.open(url)
                                    }
                                    dismiss()
                                }
                            )
                            
                            ShareOptionButton(
                                icon: "square.and.arrow.up.fill",
                                label: "More",
                                action: {
                                    showNativeShare = true
                                }
                            )
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemBackground))
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .padding(.bottom, 0)
            }
            .sheet(isPresented: $showNativeShare) {
                CustomShareSheet(
                    items: [shareText],
                    excludedActivityTypes: [.addToReadingList, .print]
                )
            }
        }
    }
}

struct ShareOptionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.accentColor)
                
                Text(label)
                    .font(.system(.caption, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// Helper for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
