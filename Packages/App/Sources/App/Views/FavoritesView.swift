import SwiftUI
import Common
import AppUI
import Chapters

struct FavoritesView: View {
    @StateObject private var chaptersVM = ChaptersViewModel()
    @StateObject private var universitiesVM = UniversitiesViewModel()
    
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
                                
                                VStack(spacing: 8) {
                                    ForEach(chaptersVM.favoritedChapters, id: \.id) { chapter in
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
                                
                                VStack(spacing: 8) {
                                    ForEach(universitiesVM.favoritedUniversities, id: \.id) { university in
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
                    await chaptersVM.loadFavorites()
                    await universitiesVM.loadFavorites()
                    HapticFeedbackManager.shared.successFeedback()
                }
            }
            .onAppear {
                Task {
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
    
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: ChapterDetailView(chapter: chapter, viewModel: viewModel), isActive: $isNavigating) {
                EmptyView()
            }
            
            Button(action: { isNavigating = true }) {
                ChapterRowContent(chapter: chapter, viewModel: viewModel)
            }
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
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
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
    
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: UniversityDetailView(university: university, viewModel: viewModel), isActive: $isNavigating) {
                EmptyView()
            }
            
            Button(action: { isNavigating = true }) {
                UniversityRowContent(university: university, viewModel: viewModel)
            }
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
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
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
