//
//  AdvocacyView.swift
//  SwiftChapterUSA Finder
//

import SwiftUI

struct AdvocacyView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @StateObject var viewModel: AdvocacyViewModel
    @Environment(\.openURL) private var openURL

    @State private var selectedState = "All States"
    @State private var selectedUniversityId: UUID?
    @State private var selectedIssue: AdvocacyIssue = .campusFreeSpeech

    @State private var showDiagnostics = false
    @State private var lastFetchSource: String = ""
    @State private var lastResultCount: Int = 0

    private var userState: String? {
        authManager.currentUser?.state
    }

    private var effectiveState: String {
        if selectedState == "All States", let state = userState {
            return state
        }
        return selectedState
    }

    private var universities: [University] {
        viewModel.filteredUniversities(state: effectiveState, query: "")
    }

    private var selectedUniversity: University? {
        guard let selectedUniversityId else { return nil }
        return universities.first { $0.id == selectedUniversityId }
    }

    private var topOfficials: [ElectedOfficial] {
        // Deprecated synchronous path — replaced by async fetch stored in `officials`
        []
    }

    @State private var officials: [ElectedOfficial] = []

    private var selectedUniversityText: String {
        selectedUniversity?.name ?? authManager.currentUser?.university ?? "Select a campus"
    }

    private var currentUser: User? {
        authManager.currentUser
    }

    private func fetchAndRecord(state: String, university: University?) async {
        let result = await viewModel.fetchOfficialsResult(for: state, university: university)
        await MainActor.run {
            self.officials = result.officials
            self.lastResultCount = result.officials.count
            self.lastFetchSource = result.sourceDescription
        }
    }

    @ViewBuilder
    private func officialRow(for official: ElectedOfficial) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(official.name.isEmpty ? "Unnamed Official" : official.name)
                        .font(.headline)
                    Text(official.displayTitle.isEmpty ? "Title unavailable" : official.displayTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(official.locationText.isEmpty ? "Location unavailable" : official.locationText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            if let phone = official.phone {
                ContactRow(systemImage: "phone.fill", text: phone)
            }

            if let email = official.email {
                ContactRow(systemImage: "envelope.fill", text: email)
            }

            officialWebsiteLink(for: official)

            HStack {
                if let email = official.email,
                   let url = viewModel.makeMailURL(
                    to: email,
                    subject: viewModel.emailSubject(for: selectedIssue, official: official),
                    body: viewModel.emailBody(for: selectedIssue, user: currentUser, university: selectedUniversity, official: official)
                   ) {
                    Button(action: {
                        openURL(url)
                    }) {
                        Label("Email", systemImage: "envelope")
                    }
                }

                if let phone = official.phone,
                   let dialURL = URL(string: "tel:\(phone.filter { $0.isNumber })") {
                    Button(action: {
                        openURL(dialURL)
                    }) {
                        Label("Call", systemImage: "phone")
                    }
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func officialWebsiteLink(for official: ElectedOfficial) -> some View {
        if let website = official.website {
            let urlString = website.lowercased().hasPrefix("http://") || website.lowercased().hasPrefix("https://") ? website : "https://\(website)"
            if let url = URL(string: urlString) {
                Link("Official website", destination: url)
                    .font(.subheadline)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Advocacy Toolkit")) {
                    Text("Connect your chapter to elected officials in your state and build ready-to-send advocacy messages.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)

                    Picker("Issue", selection: $selectedIssue) {
                        ForEach(AdvocacyIssue.allCases) { issue in
                            Text(issue.rawValue).tag(issue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("State", selection: $selectedState) {
                        ForEach(viewModel.stateOptions, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    if universities.isEmpty {
                        Text("No campuses available for this state.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Campus", selection: $selectedUniversityId) {
                            Text("Select a campus").tag(nil as UUID?)
                            ForEach(universities) { university in
                                Text(university.name).tag(university.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                if let user = currentUser {
                    Section(header: Text("Your Profile")) {
                        Text("Signed in as \(user.fullName)")
                        if let university = user.university {
                            Text("Campus: \(university)")
                        }
                        Text("Primary state: \(user.state)")
                    }
                }

                Section(header: Text("Campus Lookup")) {
                    if universities.isEmpty {
                        Text("No campuses found for \(effectiveState). Choose a different state.")
                            .foregroundColor(.secondary)
                    } else if let selectedUniversity {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Selected campus")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(selectedUniversity.name)
                                .font(.headline)
                            Text(selectedUniversity.displayLocation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    } else {
                        Text("Choose a campus from the state dropdown above to view your district delegation.")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("District & Delegation")) {
                    if officials.isEmpty {
                        Text("No delegation details are currently available for \(effectiveState).")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Selected campus: \(selectedUniversityText)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ForEach(officials) { official in
                            officialRow(for: official)
                        }
                    }
                }

                let draftMessage = viewModel.emailBody(
                    for: selectedIssue,
                    user: currentUser,
                    university: selectedUniversity,
                    official: officials.first
                )

                Section(header: Text("Draft Advocacy Message")) {
                    Text(draftMessage)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                }

//                Section {
//                    Toggle("Show Diagnostics", isOn: $showDiagnostics)
//                    if showDiagnostics {
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text("Effective state: \(effectiveState)")
//                            Text("Selected campus: \(selectedUniversity?.name ?? "nil")")
//                            Text("Last result count: \(lastResultCount)")
//                            Text("Last fetch source: \(lastFetchSource)")
//                        }
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    }
//                } header: {
//                    Text("Diagnostics")
//                }
            }
            .navigationTitle("Advocacy")
            .onAppear {
                if selectedState == "All States", let state = currentUser?.state {
                    selectedState = state
                }
                if selectedUniversityId == nil, let universityName = currentUser?.university {
                    selectedUniversityId = chapterManager.universities.first { $0.name == universityName }?.id
                }
                Task {
                    officials = []
                    await fetchAndRecord(state: effectiveState, university: selectedUniversity)
                }
            }
            .onChange(of: selectedState) { _ in
                selectedUniversityId = nil
                Task {
                    officials = []
                    await fetchAndRecord(state: effectiveState, university: nil)
                }
            }
            .onChange(of: selectedUniversityId) { _ in
                Task {
                    officials = []
                    await fetchAndRecord(state: effectiveState, university: selectedUniversity)
                }
            }
            .onChange(of: universities.count) { newCount in
                guard newCount > 0 else { return }
                Task {
                    await fetchAndRecord(state: effectiveState, university: selectedUniversity)
                }
            }
        }
    }
}
private struct ContactRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        } icon: {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
        }
    }
}
