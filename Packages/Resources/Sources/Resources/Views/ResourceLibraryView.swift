//
//  ResourceLibraryView.swift
//  Resources
//
//  Part of SwiftChapterUSA Package Migration
//

import SwiftUI

public struct ResourceLibraryView: View {
    @StateObject private var viewModel = ResourceLibraryViewModel()
    @State private var selectedResource: Resource?
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterPill(
                                title: "Featured",
                                isSelected: viewModel.showFeaturedOnly
                            ) {
                                viewModel.showFeaturedOnly.toggle()
                            }
                            
                            ForEach(Resource.ResourceCategory.allCases, id: \.self) { category in
                                FilterPill(
                                    title: category.rawValue,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    if viewModel.selectedCategory == category {
                                        viewModel.selectedCategory = nil
                                    } else {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Resources List
                    if viewModel.filteredResources.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Resources Found")
                                .font(.headline)
                            Text("Try adjusting your filters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 15) {
                            ForEach(viewModel.filteredResources) { resource in
                                ResourceCard(resource: resource)
                                    .onTapGesture {
                                        selectedResource = resource
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Resource Library")
            .sheet(item: $selectedResource) { resource in
                ResourceDetailView(resource: resource, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search resources...", text: $text)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Resource Card
struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: resource.category.icon)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(resource.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if resource.isFeatured {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            Text(resource.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}

// MARK: - Resource Detail View
struct ResourceDetailView: View {
    @Environment(\.dismiss) var dismiss
    let resource: Resource
    @ObservedObject var viewModel: ResourceLibraryViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: resource.category.icon)
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            if resource.isFeatured {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Text(resource.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(resource.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Metadata
                        HStack(spacing: 15) {
                            Label(resource.category.rawValue, systemImage: "folder")
                            Label(resource.type.rawValue, systemImage: "doc")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Content")
                            .font(.headline)
                        
                        Divider()
                        
                        Text(resource.content)
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Resource")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ResourceLibraryView()
}
