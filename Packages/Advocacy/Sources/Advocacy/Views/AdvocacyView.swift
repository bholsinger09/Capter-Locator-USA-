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
            VStack(alignment: .leading, spacing: 15) {
                // Official Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(official.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(official.displayTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(official.locationText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(12)
                
                // Contact Info
                VStack(alignment: .leading, spacing: 10) {
                    if let email = official.email {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text(email)
                                .font(.caption)
                        }
                    }
                    
                    if let phone = official.phone {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.blue)
                            Text(phone)
                                .font(.caption)
                        }
                    }
                    
                    if let website = official.website {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text(website)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(12)
                
                // Message Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message Preview")
                        .font(.headline)
                    
                    let body = viewModel.emailBody(for: issue, user: nil, university: nil, official: official)
                    Text(body)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(12)
                
                // Send Button
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
                        Text("Send Email")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Contact Official")
    }
}

#Preview {
    AdvocacyView()
}
