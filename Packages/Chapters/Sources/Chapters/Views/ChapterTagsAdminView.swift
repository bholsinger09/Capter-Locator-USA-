//
//  ChapterTagsAdminView.swift
//  Chapters
//
//  Created on October 24, 2026.
//

import SwiftUI

public struct ChapterTagsAdminView: View {
    @ObservedObject var viewModel: ChaptersViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredChapters: [Chapter] {
        if searchText.isEmpty {
            return viewModel.chapters
        }
        return viewModel.chapters.filter { 
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search chapters...", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(12)
                
                Divider()
                
                // Chapters list
                List {
                    ForEach(filteredChapters) { chapter in
                        NavigationLink(destination: ChapterTagAdminDetailView(chapter: chapter, viewModel: viewModel)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chapter.displayName)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 4) {
                                    Text("\(chapter.memberCount) members")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    ChapterTagsView(chapter: chapter)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Manage Chapter Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

public struct ChapterTagAdminDetailView: View {
    let chapter: Chapter
    @ObservedObject var viewModel: ChaptersViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTagsToAdd: Set<String> = []
    
    var currentTags: [ChapterTag] {
        chapter.getTags()
    }
    
    var availableTags: [ChapterTag] {
        ChapterTag.allCases
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Chapter info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chapter")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.secondary)
                    Text(chapter.displayName)
                        .font(.system(.headline, design: .default))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Current tags
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Tags")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                    
                    if currentTags.isEmpty {
                        Text("No tags assigned")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(currentTags, id: \.self) { tag in
                                HStack {
                                    ChapterTagView(tag: tag)
                                    Spacer()
                                    Button(action: {
                                        var updatedChapter = chapter
                                        updatedChapter.removeTag(tag)
                                        viewModel.updateChapter(updatedChapter)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                // Available tags to add
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Tags")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(availableTags, id: \.self) { tag in
                            if !chapter.hasTag(tag) {
                                Button(action: {
                                    var updatedChapter = chapter
                                    updatedChapter.addTag(tag)
                                    viewModel.updateChapter(updatedChapter)
                                }) {
                                    HStack {
                                        Text(tag.displayName)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
        .navigationTitle("Tag Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChapterTagsAdminView(viewModel: ChaptersViewModel())
}
