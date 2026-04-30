//
//  IncidentListView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import SwiftUI

struct IncidentListView: View {
    @StateObject private var viewModel: IncidentsMapViewModel
    @State private var showingReportIncident = false
    @State private var showingFilters = false
    
    init(incidentManager: IncidentManager) {
        _viewModel = StateObject(wrappedValue: IncidentsMapViewModel(incidentManager: incidentManager))
    }
    
    var body: some View {
        List {
            // Statistics Header
            statsSection
            
            // Incidents
            if viewModel.filteredIncidents.isEmpty {
                emptyStateSection
            } else {
                incidentsSection
            }
        }
        .navigationTitle("Free Speech Incidents")
        .searchable(text: $viewModel.searchText, prompt: "Search incidents...")
        .refreshable {
            await viewModel.refreshData()
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button {
                        showingReportIncident = true
                    } label: {
                        Label("Report Incident", systemImage: "plus.circle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button {
                        showingReportIncident = true
                    } label: {
                        Label("Report Incident", systemImage: "plus.circle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            #endif
        }
        .sheet(isPresented: $showingFilters) {
            IncidentFilterSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingReportIncident) {
            // Will be initialized with proper dependencies from parent
            Text("Report Incident Form")
        }
        .task {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Statistics Section
    
    private var statsSection: some View {
        Section {
            HStack {
                StatBox(title: "Total", value: "\(viewModel.incidentCount)", color: .blue)
                StatBox(title: "Verified", value: "\(viewModel.verifiedIncidentCount)", color: .green)
                StatBox(title: "Critical", value: "\(viewModel.criticalIncidentCount)", color: .red)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text("No Incidents Found")
                    .font(.headline)
                
                Text("Try adjusting your filters or be the first to report an incident.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showingReportIncident = true
                } label: {
                    Label("Report Incident", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Incidents Section
    
    private var incidentsSection: some View {
        ForEach(viewModel.filteredIncidents) { incident in
            NavigationLink {
                IncidentDetailView(incident: incident, viewModel: viewModel)
            } label: {
                IncidentRow(incident: incident)
            }
        }
    }
}

// MARK: - Incident Row

struct IncidentRow: View {
    let incident: Incident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: incident.incidentType.icon)
                    .foregroundColor(colorForSeverity(incident.severity))
                
                Text(incident.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                if incident.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .help("Verified")
                }
            }
            
            // University and Location
            HStack {
                Image(systemName: "building.columns")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(incident.universityName)
                    .font(.subheadline)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(incident.state)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Type and Severity
            HStack {
                SeverityBadge(severity: incident.severity)
                TypeBadge(type: incident.incidentType)
                
                Spacer()
                
                Text(incident.incidentDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Description Preview
            Text(incident.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Stats Footer
            HStack(spacing: 16) {
                Label("\(incident.supportCount)", systemImage: "hand.thumbsup")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if incident.hasEvidence {
                    Label("Evidence", systemImage: "photo")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if incident.isRecent {
                    Text("Recent")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func colorForSeverity(_ severity: Incident.Severity) -> Color {
        switch severity {
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

// MARK: - Incident Detail View

struct IncidentDetailView: View {
    let incident: Incident
    @ObservedObject var viewModel: IncidentsMapViewModel
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Main Content
                contentSection
                
                // People Involved
                if incident.perpetrator != nil || incident.targetedIndividual != nil {
                    peopleSection
                }
                
                // Evidence
                if incident.hasEvidence {
                    evidenceSection
                }
                
                // Tags
                if !incident.tags.isEmpty {
                    tagsSection
                }
                
                // Resolution
                resolutionSection
                
                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Incident Detail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            #endif
        }
        .sheet(isPresented: $showingShareSheet) {
            IncidentShareSheet(text: viewModel.shareIncident(incident))
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SeverityBadge(severity: incident.severity)
                TypeBadge(type: incident.incidentType)
                Spacer()
                if incident.isVerified {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Text(incident.title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "building.columns")
                Text(incident.universityName)
                    .fontWeight(.medium)
                Text("•")
                    .foregroundColor(.secondary)
                Text("\(incident.city), \(incident.state)")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            HStack {
                Image(systemName: "calendar")
                Text(incident.incidentDate, style: .date)
                Text("at")
                Text(incident.incidentDate, style: .time)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if let location = incident.campusLocation {
                HStack {
                    Image(systemName: "mappin.circle")
                    Text(location)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
            
            Text(incident.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - People Section
    
    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("People Involved")
                .font(.headline)
            
            if let targeted = incident.targetedIndividual {
                IncidentInfoRow(label: "Targeted Individual", value: targeted, icon: "person")
            }
            
            if let perpetrator = incident.perpetrator {
                IncidentInfoRow(label: "Perpetrator", value: perpetrator, icon: "person.fill.questionmark")
            }
            
            if let role = incident.perpetratorRole {
                IncidentInfoRow(label: "Role", value: role, icon: "briefcase")
            }
            
            if !incident.witnesses.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Witnesses", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(incident.witnesses, id: \.self) { witness in
                        Text("• \(witness)")
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Evidence Section
    
    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Evidence")
                .font(.headline)
            
            if let description = incident.evidenceDescription {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            if !incident.evidenceURLs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photos/Videos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(incident.evidenceURLs, id: \.self) { url in
                        Link(destination: URL(string: url)!) {
                            HStack {
                                Image(systemName: "link")
                                Text(url)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                        }
                    }
                }
            }
            
            if !incident.newsArticleURLs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("News Articles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(incident.newsArticleURLs, id: \.self) { url in
                        Link(destination: URL(string: url)!) {
                            HStack {
                                Image(systemName: "newspaper")
                                Text(url)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
            
            FlowLayout(spacing: 6) {
                ForEach(incident.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(15)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Resolution Section
    
    private var resolutionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)
            
            HStack {
                Image(systemName: statusIcon(incident.resolutionStatus))
                    .foregroundColor(statusColor(incident.resolutionStatus))
                Text(incident.resolutionStatus.rawValue)
                    .fontWeight(.medium)
            }
            
            if let resolution = incident.resolutionDescription {
                Text(resolution)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.supportIncident(incident)
                }
            } label: {
                Label("I Experienced This Too (\(incident.supportCount))", systemImage: "hand.raised.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            HStack {
                Text("Reported by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if incident.isAnonymous {
                    Text("Anonymous")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else if let reporter = incident.reporterName {
                    Text(reporter)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("on \(incident.reportedDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    private func statusIcon(_ status: Incident.ResolutionStatus) -> String {
        switch status {
        case .unresolved: return "clock"
        case .inProgress: return "gear"
        case .resolved: return "checkmark.circle.fill"
        case .dismissed: return "xmark.circle"
        case .escalated: return "arrow.up.circle.fill"
        }
    }
    
    private func statusColor(_ status: Incident.ResolutionStatus) -> Color {
        switch status {
        case .unresolved: return .orange
        case .inProgress: return .blue
        case .resolved: return .green
        case .dismissed: return .gray
        case .escalated: return .red
        }
    }
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SeverityBadge: View {
    let severity: Incident.Severity
    
    var body: some View {
        Text(severity.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
    
    private var color: Color {
        switch severity {
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

struct TypeBadge: View {
    let type: Incident.IncidentType
    
    var body: some View {
        Label(type.rawValue, systemImage: type.icon)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(6)
    }
}

struct IncidentInfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct IncidentShareSheet: View {
    let text: String
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: .constant(text))
                    .padding()
                
                ShareLink(item: text) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Share Incident")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

// MARK: - Filter Sheet

struct IncidentFilterSheet: View {
    @ObservedObject var viewModel: IncidentsMapViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("State") {
                    Picker("State", selection: $viewModel.selectedState) {
                        Text("All States").tag("All States")
                        ForEach(viewModel.availableStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                }
                
                Section("Incident Type") {
                    Picker("Type", selection: $viewModel.selectedType) {
                        Text("All Types").tag(nil as Incident.IncidentType?)
                        ForEach(Incident.IncidentType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type as Incident.IncidentType?)
                        }
                    }
                }
                
                Section("Severity") {
                    Picker("Severity", selection: $viewModel.selectedSeverity) {
                        Text("All Severities").tag(nil as Incident.Severity?)
                        ForEach(Incident.Severity.allCases, id: \.self) { severity in
                            Text(severity.rawValue).tag(severity as Incident.Severity?)
                        }
                    }
                }
                
                Section {
                    Toggle("Verified Only", isOn: $viewModel.showVerifiedOnly)
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.clearFilters()
                    }
                }
            }
            .navigationTitle("Filters")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
