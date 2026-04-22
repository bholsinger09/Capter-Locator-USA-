//
//  ContactDeveloperView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 21, 2026.
//

import SwiftUI
import CloudKit

struct ContactDeveloperView: View {
    @StateObject private var submissionManager = SubmissionManager()
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var selectedState: String = ""
    @State private var selectedUniversity: String = ""
    @State private var contactName: String = ""
    @State private var contactEmail: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    
    // Get unique states
    private var states: [String] {
        let allStates = ChapterData.sampleChapters.map { $0.state }
        return Array(Set(allStates)).sorted()
    }
    
    // Get universities for selected state
    private var universities: [String] {
        guard !selectedState.isEmpty else { return [] }
        let chaptersInState = ChapterData.sampleChapters.filter { $0.state == selectedState }
        return chaptersInState.compactMap { $0.university }.sorted()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chapter Information")) {
                    // State Picker
                    Picker("State", selection: $selectedState) {
                        Text("Select State").tag("")
                        ForEach(states, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .onChange(of: selectedState) { _ in
                        selectedUniversity = ""
                    }
                    
                    // University Picker
                    Picker("University", selection: $selectedUniversity) {
                        Text("Select University").tag("")
                        ForEach(universities, id: \.self) { university in
                            Text(university).tag(university)
                        }
                    }
                    .disabled(selectedState.isEmpty)
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Contact Name", text: $contactName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Contact Email", text: $contactEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("About This Feature")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Help us keep chapter contact information up to date!")
                            .font(.subheadline)
                        
                        Text("Submit updated contact information for your chapter, and our team will review and update the app.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button(action: submitUpdate) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Submit Update")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .navigationTitle("Contact Developer")
            .alert("Submission Status", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("successfully") {
                        resetForm()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !selectedState.isEmpty &&
        !selectedUniversity.isEmpty &&
        !contactName.isEmpty &&
        !contactEmail.isEmpty &&
        contactEmail.contains("@")
    }
    
    private func submitUpdate() {
        guard let userEmail = authManager.currentUser?.email else {
            alertMessage = "Please sign in to submit updates"
            showingAlert = true
            return
        }
        
        isSubmitting = true
        
        let submission = ChapterUpdateSubmission(
            state: selectedState,
            university: selectedUniversity,
            contactName: contactName,
            contactEmail: contactEmail,
            submittedBy: userEmail
        )
        
        Task {
            do {
                try await submissionManager.submitUpdate(submission)
                await MainActor.run {
                    isSubmitting = false
                    alertMessage = "Update submitted successfully! Thank you for helping us keep the information current."
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    alertMessage = "Failed to submit update. Please try again later."
                    showingAlert = true
                }
            }
        }
    }
    
    private func resetForm() {
        selectedState = ""
        selectedUniversity = ""
        contactName = ""
        contactEmail = ""
    }
}

#Preview {
    ContactDeveloperView()
        .environmentObject(AuthenticationManager())
}
