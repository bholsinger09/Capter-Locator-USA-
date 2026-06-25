//
//  NearbyChaptersView.swift
//  SwiftChapterUSA Finder
//
//  Shows nearby chapters and events within a specified radius.
//

import SwiftUI
import MapKit

struct NearbyChaptersView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var eventManager: EventManager
    @StateObject var viewModel: LocationViewModel
    @State private var selectedTab: Tab = .list
    @State private var selectedChapter: Chapter?
    @State private var showingLocationSettings = false
    @State private var mapRegion: MKCoordinateRegion?
    
    enum Tab {
        case list
        case map
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with location and radius controls
                VStack(spacing: 12) {
                    if let userLoc = viewModel.userLocation {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Location: \(String(format: "%.2f°", userLoc.latitude)), \(String(format: "%.2f°", userLoc.longitude))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                viewModel.startUpdatingLocation()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.94, green: 0.94, blue: 0.96))
                        .cornerRadius(8)
                    } else {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.orange)
                            Text("Location not available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Enable") {
                                viewModel.requestLocationPermission()
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.94, green: 0.94, blue: 0.96))
                        .cornerRadius(8)
                    }
                    
                    // Radius selector
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Search Radius")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(viewModel.distanceString(viewModel.selectedRadius))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Picker("Radius", selection: $viewModel.selectedRadius) {
                            ForEach(viewModel.radiusOptions(), id: \.self) { radius in
                                Text(viewModel.distanceString(radius)).tag(radius)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.selectedRadius) { _ in
                            if viewModel.userLocation != nil {
                                viewModel.updateNearbyLocations(
                                    chapters: chapterManager.chapters,
                                    events: eventManager.events
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.94, green: 0.94, blue: 0.96))
                    .cornerRadius(8)
                }
                .padding(12)
                
                // Tab selection
                Picker("View", selection: $selectedTab) {
                    Text("List").tag(Tab.list)
                    Text("Map").tag(Tab.map)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Content
                ZStack {
                    if viewModel.nearbyChapters.isEmpty && viewModel.nearbyEvents.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "mappin.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No nearby chapters or events")
                                .font(.headline)
                            Text("Chapters within \(viewModel.distanceString(viewModel.selectedRadius))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        if selectedTab == .list {
                            listView
                        } else {
                            mapView
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Nearby Chapters & Events")
            .onAppear {
                viewModel.requestLocationPermission()
                // Use mock location if not available
                if viewModel.userLocation == nil {
                    // Simulate user at center of US for demo
                    var coords = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.userLocation = coords
                        viewModel.updateNearbyLocations(
                            chapters: chapterManager.chapters,
                            events: eventManager.events
                        )
                    }
                }
            }
        }
    }
    
    private var listView: some View {
        List {
            Section(header: Text("Nearby Chapters (\(viewModel.nearbyChapters.count))")) {
                if viewModel.nearbyChapters.isEmpty {
                    Text("No chapters within \(viewModel.distanceString(viewModel.selectedRadius))")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.nearbyChapters, id: \.chapter.id) { item in
                        NavigationLink(destination: ChapterDetailView(chapter: item.chapter)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.chapter.displayName)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(viewModel.distanceString(item.distanceKm))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                HStack(spacing: 12) {
                                    Label("\(item.chapter.memberCount) members", systemImage: "person.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if let university = item.chapter.university {
                                        Label(university, systemImage: "building")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Nearby Events (\(viewModel.nearbyEvents.count))")) {
                if viewModel.nearbyEvents.isEmpty {
                    Text("No events within \(viewModel.distanceString(viewModel.selectedRadius))")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(viewModel.nearbyEvents.enumerated()), id: \.offset) { offset, item in
                        let eventVM = EventsViewModel(eventManager: eventManager, authManager: authManager)
                        NavigationLink(destination: EventDetailView(event: item.event, viewModel: eventVM)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.event.title)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(viewModel.distanceString(item.distanceKm))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                HStack(spacing: 12) {
                                    Label(item.event.eventDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Label(item.event.chapterName, systemImage: "building")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var mapView: some View {
        ZStack {
            // Simple map representation (would use MapKit in production)
            VStack {
                Text("📍 Map View")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    Text("\(viewModel.nearbyChapters.count) chapters")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("\(viewModel.nearbyEvents.count) events")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                
                Text("Full map integration requires MapKit implementation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
        .background(Color(red: 0.94, green: 0.94, blue: 0.96))
    }
}

// Preview
#Preview {
    NearbyChaptersView(viewModel: LocationViewModel(geospatialService: GeospatialService()))
        .environmentObject(AuthenticationManager())
        .environmentObject(ChapterManager())
        .environmentObject(EventManager())
}
