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
    
    var body: some View {
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
    
    var body: some View {
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
                    
                    if chapter.getTags().isEmpty {
                        Text("No tags assigned")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.secondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    } else {
                        HStack(spacing: 6) {
                            ForEach(chapter.getTags(), id: \.self) { tag in
                                ChapterTagView(tag: tag)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                // Tag criteria info
                VStack(alignment: .leading, spacing: 12) {
                    Text("How Tags Are Assigned")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        tagCriteriaRow("🆕 New", "Established within last 60 days")
                        tagCriteriaRow("🔥 Popular", "25 or more members")
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Chapter stats
                VStack(alignment: .leading, spacing: 12) {
                    Text("Chapter Statistics")
                        .font(.system(.subheadline, design: .default))
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        statRow("Members", "\(chapter.memberCount)")
                        statRow("Established", chapter.dateEstablished.formatted(date: .abbreviated, time: .omitted))
                        statRow("Status", chapter.isActive ? "Active" : "Inactive")
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(16)
        }
        .navigationTitle("Tag Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func tagCriteriaRow(_ tag: String, _ criteria: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(tag)
                .font(.system(.body, design: .default))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(criteria)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.caption, design: .default))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .default))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ChapterTagsAdminView(viewModel: ChaptersViewModel())
}
