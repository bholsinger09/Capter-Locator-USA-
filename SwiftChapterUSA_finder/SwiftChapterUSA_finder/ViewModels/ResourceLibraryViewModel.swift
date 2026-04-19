//
//  ResourceLibraryViewModel.swift
//  SwiftChapterUSA Finder
//
//  Created on December 9, 2025.
//

import Foundation
import Combine

class ResourceLibraryViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Resource.ResourceCategory?
    @Published var selectedType: Resource.ResourceType?
    @Published var showFeaturedOnly: Bool = false
    
    init() {
        loadResources()
    }
    
    var filteredResources: [Resource] {
        var filtered = resources
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { resource in
                resource.title.localizedCaseInsensitiveContains(searchText) ||
                resource.description.localizedCaseInsensitiveContains(searchText) ||
                resource.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by type
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }
        
        // Filter by featured
        if showFeaturedOnly {
            filtered = filtered.filter { $0.isFeatured }
        }
        
        return filtered.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var featuredResources: [Resource] {
        resources.filter { $0.isFeatured }
    }
    
    var resourcesByCategory: [Resource.ResourceCategory: [Resource]] {
        Dictionary(grouping: resources) { $0.category }
    }
    
    func loadResources() {
        // Load from UserDefaults or use sample data
        if let savedData = UserDefaults.standard.data(forKey: "resources"),
           let decoded = try? JSONDecoder().decode([Resource].self, from: savedData) {
            resources = decoded
        } else {
            resources = Resource.samples
            saveResources()
        }
    }
    
    func saveResources() {
        if let encoded = try? JSONEncoder().encode(resources) {
            UserDefaults.standard.set(encoded, forKey: "resources")
        }
    }
    
    func incrementDownloadCount(for resource: Resource) {
        if let index = resources.firstIndex(where: { $0.id == resource.id }) {
            resources[index].downloadCount += 1
            saveResources()
        }
    }
    
    func toggleFeatured(for resource: Resource) {
        if let index = resources.firstIndex(where: { $0.id == resource.id }) {
            resources[index].isFeatured.toggle()
            saveResources()
        }
    }
    
    func addResource(_ resource: Resource) {
        resources.append(resource)
        saveResources()
    }
    
    func deleteResource(_ resource: Resource) {
        resources.removeAll { $0.id == resource.id }
        saveResources()
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedType = nil
        showFeaturedOnly = false
    }
}
