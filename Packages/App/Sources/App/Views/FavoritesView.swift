import SwiftUI
import Common
import AppUI
import Chapters

struct FavoritesView: View {
    @StateObject private var chaptersVM = ChaptersViewModel()
    @StateObject private var universitiesVM = UniversitiesViewModel()
    @State private var chapterSortOption: ChapterSortOption = .name
    @State private var universitySortOption: UniversitySortOption = .name
    
    enum ChapterSortOption {
        case name
        case state
        case members
        
        var label: String {
            switch self {
            case .name:
                return "Name"
            case .state:
                return "State"
            case .members:
                return "Members"
            }
        }
    }
    
    enum UniversitySortOption {
        case name
        case state
        
        var label: String {
            switch self {
            case .name:
                return "Name"
            case .state:
                return "State"
            }
        }
    }
    
    var sortedFavoritedChapters: [Chapter] {
        let favorites = chaptersVM.favoritedChapters
        switch chapterSortOption {
        case .name:
            return favorites.sorted { $0.displayName < $1.displayName }
        case .state:
            return favorites.sorted { $0.state < $1.state }
        case .members:
            return favorites.sorted { $0.memberCount > $1.memberCount }
        }
    }
    
    var sortedFavoritedUniversities: [University] {
        let favorites = universitiesVM.favoritedUniversities
        switch universitySortOption {
        case .name:
            return favorites.sorted { $0.name < $1.name }
        case .state:
            return favorites.sorted { $0.state < $1.state }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if chaptersVM.favoriteIds.isEmpty && universitiesVM.favoriteIds.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Favorites Yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Tap the heart icon on chapters or universities to save them here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                    } else {
                        // Favorite Chapters Section
                        if !chaptersVM.favoritedChapters.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Favorite Chapters")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(chaptersVM.favoritedChapters.count)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(4)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                .padding(.horizontal)
                                
                                // Sort Picker
                                HStack {
                                    Text("Sort by:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Picker("Sort Chapters", selection: $chapterSortOption) {
                                        Text(ChapterSortOption.name.label).tag(ChapterSortOption.name)
                                        Text(ChapterSortOption.state.label).tag(ChapterSortOption.state)
                                        Text(ChapterSortOption.members.label).tag(ChapterSortOption.members)
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(sortedFavoritedChapters, id: \.id) { chapter in
                                        FavoriteChapterRow(chapter: chapter, viewModel: chaptersVM)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Favorite Universities Section
                        if !universitiesVM.favoritedUniversities.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Favorite Universities")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(universitiesVM.favoritedUniversities.count)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(4)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                .padding(.horizontal)
                                
                                // Sort Picker
                                HStack {
                                    Text("Sort by:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Picker("Sort Universities", selection: $universitySortOption) {
                                        Text(UniversitySortOption.name.label).tag(UniversitySortOption.name)
                                        Text(UniversitySortOption.state.label).tag(UniversitySortOption.state)
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(sortedFavoritedUniversities, id: \.id) { university in
                                        FavoriteUniversityRow(university: university, viewModel: universitiesVM)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Favorites")
            .refreshable {
                Task {
                    await chaptersVM.loadChapters()
                    await chaptersVM.loadFavorites()
                    await universitiesVM.loadFavorites()
                    HapticFeedbackManager.shared.successFeedback()
                }
            }
            .onAppear {
                Task {
                    await chaptersVM.loadChapters()
                    await chaptersVM.loadFavorites()
                    await universitiesVM.loadFavorites()
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
}

// MARK: - Helper Views

struct FavoriteChapterRow: View {
    let chapter: Chapter
    let viewModel: ChaptersViewModel
    
    @State private var selectedChapter: Chapter?
    
    var body: some View {
        Button(action: { selectedChapter = chapter }) {
            ChapterRowContent(chapter: chapter, viewModel: viewModel)
        }
        .navigationDestination(item: $selectedChapter) { chapter in
            ChapterDetailView(chapter: chapter, viewModel: viewModel)
        }
    }
}

struct ChapterRowContent: View {
    let chapter: Chapter
    let viewModel: ChaptersViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ChapterRowText(chapter: chapter)
            Spacer()
            ChapterRowButton(chapter: chapter, viewModel: viewModel)
        }
        .padding()
        .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
        .cornerRadius(12)
    }
}

struct ChapterRowText: View {
    let chapter: Chapter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(chapter.displayName)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            HStack(spacing: 8) {
                Label(chapter.city, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(chapter.memberCount) members")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChapterRowButton: View {
    let chapter: Chapter
    let viewModel: ChaptersViewModel
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.tapFeedback()
            viewModel.toggleFavorite(chapter)
        }) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
        }
    }
}

struct FavoriteUniversityRow: View {
    let university: University
    let viewModel: UniversitiesViewModel
    
    @State private var selectedUniversity: University?
    
    var body: some View {
        Button(action: { selectedUniversity = university }) {
            UniversityRowContent(university: university, viewModel: viewModel)
        }
        .navigationDestination(item: $selectedUniversity) { university in
            UniversityDetailView(university: university, viewModel: viewModel)
        }
    }
}

struct UniversityRowContent: View {
    let university: University
    let viewModel: UniversitiesViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            UniversityRowText(university: university)
            Spacer()
            UniversityRowButton(university: university, viewModel: viewModel)
        }
        .padding()
        .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
        .cornerRadius(12)
    }
}

struct UniversityRowText: View {
    let university: University
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(university.name)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            HStack(spacing: 8) {
                Text(university.displayLocation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if university.hasChapter {
                    Label("Has Chapter", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct UniversityRowButton: View {
    let university: University
    let viewModel: UniversitiesViewModel
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.tapFeedback()
            viewModel.toggleFavorite(university)
        }) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
        }
    }
}
