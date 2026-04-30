//
//  ReportIncidentView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import SwiftUI

struct ReportIncidentView: View {
    @StateObject private var viewModel: IncidentReporterViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTag = ""
    @State private var newEvidenceURL = ""
    @State private var newWitness = ""
    
    init(incidentManager: IncidentManager, authManager: AuthenticationManager) {
        _viewModel = StateObject(wrappedValue: IncidentReporterViewModel(
            incidentManager: incidentManager,
            authManager: authManager
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                basicInfoSection
                
                // Location Details
                locationSection
                
                // Incident Classification
                classificationSection
                
                // People Involved
                peopleInvolvedSection
                
                // Evidence
                evidenceSection
                
                // Reporter Info
                reporterSection
                
                // Validation Errors
                if !viewModel.validationErrors.isEmpty {
                    validationErrorsSection
                }
            }
            .navigationTitle("Report Incident")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task {
                            await viewModel.submitIncident()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
            .disabled(viewModel.isSubmitting)
            .overlay {
                if viewModel.isSubmitting {
                    ProgressView("Submitting...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .alert("Report Submitted", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for reporting this incident. Our team will review it shortly.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - Basic Info Section
    
    private var basicInfoSection: some View {
        Section {
            TextField("Incident Title", text: $viewModel.title)
            
            TextEditor(text: $viewModel.description)
                .frame(minHeight: 100)
                .overlay(alignment: .topLeading) {
                    if viewModel.description.isEmpty {
                        Text("Describe what happened in detail...")
                            .foregroundColor(.secondary)
                            .padding(.leading, 5)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
            
            DatePicker("Incident Date", selection: $viewModel.incidentDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
        } header: {
            Label("Basic Information", systemImage: "doc.text")
        } footer: {
            Text("Provide a clear title and detailed description of the incident. Include specific quotes, actions, or policies if applicable.")
                .font(.caption)
        }
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        Section {
            TextField("University Name", text: $viewModel.selectedUniversity)
            
            TextField("State", text: $viewModel.selectedState)
            
            TextField("City", text: $viewModel.city)
            
            TextField("Campus Location (Optional)", text: $viewModel.campusLocation)
        } header: {
            Label("Location", systemImage: "mappin.circle")
        } footer: {
            Text("Specific building, classroom, or area on campus where the incident occurred.")
                .font(.caption)
        }
    }
    
    // MARK: - Classification Section
    
    private var classificationSection: some View {
        Section {
            Picker("Incident Type", selection: $viewModel.selectedType) {
                ForEach(Incident.IncidentType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            
            Picker("Severity Level", selection: $viewModel.selectedSeverity) {
                ForEach(Incident.Severity.allCases, id: \.self) { severity in
                    HStack {
                        Text(severity.rawValue)
                        Spacer()
                        Circle()
                            .fill(colorForSeverity(severity))
                            .frame(width: 10, height: 10)
                    }
                    .tag(severity)
                }
            }
            
            // Tags
            VStack(alignment: .leading, spacing: 8) {
                Text("Tags (Optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !viewModel.tags.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            TagChip(text: tag) {
                                viewModel.removeTag(tag)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Add tag", text: $newTag)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Add") {
                        viewModel.addTag(newTag)
                        newTag = ""
                    }
                    .buttonStyle(.bordered)
                    .disabled(newTag.isEmpty)
                }
            }
        } header: {
            Label("Classification", systemImage: "tag")
        } footer: {
            Text("Categorize the incident to help others find similar reports.")
                .font(.caption)
        }
    }
    
    // MARK: - People Involved Section
    
    private var peopleInvolvedSection: some View {
        Section {
            TextField("Who was targeted? (Optional)", text: $viewModel.targetedIndividual)
            
            TextField("Perpetrator Name (Optional)", text: $viewModel.perpetratorName)
            
            TextField("Perpetrator Role (Optional)", text: $viewModel.perpetratorRole)
                .textContentType(.jobTitle)
            
            // Witnesses
            if !viewModel.witnesses.isEmpty {
                ForEach(viewModel.witnesses, id: \.self) { witness in
                    HStack {
                        Image(systemName: "person")
                        Text(witness)
                        Spacer()
                        Button(role: .destructive) {
                            viewModel.removeWitness(witness)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Add witness", text: $newWitness)
                
                Button("Add") {
                    viewModel.addWitness(newWitness)
                    newWitness = ""
                }
                .buttonStyle(.bordered)
                .disabled(newWitness.isEmpty)
            }
        } header: {
            Label("People Involved", systemImage: "person.2")
        } footer: {
            Text("Include names if you feel comfortable. This helps verify and investigate the incident.")
                .font(.caption)
        }
    }
    
    // MARK: - Evidence Section
    
    private var evidenceSection: some View {
        Section {
            TextField("Evidence Description (Optional)", text: $viewModel.evidenceDescription)
            
            // Evidence URLs
            if !viewModel.evidenceURLs.isEmpty {
                ForEach(viewModel.evidenceURLs, id: \.self) { url in
                    HStack {
                        Image(systemName: "link")
                        Text(url)
                            .lineLimit(1)
                            .font(.caption)
                        Spacer()
                        Button(role: .destructive) {
                            viewModel.removeEvidenceURL(url)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Photo/Video URL", text: $newEvidenceURL)
                    .textContentType(.URL)
                
                Button("Add") {
                    viewModel.addEvidenceURL(newEvidenceURL)
                    newEvidenceURL = ""
                }
                .buttonStyle(.bordered)
                .disabled(newEvidenceURL.isEmpty)
            }
        } header: {
            Label("Evidence", systemImage: "camera")
        } footer: {
            Text("Add links to photos, videos, documents, or news articles about the incident.")
                .font(.caption)
        }
    }
    
    // MARK: - Reporter Section
    
    private var reporterSection: some View {
        Section {
            Toggle("Report Anonymously", isOn: $viewModel.isAnonymous)
            
            if !viewModel.isAnonymous {
                TextField("Your Name", text: $viewModel.reporterName)
            }
        } header: {
            Label("Reporter Information", systemImage: "person.text.rectangle")
        } footer: {
            if viewModel.isAnonymous {
                Text("Your identity will not be shared publicly. Only administrators will have access to your account information.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Your name will be visible on this report. This can help with credibility and follow-up.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Validation Errors Section
    
    private var validationErrorsSection: some View {
        Section {
            ForEach(viewModel.validationErrors, id: \.self) { error in
                Label {
                    Text(error)
                        .font(.caption)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }
        } header: {
            Text("Please fix the following:")
        }
        .listRowBackground(Color.orange.opacity(0.1))
    }
    
    // MARK: - Helper Functions
    
    private func colorForSeverity(_ severity: Incident.Severity) -> Color {
        switch severity {
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

// MARK: - Supporting Views

struct TagChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.blue.opacity(0.2))
        .foregroundColor(.blue)
        .cornerRadius(15)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
