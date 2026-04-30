//
//  IncidentsMapView.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import SwiftUI
import MapKit

struct IncidentsMapView: View {
    @StateObject private var viewModel: IncidentsMapViewModel
    @State private var showingFilters = false
    @State private var showingCampusStats = false
    @State private var showHeatMap = true
    
    init(incidentManager: IncidentManager) {
        _viewModel = StateObject(wrappedValue: IncidentsMapViewModel(incidentManager: incidentManager))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map
            Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.filteredIncidents.filter { $0.coordinate != nil }) { incident in
                MapAnnotation(coordinate: incident.coordinate!) {
                    IncidentMapMarker(incident: incident) {
                        viewModel.selectedIncident = incident
                    }
                }
            }
            .ignoresSafeArea()
            
            // Heat Map Overlay (if enabled)
            if showHeatMap {
                HeatMapOverlay(points: viewModel.getHeatMapPoints())
                    .allowsHitTesting(false)
            }
            
            // Controls
            VStack(alignment: .trailing, spacing: 12) {
                // Legend and Stats Button
                HStack(spacing: 12) {
                    Button {
                        showingCampusStats.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("\(viewModel.filteredIncidents.count)")
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        showHeatMap.toggle()
                    } label: {
                        Image(systemName: showHeatMap ? "map.fill" : "map")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
                
                // Legend
                if !viewModel.filteredIncidents.isEmpty {
                    MapLegend()
                        .padding()
                }
            }
            
            // Bottom Sheet for Selected Incident
            if let incident = viewModel.selectedIncident {
                VStack {
                    Spacer()
                    IncidentBottomSheet(incident: incident) {
                        viewModel.selectedIncident = nil
                    } onViewDetails: {
                        viewModel.showIncidentDetail = true
                    }
                    .transition(.move(edge: .bottom))
                }
                .animation(.spring(), value: viewModel.selectedIncident != nil)
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCampusStats) {
            CampusStatisticsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showIncidentDetail) {
            if let incident = viewModel.selectedIncident {
                NavigationView {
                    IncidentDetailView(incident: incident, viewModel: viewModel)
                }
            }
        }
        .task {
            await viewModel.refreshData()
            viewModel.mapRegion = viewModel.getMapRegion()
        }
    }
}

// MARK: - Incident Map Marker

struct IncidentMapMarker: View {
    let incident: Incident
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: size * 1.5, height: size * 1.5)
                
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                
                Image(systemName: incident.incidentType.icon)
                    .font(.system(size: size * 0.5))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var color: Color {
        switch incident.severity {
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
    
    private var size: CGFloat {
        switch incident.severity {
        case .low: return 20
        case .moderate: return 25
        case .high: return 30
        case .critical: return 35
        }
    }
}

// MARK: - Heat Map Overlay

struct HeatMapOverlay: View {
    let points: [IncidentsMapViewModel.HeatMapPoint]
    
    var body: some View {
        Canvas { context, size in
            for point in points {
                // Convert coordinate to screen position (simplified - in production use proper projection)
                let x = CGFloat((point.coordinate.longitude + 180) / 360) * size.width
                let y = CGFloat((90 - point.coordinate.latitude) / 180) * size.height
                
                let radius = CGFloat(50 + (point.weight * 100))
                let opacity = point.weight * 0.3
                
                context.fill(
                    Circle().path(in: CGRect(x: x - radius/2, y: y - radius/2, width: radius, height: radius)),
                    with: .color(.red.opacity(opacity))
                )
            }
        }
    }
}

// MARK: - Incident Bottom Sheet

struct IncidentBottomSheet: View {
    let incident: Incident
    let onDismiss: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
            
            // Content
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        SeverityBadge(severity: incident.severity)
                        TypeBadge(type: incident.incidentType)
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark. circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(incident.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "building.columns")
                        Text(incident.universityName)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(incident.state)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(incident.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    HStack {
                        Label("\(incident.supportCount) support", systemImage: "hand.raised")
                        Spacer()
                        Text(incident.incidentDate, style: .date)
                        if incident.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Button(action: onViewDetails) {
                Text("View Full Details")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Map Legend

struct MapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Severity")
                .font(.caption)
                .fontWeight(.bold)
            
            LegendItem(color: .yellow, label: "Low")
            LegendItem(color: .orange, label: "Moderate")
            LegendItem(color: .red, label: "High")
            LegendItem(color: .purple, label: "Critical")
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption)
        }
    }
}

// MARK: - Campus Statistics Sheet

struct CampusStatisticsSheet: View {
    @ObservedObject var viewModel: IncidentsMapViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Summary
                Section {
                    HStack {
                        StatBox(title: "Campuses", value: "\(viewModel.campusStats.count)", color: .blue)
                        StatBox(title: "Incidents", value: "\(viewModel.incidentCount)", color: .orange)
                        StatBox(title: "Critical", value: "\(viewModel.criticalIncidentCount)", color: .red)
                    }
                }
                
                // Most Hostile Campuses
                Section("Most Hostile Environments") {
                    ForEach(viewModel.getMostHostileCampuses()) { campus in
                        CampusStatRow(campus: campus) {
                            viewModel.focusOnCampus(campus)
                            dismiss()
                        }
                    }
                }
                
                // Incident Types
                Section("By Type") {
                    ForEach(viewModel.getIncidentsGroupedByType(), id: \.type) { item in
                        HStack {
                            Image(systemName: item.type.icon)
                                .foregroundColor(.blue)
                            Text(item.type.rawValue)
                            Spacer()
                            Text("\(item.count)")
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // By Severity
                Section("By Severity") {
                    ForEach(viewModel.getIncidentsGroupedBySeverity(), id: \.severity) { item in
                        HStack {
                            Circle()
                                .fill(colorForSeverity(item.severity))
                                .frame(width: 12, height: 12)
                            Text(item.severity.rawValue)
                            Spacer()
                            Text("\(item.count)")
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Campus Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func colorForSeverity(_ severity: Incident.Severity) -> Color {
        switch severity {
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

struct CampusStatRow: View {
    let campus: CampusStats
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(campus.universityName)
                        .font(.headline)
                    Spacer()
                    CampusRatingBadge(rating: campus.rating)
                }
                
                HStack {
                    Image(systemName: "mappin.circle")
                    Text("\(campus.city), \(campus.state)")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                
                HStack(spacing: 16) {
                    StatPill(label: "Total", value: "\(campus.totalIncidents)", color: .blue)
                    StatPill(label: "Verified", value: "\(campus.verifiedIncidents)", color: .green)
                    StatPill(label: "Critical", value: "\(campus.criticalIncidents)", color: .red)
                    StatPill(label: "Recent", value: "\(campus.recentIncidents)", color: .orange)
                }
                
                // Hostility Score Bar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hostility Score: \(Int(campus.hostilityScore))/100")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(ratingColor(campus.rating))
                                .frame(width: geometry.size.width * (campus.hostilityScore / 100), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func ratingColor(_ rating: CampusStats.CampusRating) -> Color {
        switch rating {
        case .friendly: return .green
        case .neutral: return .blue
        case .cautious: return .yellow
        case .hostile: return .orange
        case .veryHostile: return .red
        }
    }
}

struct CampusRatingBadge: View {
    let rating: CampusStats.CampusRating
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rating.icon)
            Text(rating.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(6)
    }
    
    private var color: Color {
        switch rating {
        case .friendly: return .green
        case .neutral: return .blue
        case .cautious: return .yellow
        case .hostile: return .orange
        case .veryHostile: return .red
        }
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}
