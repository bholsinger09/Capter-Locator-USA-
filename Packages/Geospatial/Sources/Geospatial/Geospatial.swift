// Geospatial Package
import Foundation
import Common
import Chapters

private struct GeospatialDebug {
    static let initialized: Void = {
        print("📦 [DEBUG] Geospatial package initializing")
        return ()
    }()
}

public protocol GeospatialProvider {
    var userLocation: CLLocationCoordinate2D? { get }
    func findNearbyChapters(latitude: Double, longitude: Double, chapters: [Chapter], radiusInMiles: Double)
}

