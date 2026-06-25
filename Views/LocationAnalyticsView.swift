//
//  LocationAnalyticsView.swift
//  SwiftChapterUSA Finder
//
//  Displays regional analytics, trends, and heatmap data for geospatial insights.
//

import SwiftUI
import Charts

struct LocationAnalyticsView: View {
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var eventManager: EventManager
    @StateObject var viewModel: LocationViewModel
    @State private var selectedRegionTab: RegionTab = .statistics
    @State private var sortBy: SortOption = .chapters
    
    enum RegionTab {
        case statistics
        case heatmap
        case rankings
    }
    
    enum SortOption: String, CaseIterable {
        case chapters = "Chapters"
        case events = "Events"
        case engagement = "Engagement"
        case members = "Members"
    }
    
    var sortedStats: [RegionStatistics] {
        switch sortBy {
        case .chapters:
            return viewModel.regionStats.sorted { $0.chapterCount > $1.chapterCount }
        case .events:
            return viewModel.regionStats.sorted { $0.eventCount > $1.eventCount }
        case .engagement:
            return viewModel.regionStats.sorted { $0.advocacyActionCount > $1.advocacyActionCount }
        case .members:
            return viewModel.regionStats.sorted { $0.averageMemberCount > $1.averageMemberCount }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("View", selection: $selectedRegionTab) {
                    Text("Statistics").tag(RegionTab.statistics)
                    Text("Heatmap").tag(RegionTab.heatmap)
                    Text("Rankings").tag(RegionTab.rankings)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on tab
                ZStack {
                    if selectedRegionTab == .statistics {
                        statisticsView
                    } else if selectedRegionTab == .heatmap {
                        heatmapView
                    } else {
                        rankingsView
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Regional Analytics")
            .onAppear {
                viewModel.updateRegionStatistics(
                    chapters: chapterManager.chapters,
                    events: eventManager.events
                )
            }
            .onChange(of: selectedRegionTab) { newTab in
                if newTab == .rankings {
                    viewModel.calculateRankedChapters(
                        chapters: chapterManager.chapters,
                        events: eventManager.events
                    )
                }
            }
        }
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        VStack(spacing: 12) {
            // Sort controls
            Picker("Sort by", selection: $sortBy) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Summary cards
            HStack(spacing: 12) {
                RegionStatCard(
                    title: "Total States",
                    value: "\(viewModel.regionStats.count)",
                    icon: "map.fill",
                    color: .blue
                )
                
                RegionStatCard(
                    title: "Total Chapters",
                    value: "\(viewModel.regionStats.reduce(0) { $0 + $1.chapterCount })",
                    icon: "building.2.fill",
                    color: .green
                )
                
                RegionStatCard(
                    title: "Total Events",
                    value: "\(viewModel.regionStats.reduce(0) { $0 + $1.eventCount })",
                    icon: "calendar.badge.plus",
                    color: .orange
                )
            }
            .padding()
            
            // Regional breakdown
            List {
                ForEach(sortedStats) { stat in
                    NavigationLink(destination: RegionDetailView(stat: stat)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(stat.state)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(stat.chapterCount) chapters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Events")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(stat.eventCount)")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Avg Members")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(stat.averageMemberCount)")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Activity")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(stat.advocacyActionCount)")
                                        .font(.headline)
                                }
                                
                                Spacer()
                            }
                            
                            // Progress bar
                            ProgressView(
                                value: Double(stat.chapterCount),
                                total: Double(viewModel.regionStats.map { $0.chapterCount }.max() ?? 1)
                            )
                            .tint(.blue)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: - Heatmap View
    private var heatmapView: some View {
        VStack(spacing: 12) {
            Text("Advocacy Activity Heatmap")
                .font(.headline)
                .padding()
            
            if viewModel.heatmapData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "thermometer")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No heatmap data available")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.94, green: 0.94, blue: 0.96))
            } else {
                // Heatmap intensity chart
                List {
                    let sortedData = viewModel.heatmapData.sorted { $0.intensity > $1.intensity }
                    ForEach(Array(sortedData.enumerated()), id: \.offset) { offset, point in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(point.region)
                                    .fontWeight(.semibold)
                                Text("(\(String(format: "%.2f°", point.latitude)), \(String(format: "%.2f°", point.longitude)))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Intensity bar
                            HStack(spacing: 4) {
                                ForEach(0..<5, id: \.self) { index in
                                    Rectangle()
                                        .fill(point.intensity > Double(index) / 5 ? Color.orange : Color(red: 0.89, green: 0.89, blue: 0.89))
                                        .frame(height: 20)
                                }
                            }
                            .frame(width: 60)
                            
                            Text(String(format: "%.0f%%", point.intensity * 100))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .listStyle(.plain)
                
                Text("Intensity shows relative advocacy activity and chapter engagement across regions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Rankings View
    private var rankingsView: some View {
        return VStack(spacing: 12) {
            Text("Top Performing Chapters")
                .font(.headline)
                .padding()
            
            List {
                ForEach(Array(viewModel.rankedChapters.prefix(20).enumerated()), id: \.element.chapter.id) { index, item in
                    NavigationLink(destination: ChapterDetailView(chapter: item.chapter)) {
                        HStack(spacing: 12) {
                            VStack(alignment: .center) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.chapter.displayName)
                                    .fontWeight(.semibold)
                                Text("\(item.chapter.memberCount) members")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Score")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.1f", item.score))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Stat Card Component
struct RegionStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(red: 0.94, green: 0.94, blue: 0.96))
        .cornerRadius(12)
    }
}

// MARK: - Region Detail View
struct RegionDetailView: View {
    let stat: RegionStatistics
    
    var body: some View {
        List {
            Section(header: Text("Overview")) {
                HStack {
                    Text("State")
                    Spacer()
                    Text(stat.state)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Coordinates")
                    Spacer()
                    Text("\(String(format: "%.2f°", stat.centerLatitude)), \(String(format: "%.2f°", stat.centerLongitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Metrics")) {
                HStack {
                    Text("Total Chapters")
                    Spacer()
                    Text("\(stat.chapterCount)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Total Events")
                    Spacer()
                    Text("\(stat.eventCount)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Advocacy Actions")
                    Spacer()
                    Text("\(stat.advocacyActionCount)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Avg Chapter Members")
                    Spacer()
                    Text("\(stat.averageMemberCount)")
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(stat.state)
    }
}

// Preview
#Preview {
    LocationAnalyticsView(viewModel: LocationViewModel(geospatialService: GeospatialService()))
        .environmentObject(ChapterManager())
        .environmentObject(EventManager())
}
