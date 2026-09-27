//
//  ResourceLibraryViewModel.swift
//  Resources
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation
import Combine

public class ResourceLibraryViewModel: ObservableObject {
    @Published public var resources: [Resource] = []
    @Published public var searchText: String = ""
    @Published public var selectedCategory: Resource.ResourceCategory?
    @Published public var selectedType: Resource.ResourceType?
    @Published public var showFeaturedOnly: Bool = false
    
    public init() {
        loadResources()
    }
    
    public var filteredResources: [Resource] {
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
    
    public var featuredResources: [Resource] {
        resources.filter { $0.isFeatured }
    }
    
    public var resourcesByCategory: [Resource.ResourceCategory: [Resource]] {
        Dictionary(grouping: resources) { $0.category }
    }
    
    public func loadResources() {
        if let savedData = UserDefaults.standard.data(forKey: "resources"),
           let decoded = try? JSONDecoder().decode([Resource].self, from: savedData) {
            self.resources = decoded
        } else {
            self.resources = Resource.samples
            saveResources()
        }
    }
    
    public func saveResources() {
        if let encoded = try? JSONEncoder().encode(resources) {
            UserDefaults.standard.set(encoded, forKey: "resources")
        }
    }
    
    public func incrementDownloadCount(for resource: Resource) {
        if let index = resources.firstIndex(where: { $0.id == resource.id }) {
            resources[index].downloadCount += 1
            saveResources()
        }
    }
    
    public func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedType = nil
        showFeaturedOnly = false
    }
}
