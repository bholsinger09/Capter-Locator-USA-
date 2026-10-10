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
                                    ForEach(chaptersVM.favoritedChapters) { chapter in
                                        NavigationLink(destination: ChapterDetailView(chapter: chapter, viewModel: chaptersVM)) {
                                            HStack(spacing: 12) {
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
                                                Spacer()
                                                Button(action: {
                                                    HapticFeedbackManager.shared.tapFeedback()
                                                    chaptersVM.toggleFavorite(chapter)
                                                }) {
                                                    Image(systemName: "heart.fill")
                                                        .foregroundColor(.red)
                                                        .font(.system(size: 16))
                                                }
                                            }
                                            .padding()
                                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                            .cornerRadius(12)
                                        }
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
                                    ForEach(universitiesVM.favoritedUniversities) { university in
                                        NavigationLink(destination: UniversityDetailView(university: university, viewModel: universitiesVM)) {
                                            HStack(spacing: 12) {
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
                                                Spacer()
                                                Button(action: {
                                                    HapticFeedbackManager.shared.tapFeedback()
                                                    universitiesVM.toggleFavorite(university)
                                                }) {
                                                    Image(systemName: "heart.fill")
                                                        .foregroundColor(.red)
                                                        .font(.system(size: 16))
                                                }
                                            }
                                            .padding()
                                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                            .cornerRadius(12)
                                        }
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
