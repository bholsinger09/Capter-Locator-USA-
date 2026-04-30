//
//  ResourceDetailView.swift
//  SwiftChapterUSA Finder
//
//  Created on December 9, 2025.
//

import SwiftUI

struct ResourceDetailView: View {
    @Environment(\.dismiss) var dismiss
    let resource: Resource
    @ObservedObject var viewModel: ResourceLibraryViewModel
    @State private var showingShareSheet = false
    @State private var copiedToClipboard = false
    
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
                                HStack(spacing: 5) {
                                    Image(systemName: "star.fill")
                                    Text("Featured")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.yellow)
                            }
                        }
                        
                        Text(resource.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(resource.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Metadata
                        HStack(spacing: 15) {
                            Label(resource.category.rawValue, systemImage: "folder")
                            Label(resource.type.rawValue, systemImage: "doc")
                            
                            if resource.downloadCount > 0 {
                                Label("\(resource.downloadCount)", systemImage: "arrow.down.circle")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        if let author = resource.author {
                            Text("By \(author)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Added \(formattedDate(resource.dateAdded))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Tags
                        if !resource.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(resource.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Action Buttons
                    HStack(spacing: 15) {
                        Button(action: {
                            copyToClipboard()
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(copiedToClipboard ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showingShareSheet = true
                            viewModel.incrementDownloadCount(for: resource)
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Content")
                            .font(.headline)
                        
                        Divider()
                        
                        Text(resource.content)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Related Resources
                    if !relatedResources.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Related Resources")
                                .font(.headline)
                            
                            ForEach(relatedResources) { related in
                                Button(action: {
                                    // This would navigate to another resource
                                }) {
                                    HStack {
                                        Image(systemName: related.category.icon)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(related.title)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                            
                                            Text(related.category.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Resource")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button(action: {
                            copyToClipboard()
                        }) {
                            Label("Copy Content", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            #if os(iOS)
                            showingShareSheet = true
                            #else
                            copyToClipboard()
                            #endif
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            viewModel.toggleFeatured(for: resource)
                        }) {
                            Label(
                                resource.isFeatured ? "Remove from Featured" : "Mark as Featured",
                                systemImage: resource.isFeatured ? "star.slash" : "star"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            #if os(iOS)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [resource.content])
            }
            #endif
            .alert("Copied!", isPresented: $copiedToClipboard) {
                Button("OK", role: .cancel) {
                    copiedToClipboard = false
                }
            } message: {
                Text("Content copied to clipboard")
            }
        }
    }
    
    private var relatedResources: [Resource] {
        viewModel.resources
            .filter { $0.category == resource.category && $0.id != resource.id }
            .prefix(3)
            .map { $0 }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = resource.content
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resource.content, forType: .string)
        #endif
        copiedToClipboard = true
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedToClipboard = false
        }
    }
}

// MARK: - Share Sheet
#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

struct ResourceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceDetailView(
            resource: Resource.samples[0],
            viewModel: ResourceLibraryViewModel()
        )
    }
}
