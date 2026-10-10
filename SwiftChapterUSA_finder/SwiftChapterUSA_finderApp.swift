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

#if os(iOS)
import UIKit
#endif

@main
struct SwiftChapterUSA_finderApp: App {
    #if os(iOS)
    // AppDelegate is defined in the App package
    @UIApplicationDelegateAdaptor(App.AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            App.ContentView()
        }
    }
}
