import SwiftUI
import App
import Common
import AppUI
import Authentication
import Chapters
import Events
import Geospatial
import Advocacy
import Resources
import Notifications
import UIKit

@main
struct SwiftChapterUSA_finderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
