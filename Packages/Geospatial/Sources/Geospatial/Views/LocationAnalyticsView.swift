//
//  LocationAnalyticsView.swift
//  Geospatial
//

import SwiftUI

public struct LocationAnalyticsView: View {
    @StateObject private var service = GeospatialService()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Location")) {
                    if let location = service.userLocation {
                        Text("Latitude: \(location.latitude)")
                        Text("Longitude: \(location.longitude)")
                    } else {
                        Text("Location not available")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Nearby Chapters")) {
                    if service.nearbyChapters.isEmpty {
                        Text("No nearby chapters found")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(service.nearbyChapters) { chapter in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chapter.name)
                                    .fontWeight(.semibold)
                                Text(String(format: "%.1f miles away", chapter.distance))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Location Analytics")
        }
    }
}

#Preview {
    LocationAnalyticsView()
}
