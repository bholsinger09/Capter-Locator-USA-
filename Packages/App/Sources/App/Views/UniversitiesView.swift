import SwiftUI
import Common
import AppUI

struct UniversitiesView: View {
    @StateObject private var viewModel = UniversitiesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.loadingState {
                case .idle:
                    contentView
                case .loading:
                    LoadingView(message: "Loading universities...")
                case .success:
                    contentView
                case .failure(let error):
                    ErrorView(
                        title: "Failed to Load Universities",
                        message: error.errorDescription ?? "Unknown error",
                        retryAction: {
                            Task {
                                HapticFeedbackManager.shared.tapFeedback()
                                await viewModel.loadUniversities()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Universities")
            .toolbar {
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
            .refreshable {
                await viewModel.refresh()
                HapticFeedbackManager.shared.successFeedback()
            }
            .onAppear {
                Task {
                    await viewModel.loadUniversities()
                    await viewModel.loadFavorites()
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search universities...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .onChange(of: viewModel.searchText) { _ in
                viewModel.resetPagination()
            }
            
            // Filter Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Picker("State", selection: $viewModel.selectedState) {
                        ForEach(viewModel.stateOptions, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
            }
            .onChange(of: viewModel.selectedState) { _ in
                viewModel.resetPagination()
            }
            
            // Content
            if viewModel.filteredUniversities.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "building.2")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No universities found")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(viewModel.paginatedUniversities) { university in
                        ZStack(alignment: .trailing) {
                            NavigationLink(destination: UniversityDetailView(university: university, viewModel: viewModel)) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(university.name)
                                            .fontWeight(.semibold)
                                        Text(university.displayLocation)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if university.hasChapter {
                                            Label("Has Chapter", systemImage: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            
                            Button(action: {
                                HapticFeedbackManager.shared.tapFeedback()
                                viewModel.toggleFavorite(university)
                            }) {
                                Image(systemName: viewModel.isFavorited(university) ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.isFavorited(university) ? .red : .gray)
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
                                        Text("Load More Universities")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                }
                                Text("Showing \(viewModel.paginatedUniversities.count + (viewModel.currentPage - 1) * viewModel.itemsPerPage) of \(viewModel.filteredUniversities.count) universities")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    } else if !viewModel.paginatedUniversities.isEmpty {
                        HStack {
                            Spacer()
                            Text("All universities loaded")
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
}

struct UniversityDetailView: View {
    let university: University
    let viewModel: UniversitiesViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with favorite button
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(university.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Label(university.displayLocation, systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        HapticFeedbackManager.shared.mediumTapFeedback()
                        viewModel.toggleFavorite(university)
                    }) {
                        Image(systemName: viewModel.isFavorited(university) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorited(university) ? .red : .gray)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .cornerRadius(12)
                
                // Chapter Status
                HStack(spacing: 10) {
                    Image(systemName: university.hasChapter ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(university.hasChapter ? .green : .red)
                    
                    Text(university.hasChapter ? "Chapter Active" : "No Chapter")
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .cornerRadius(12)
                
                // Details
                if let population = university.studentPopulation {
                    DetailRow(
                        label: "Student Population",
                        value: "\(population)",
                        icon: "person.3.fill"
                    )
                }
                
                if let website = university.website {
                    Link(destination: URL(string: website) ?? URL(fileURLWithPath: "")) {
                        DetailRow(
                            label: "Website",
                            value: "Visit Website",
                            icon: "globe"
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("University Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}


#Preview {
    UniversitiesView()
}
