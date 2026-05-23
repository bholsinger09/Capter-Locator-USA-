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
    @State private var searchText = ""
    @State private var selectedUniversity: University?
    @State private var selectedIssue: AdvocacyIssue = .campusFreeSpeech

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
        viewModel.filteredUniversities(state: effectiveState, query: searchText)
    }

    private var topOfficials: [ElectedOfficial] {
        viewModel.electedOfficials(for: effectiveState, university: selectedUniversity)
    }

    private var selectedUniversityText: String {
        selectedUniversity?.name ?? authManager.currentUser?.university ?? "Select a campus"
    }

    private var issueDescription: String {
        selectedIssue.description
    }

    private var currentUser: User? {
        authManager.currentUser
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

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search campuses...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
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
                        Text("No campuses found for \(effectiveState). Try clearing the search or choosing a different state.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(universities) { university in
                            Button(action: {
                                selectedUniversity = university
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(university.name)
                                            .fontWeight(.semibold)
                                        Text(university.displayLocation)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if university.id == selectedUniversity?.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }

                Section(header: Text("District & Delegation")) {
                    if topOfficials.isEmpty {
                        Text("No delegation details are currently available for \(effectiveState).")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Selected campus: \(selectedUniversityText)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ForEach(topOfficials) { official in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(official.name)
                                            .font(.headline)
                                        Text(official.displayTitle)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(official.locationText)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }

                                if let phone = official.phone {
                                    HStack(spacing: 8) {
                                        Image(systemName: "phone.fill")
                                        Text(phone)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }

                                if let email = official.email {
                                    HStack(spacing: 8) {
                                        Image(systemName: "envelope.fill")
                                        Text(email)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }

                                if let website = official.website,
                                   let url = URL(string: "https://\(website)") {
                                    Link("Official website", destination: url)
                                        .font(.subheadline)
                                }

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
                    }
                }

                Section(header: Text("Draft Advocacy Message")) {
                    Text(issueDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 6)

                    if let official = topOfficials.first {
                        Text(viewModel.emailBody(for: selectedIssue, user: currentUser, university: selectedUniversity, official: official))
                            .font(.callout)
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    } else {
                        Text("Choose a state or campus above to preview a message tailored to your elected official.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Advocacy")
            .onAppear {
                if selectedState == "All States", let state = currentUser?.state {
                    selectedState = state
                }
                if selectedUniversity == nil, let universityName = currentUser?.university {
                    selectedUniversity = chapterManager.universities.first { $0.name == universityName }
                }
            }
        }
    }
}
