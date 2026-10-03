//
//  ChaptersView.swift
//  Chapters
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI
import Common

public struct ChaptersView: View {
    @StateObject private var viewModel = ChaptersViewModel()
    @State private var selectedChapter: Chapter?
    @State private var showCreateSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Find Your Chapter")) {
                    Picker("State", selection: $viewModel.selectedState) {
                        ForEach(viewModel.stateOptions, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search chapters...", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }
                
                if viewModel.filteredChapters.isEmpty {
                    Section {
                        Text("No chapters found in your search")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Section(header: Text("Chapters (\(viewModel.filteredChapters.count))")) {
                        ForEach(viewModel.filteredChapters) { chapter in
                            NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chapter.displayName)
                                        .fontWeight(.semibold)
                                    Text("\(chapter.memberCount) members")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chapters")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateChapterView(chaptersViewModel: viewModel)
            }
        }
    }
}

// MARK: - Chapter Detail View
public struct ChapterDetailView: View {
    let chapter: Chapter
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(chapter.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                        Text("\(chapter.city), \(chapter.state)")
                    }
                    .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(12)
                
                // Info
                VStack(alignment: .leading, spacing: 10) {
                    infoRow(icon: "person.fill", label: "President", value: chapter.presidentName)
                    infoRow(icon: "envelope.fill", label: "Email", value: chapter.contactEmail)
                    if let phone = chapter.phoneNumber {
                        infoRow(icon: "phone.fill", label: "Phone", value: phone)
                    }
                    infoRow(icon: "person.2.fill", label: "Members", value: "\(chapter.memberCount)")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(12)
                
                // Description
                if !chapter.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text(chapter.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Chapter")
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

// MARK: - Create Chapter View
public struct CreateChapterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var chaptersViewModel: ChaptersViewModel
    @StateObject private var viewModel = CreateChapterViewModel()
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chapter Information")) {
                    TextField("Chapter Name", text: $viewModel.name)
                    Picker("State", selection: $viewModel.state) {
                        ForEach(AppConstants.usStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    TextField("City", text: $viewModel.city)
                    TextField("University (Optional)", text: $viewModel.university)
                }
                
                Section(header: Text("Leadership")) {
                    TextField("President Name", text: $viewModel.presidentName)
                    TextField("Contact Email", text: $viewModel.contactEmail)
                    TextField("Phone Number (Optional)", text: $viewModel.phoneNumber)
                }
                
                Section(header: Text("Details")) {
                    TextField("Description", text: $viewModel.description)
                    TextField("Meeting Location (Optional)", text: $viewModel.meetingLocation)
                    TextField("Meeting Schedule (Optional)", text: $viewModel.meetingSchedule)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create Chapter")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Create") {
                        if let chapter = viewModel.createChapter() {
                            chaptersViewModel.addChapter(chapter)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
    }
}

#Preview {
    ChaptersView()
}
