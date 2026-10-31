//
//  AdvocacyView.swift
//  Advocacy
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI
import Common

public struct AdvocacyView: View {
    @StateObject private var viewModel = AdvocacyViewModel()
    @State private var selectedOfficial: ElectedOfficial?
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Advocacy Toolkit")) {
                    Text("Connect with elected officials in your state and send ready-to-send advocacy messages.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Issue", selection: $viewModel.selectedIssue) {
                        ForEach(AdvocacyIssue.allCases) { issue in
                            Text(issue.rawValue).tag(issue)
                        }
                    }
                    
                    Picker("State", selection: $viewModel.selectedState) {
                        ForEach(viewModel.stateOptions, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                }
                
                Section(header: Text("Message Preview")) {
                    Text(viewModel.selectedIssue.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Available Representatives")) {
                    let officials = AdvocacyData.officials(forState: viewModel.selectedState)
                    
                    if officials.isEmpty {
                        Text("No representatives available for this state")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(officials) { official in
                            NavigationLink(destination: OfficialDetailView(
                                official: official,
                                issue: viewModel.selectedIssue,
                                viewModel: viewModel
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(official.name)
                                        .fontWeight(.semibold)
                                    Text(official.displayTitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Advocacy")
        }
    }
}

// MARK: - Official Detail View

struct OfficialDetailView: View {
    @Environment(\.dismiss) var dismiss
    let official: ElectedOfficial
    let issue: AdvocacyIssue
    @ObservedObject var viewModel: AdvocacyViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Official Header Card
                VStack(alignment: .leading, spacing: 8) {
                    Text(official.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(official.displayTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text(official.locationText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Contact Information - Better Layout
                VStack(alignment: .leading, spacing: 14) {
                    Text("Contact Information")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let email = official.email {
                        ContactRow(
                            icon: "envelope.fill",
                            label: "Email",
                            value: email,
                            isLink: true
                        )
                    }
                    
                    if let phone = official.phone {
                        ContactRow(
                            icon: "phone.fill",
                            label: "Phone",
                            value: phone,
                            isLink: true
                        )
                    }
                    
                    if let website = official.website {
                        ContactRow(
                            icon: "globe",
                            label: "LinkedIn",
                            value: "View Profile",
                            isLink: true
                        )
                    }
                    
                    if official.email == nil && official.phone == nil && official.website == nil {
                        Text("No contact information available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                
                // Message Preview - Improved
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Message Preview")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Issue: \(issue.rawValue)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    let body = viewModel.emailBody(for: issue, user: nil, university: nil, official: official)
                    Text(body)
                        .font(.body)
                        .lineSpacing(2)
                        .foregroundColor(.primary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                
                // Send Button - Call to Action
                if let email = official.email {
                    Button(action: {
                        let subject = viewModel.emailSubject(for: issue, official: official)
                        let body = viewModel.emailBody(for: issue, user: nil, university: nil, official: official)
                        if let url = viewModel.makeMailURL(to: email, subject: subject, body: body) {
                            #if canImport(AppKit)
                            NSWorkspace.shared.open(url)
                            #endif
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                            Text("Send Email to \(official.name)")
                                .font(.body)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Text("No email address available to send message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Contact Official")
    }
}

// MARK: - Contact Row Component
struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let isLink: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 32)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isLink {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    AdvocacyView()
}
