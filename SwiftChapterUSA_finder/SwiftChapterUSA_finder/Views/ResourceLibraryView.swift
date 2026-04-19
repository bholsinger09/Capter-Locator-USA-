//
//  ResourceLibraryView.swift
//  SwiftChapterUSA Finder
//
//  Created on December 9, 2025.
//

import SwiftUI

struct ResourceLibraryView: View {
    @StateObject private var viewModel = ResourceLibraryViewModel()
    @State private var showingFilters = false
    @State private var selectedResource: Resource?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Bar
                    SearchBarView(text: $viewModel.searchText)
                        .padding(.horizontal)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterPillButton(
                                title: "Featured",
                                isSelected: viewModel.showFeaturedOnly
                            ) {
                                viewModel.showFeaturedOnly.toggle()
                            }
                            
                            ForEach(Resource.ResourceCategory.allCases, id: \.self) { category in
                                FilterPillButton(
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
                    
                    // Active Filters Summary
                    if viewModel.selectedCategory != nil || viewModel.showFeaturedOnly || !viewModel.searchText.isEmpty {
                        HStack {
                            Text("\(viewModel.filteredResources.count) resources")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Clear Filters") {
                                viewModel.clearFilters()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Featured Section (if no filters applied)
                    if viewModel.selectedCategory == nil && !viewModel.showFeaturedOnly && viewModel.searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Featured Resources")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.featuredResources) { resource in
                                        FeaturedResourceCard(resource: resource)
                                            .onTapGesture {
                                                selectedResource = resource
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Resources List
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
                .padding(.vertical)
            }
            .navigationTitle("Resource Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedResource) { resource in
                ResourceDetailView(resource: resource, viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search resources...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Filter Pill Button
struct FilterPillButton: View {
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
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Featured Resource Card
struct FeaturedResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: resource.category.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            
            Text(resource.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(resource.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(resource.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(5)
                
                Spacer()
                
                Text(resource.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - Resource Card
struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: resource.category.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(resource.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if resource.isFeatured {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                    }
                }
                
                Text(resource.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(resource.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Text(resource.type.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if resource.downloadCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down.circle")
                                .font(.caption2)
                            Text("\(resource.downloadCount)")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ResourceLibraryViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    ForEach(Resource.ResourceCategory.allCases, id: \.self) { category in
                        Button(action: {
                            if viewModel.selectedCategory == category {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category
                            }
                        }) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.blue)
                                Text(category.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Type")) {
                    ForEach([Resource.ResourceType.article, .guide, .pdf, .video, .link, .image], id: \.self) { type in
                        Button(action: {
                            if viewModel.selectedType == type {
                                viewModel.selectedType = nil
                            } else {
                                viewModel.selectedType = type
                            }
                        }) {
                            HStack {
                                Text(type.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Toggle("Featured Only", isOn: $viewModel.showFeaturedOnly)
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ResourceLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceLibraryView()
    }
}
