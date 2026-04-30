//
//  AdminSubmissionsView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 21, 2026.
//

import SwiftUI
import CloudKit

struct AdminSubmissionsView: View {
    @StateObject private var submissionManager = SubmissionManager()
    @State private var showingDeleteAlert = false
    @State private var submissionToDelete: ChapterUpdateSubmission?
    @State private var selectedFilter: ChapterUpdateSubmission.SubmissionStatus?
    
    var filteredSubmissions: [ChapterUpdateSubmission] {
        if let filter = selectedFilter {
            return submissionManager.submissions.filter { $0.status == filter }
        }
        return submissionManager.submissions
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if submissionManager.isLoading && submissionManager.submissions.isEmpty {
                    ProgressView("Loading submissions...")
                } else if submissionManager.submissions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Submissions Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Chapter update submissions will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        Section {
                            Picker("Filter by Status", selection: $selectedFilter) {
                                Text("All").tag(nil as ChapterUpdateSubmission.SubmissionStatus?)
                                ForEach(ChapterUpdateSubmission.SubmissionStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status as ChapterUpdateSubmission.SubmissionStatus?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        ForEach(filteredSubmissions) { submission in
                            SubmissionRow(
                                submission: submission,
                                onStatusChange: { newStatus in
                                    updateStatus(for: submission, to: newStatus)
                                },
                                onDelete: {
                                    submissionToDelete = submission
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Chapter Updates")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        Task {
                            await submissionManager.fetchAllSubmissions()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(submissionManager.isLoading)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        Task {
                            await submissionManager.fetchAllSubmissions()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(submissionManager.isLoading)
                }
                #endif
            }
            .alert("Delete Submission", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let submission = submissionToDelete {
                        deleteSubmission(submission)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this submission?")
            }
            .onAppear {
                Task {
                    await submissionManager.fetchAllSubmissions()
                }
            }
        }
    }
    
    private func updateStatus(for submission: ChapterUpdateSubmission, to status: ChapterUpdateSubmission.SubmissionStatus) {
        Task {
            do {
                try await submissionManager.updateSubmissionStatus(submission, status: status)
            } catch {
                print("Failed to update status: \(error)")
            }
        }
    }
    
    private func deleteSubmission(_ submission: ChapterUpdateSubmission) {
        Task {
            do {
                try await submissionManager.deleteSubmission(submission)
            } catch {
                print("Failed to delete submission: \(error)")
            }
        }
    }
}

struct SubmissionRow: View {
    let submission: ChapterUpdateSubmission
    let onStatusChange: (ChapterUpdateSubmission.SubmissionStatus) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(submission.university)
                        .font(.headline)
                    Text(submission.state)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: submission.status)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                InfoRow(label: "Contact Name", value: submission.contactName)
                InfoRow(label: "Contact Email", value: submission.contactEmail)
                InfoRow(label: "Submitted By", value: submission.submittedBy)
                InfoRow(label: "Submitted", value: submission.submittedAt.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.caption)
            
            Divider()
            
            HStack {
                Menu {
                    ForEach(ChapterUpdateSubmission.SubmissionStatus.allCases, id: \.self) { status in
                        Button(action: {
                            onStatusChange(status)
                        }) {
                            Label(status.rawValue, systemImage: status == submission.status ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Change Status", systemImage: "rectangle.stack.badge.person.crop")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
        }
    }
}

struct StatusBadge: View {
    let status: ChapterUpdateSubmission.SubmissionStatus
    
    var badgeColor: Color {
        switch status {
        case .pending:
            return .orange
        case .reviewed:
            return .blue
        case .approved:
            return .green
        case .rejected:
            return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(8)
    }
}

#Preview {
    AdminSubmissionsView()
}
