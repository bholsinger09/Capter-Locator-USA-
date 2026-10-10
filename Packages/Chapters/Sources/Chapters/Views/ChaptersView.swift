//
//  ChaptersView.swift
//  Chapters
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI
import Common
import AppUI

public struct ChaptersView: View {
    @StateObject private var viewModel = ChaptersViewModel()
    @State private var selectedChapter: Chapter?
    @State private var showCreateSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.loadingState {
                case .idle:
                    contentView
                case .loading:
                    LoadingView(message: "Loading chapters...")
                case .success:
                    contentView
                case .failure(let error):
                    ErrorView(
                        title: "Failed to Load Chapters",
                        message: error.errorDescription ?? "Unknown error",
                        retryAction: {
                            Task {
                                HapticFeedbackManager.shared.tapFeedback()
                                await viewModel.loadChapters()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Chapters")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        HapticFeedbackManager.shared.tapFeedback()
                        showCreateSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.favoriteCount > 0 {
                        Text("\(viewModel.favoriteCount)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateChapterView(chaptersViewModel: viewModel)
            }
            .refreshable {
                await viewModel.refresh()
                HapticFeedbackManager.shared.successFeedback()
            }
            .onAppear {
                Task {
                    await viewModel.loadChapters()
                    await viewModel.loadFavorites()
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack {
            List {
                Section(header: Text("Find Your Chapter")) {
                    Picker("State", selection: $viewModel.selectedState) {
                        ForEach(viewModel.stateOptions, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .onChange(of: viewModel.selectedState) { _ in
                        viewModel.resetPagination()
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search chapters...", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(10)
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.resetPagination()
                    }
                }
                
                if viewModel.filteredChapters.isEmpty {
                    Section {
                        Text("No chapters found in your search")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Section(header: Text("Chapters (\(viewModel.filteredChapters.count))")) {
                        ForEach(viewModel.paginatedChaptersFromFiltered) { chapter in
                            ZStack(alignment: .trailing) {
                                NavigationLink(destination: ChapterDetailView(chapter: chapter, viewModel: viewModel)) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(chapter.displayName)
                                                .fontWeight(.semibold)
                                            Text("\(chapter.memberCount) members")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                                
                                Button(action: {
                                    HapticFeedbackManager.shared.tapFeedback()
                                    viewModel.toggleFavorite(chapter)
                                }) {
                                    Image(systemName: viewModel.isFavorited(chapter) ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isFavorited(chapter) ? .red : .gray)
                                        .font(.system(size: 16))
                                }
                                .padding(.trailing, 16)
                            }
                        }
                        
                        if viewModel.hasMoreData {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    if viewModel.loadingState == .loading {
                                        ProgressView()
                                    } else {
                                        Button(action: {
                                            Task {
                                                HapticFeedbackManager.shared.mediumTapFeedback()
                                                await viewModel.loadNextPage()
                                            }
                                        }) {
                                            Text("Load More Chapters")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.blue)
                                                .cornerRadius(8)
                                        }
                                    }
                                    Text("Showing \(viewModel.paginatedChaptersFromFiltered.count + (viewModel.currentPage - 1) * viewModel.itemsPerPage) of \(viewModel.filteredChapters.count) chapters")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                        } else if !viewModel.paginatedChaptersFromFiltered.isEmpty {
                            HStack {
                                Spacer()
                                Text("All chapters loaded")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadFavorites()
            }
        }
    }
}

// MARK: - Chapter Detail View
public struct ChapterDetailView: View {
    public let chapter: Chapter
    public let viewModel: ChaptersViewModel
    @Environment(\.dismiss) var dismiss
    
    public init(chapter: Chapter, viewModel: ChaptersViewModel) {
        self.chapter = chapter
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color(red: 1, green: 1, blue: 1).ignoresSafeArea()
            
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Header with favorite button
                HStack(alignment: .top) {
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
                    Spacer()
                    Button(action: {
                        HapticFeedbackManager.shared.mediumTapFeedback()
                        viewModel.toggleFavorite(chapter)
                    }) {
                        Image(systemName: viewModel.isFavorited(chapter) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorited(chapter) ? .red : .gray)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
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
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .cornerRadius(12)
                
                // Description
                if !chapter.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                        Text(chapter.description)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Chapter")
        }
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
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
