//
//  LocationAnalyticsView.swift
//  Geospatial
//

import SwiftUI
import CoreLocation
import Chapters
import Common

public struct LocationAnalyticsView: View {
    @StateObject private var service = GeospatialService()
    @StateObject private var chaptersVM = ChaptersViewModel()
    @State private var locationManager = CLLocationManager()
    @State private var hasRequestedPermission = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Your Location")) {
                        if let location = service.userLocation {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading) {
                                        Text("Current Location")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.4f°, %.4f°", location.latitude, location.longitude))
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                            .cornerRadius(12)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.slash")
                                        .foregroundColor(.red)
                                    VStack(alignment: .leading) {
                                        Text("Location Status")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("Enable location services to see nearby chapters")
                                            .font(.caption)
                                    }
                                }
                                Button(action: requestLocationPermission) {
                                    Text("Enable Location")
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                            .cornerRadius(12)
                        }
                    }
                    
                    Section(header: Text("Nearby Chapters")) {
                        if service.nearbyChapters.isEmpty {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "mappin.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No Nearby Chapters")
                                    .font(.headline)
                                Text("Enable location to find nearby chapters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(20)
                        } else {
                            ForEach(service.nearbyChapters.sorted { $0.distance < $1.distance }) { chapter in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(chapter.name)
                                        .fontWeight(.semibold)
                                    HStack(spacing: 12) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "location.fill")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            Text(String(format: "%.1f mi", chapter.distance))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "compass")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            Text(chapter.direction)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nearby")
            .onAppear {
                Task {
                    await chaptersVM.loadChapters()
                    requestLocationPermission()
                }
            }
        }
        .onReceive(service.$userLocation) { location in
            if let location = location {
                service.findNearbyChapters(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    chapters: chaptersVM.chapters,
                    radiusInMiles: 100
                )
            }
        }
    }
    
    private func requestLocationPermission() {
        if !hasRequestedPermission {
            hasRequestedPermission = true
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let location = locationManager.location {
                    service.updateUserLocation(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
        }
    }
}

#Preview {
    LocationAnalyticsView()
}
