//
//  FreeSpeechHubView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import SwiftUI

struct FreeSpeechHubView: View {
    @StateObject private var incidentManager = IncidentManager()
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var selectedTab = 0
    @State private var showingReportIncident = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Map View
                IncidentsMapView(incidentManager: incidentManager)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .tag(0)
                
                // List View
                IncidentListView(incidentManager: incidentManager)
                    .tabItem {
                        Label("Incidents", systemImage: "list.bullet")
                    }
                    .tag(1)
                
                // Statistics View
                StatisticsView(incidentManager: incidentManager)
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                    .tag(2)
                
                // About/Info View
                AboutFreeSpeechView()
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
                    .tag(3)
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingReportIncident = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingReportIncident) {
                ReportIncidentView(incidentManager: incidentManager, authManager: authManager)
            }
        }
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Campus Free Speech Map"
        case 1: return "Incident Reports"
        case 2: return "Statistics"
        case 3: return "About"
        default: return "Free Speech Hub"
        }
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    @StateObject private var viewModel: IncidentsMapViewModel
    
    init(incidentManager: IncidentManager) {
        _viewModel = StateObject(wrappedValue: IncidentsMapViewModel(incidentManager: incidentManager))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Statistics
                overallStatsSection
                
                // Trend Analysis
                trendSection
                
                // Top Hostile Campuses
                topCampusesSection
                
                // By Type
                byTypeSection
                
                // By State
                byStateSection
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .task {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Overall Stats
    
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("National Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Total Incidents",
                    value: "\(viewModel.incidentCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Verified",
                    value: "\(viewModel.verifiedIncidentCount)",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Critical",
                    value: "\(viewModel.criticalIncidentCount)",
                    icon: "flame.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Campuses Affected",
                    value: "\(viewModel.campusStats.count)",
                    icon: "building.columns.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Trend Section
    
    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("30-Day Trend")
                .font(.title3)
                .fontWeight(.bold)
            
            let trendData = viewModel.getIncidentTrend(days: 30)
            
            if trendData.isEmpty {
                Text("No recent data")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                SimpleTrendChart(data: trendData)
                    .frame(height: 150)
            }
            
            Text("Incidents reported in the last 30 days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Top Campuses
    
    private var topCampusesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Most Hostile Campuses")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("Top 10")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.campusStats.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(Array(viewModel.getMostHostileCampuses().prefix(10).enumerated()), id: \.1.id) { index, campus in
                    HStack {
                        Text("\(index + 1)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(campus.universityName)
                                .font(.headline)
                            Text("\(campus.city), \(campus.state)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(campus.totalIncidents)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("incidents")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if index < 9 && index < viewModel.getMostHostileCampuses().count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - By Type
    
    private var byTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Incidents by Type")
                .font(.title3)
                .fontWeight(.bold)
            
            let typeData = viewModel.getIncidentsGroupedByType()
            
            if typeData.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(typeData, id: \.type) { item in
                    HStack {
                        Image(systemName: item.type.icon)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text(item.type.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(item.count)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            let maxCount = typeData.first?.count ?? 1
                            let percentage = Double(item.count) / Double(maxCount)
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * percentage, height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(width: 100, height: 6)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - By State
    
    private var byStateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Incidents by State")
                .font(.title3)
                .fontWeight(.bold)
            
            let stateData = Dictionary(grouping: viewModel.filteredIncidents) { $0.state }
                .map { (state: $0.key, count: $0.value.count) }
                .sorted { $0.count > $1.count }
                .prefix(10)
            
            if stateData.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(Array(stateData), id: \.state) { item in
                    HStack {
                        Text(item.state)
                            .font(.subheadline)
                            .frame(width: 120, alignment: .leading)
                        
                        Spacer()
                        
                        Text("\(item.count)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Simple Trend Chart

struct SimpleTrendChart: View {
    let data: [Date: Int]
    
    var body: some View {
        GeometryReader { geometry in
            let sortedData = data.sorted { $0.key < $1.key }
            let maxValue = sortedData.map { $0.value }.max() ?? 1
            let pointWidth = geometry.size.width / CGFloat(max(sortedData.count - 1, 1))
            
            ZStack {
                // Background Grid
                ForEach(0..<5) { i in
                    let y = geometry.size.height * CGFloat(i) / 4
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
                
                // Line Chart
                Path { path in
                    for (index, item) in sortedData.enumerated() {
                        let x = CGFloat(index) * pointWidth
                        let y = geometry.size.height *  (1 - CGFloat(item.value) / CGFloat(maxValue))
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // Area Fill
                Path { path in
                    if let first = sortedData.first {
                        let firstX: CGFloat = 0
                        let firstY = geometry.size.height * (1 - CGFloat(first.value) / CGFloat(maxValue))
                        path.move(to: CGPoint(x: firstX, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: firstX, y: firstY))
                        
                        for (index, item) in sortedData.enumerated() {
                            let x = CGFloat(index) * pointWidth
                            let y = geometry.size.height * (1 - CGFloat(item.value) / CGFloat(maxValue))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        if let last = sortedData.last {
                            let lastX = CGFloat(sortedData.count - 1) * pointWidth
                            path.addLine(to: CGPoint(x: lastX, y: geometry.size.height))
                        }
                        path.closeSubpath()
                    }
                }
                .fill(LinearGradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                
                // Data Points
                ForEach(Array(sortedData.enumerated()), id: \.0) { index, item in
                    let x = CGFloat(index) * pointWidth
                    let y = geometry.size.height * (1 - CGFloat(item.value) / CGFloat(maxValue))
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - About View

struct AboutFreeSpeechView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Section
                VStack(spacing: 12) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Campus Free Speech Incidents")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Documenting and tracking free speech violations on college campuses across America")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                // Purpose
                HubInfoSection(
                    title: "Our Mission",
                    icon: "target",
                    color: .blue
                ) {
                    Text("This tool empowers students and faculty to document, report, and track incidents where free speech and intellectual freedom are threatened on college campuses. By crowdsourcing these reports, we create transparency and accountability.")
                }
                
                // How It Works
                HubInfoSection(
                    title: "How It Works",
                    icon: "gear",
                    color: .orange
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        StepRow(number: 1, text: "Report an incident of censorship, bias, or discrimination")
                        StepRow(number: 2, text: "Provide evidence and details to support your report")
                        StepRow(number: 3, text: "Reports are reviewed and verified by moderators")
                        StepRow(number: 4, text: "Verified incidents appear on the public map and database")
                        StepRow(number: 5, text: "Support others who experienced similar incidents")
                    }
                }
                
                // Types of Incidents
                HubInfoSection(
                    title: "What to Report",
                    icon: "checklist",
                    color: .green
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Professor bias or political indoctrination")
                        BulletPoint(text: "Grade retaliation for expressing views")
                        BulletPoint(text: "Speech codes that restrict expression")
                        BulletPoint(text: "Event cancellations or disruptions")
                        BulletPoint(text: "Viewpoint discrimination by administration")
                        BulletPoint(text: "Removal of posters or materials")
                        BulletPoint(text: "Harassment or intimidation")
                        BulletPoint(text: "Deplatforming of speakers")
                    }
                }
                
                // Privacy
                HubInfoSection(
                    title: "Privacy & Safety",
                    icon: "lock.shield",
                    color: .purple
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(" You can report incidents anonymously")
                        Text("✓ Your personal information is kept confidential")
                        Text("✓ Reports are moderated to prevent abuse")
                        Text("✓ Evidence is stored securely")
                    }
                    .foregroundColor(.secondary)
                }
                
                // Call to Action
                VStack(spacing: 12) {
                    Text("Stand Up for Free Speech")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("If you've experienced or witnessed an incident, report it now. Your voice matters.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct HubInfoSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            content
                .font(.body)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.green)
                .fontWeight(.bold)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}
