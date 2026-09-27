//
//  DependencyContainer.swift
//  App
//
//  Dependency injection container for package-based services

import Foundation
import Combine
import Common
import Authentication
import Chapters
import Events
import Geospatial
import Notifications
import Advocacy
import Resources
import SwiftUI

/// Central dependency container for managing package-based services and ViewModels
public class DependencyContainer: ObservableObject {
    // MARK: - Package Services
    public let authenticationManager: AuthenticationManager
    public let geospatialService: GeospatialService
    public let notificationManager: NotificationManager
    
    // MARK: - Package ViewModels
    public let chaptersViewModel: ChaptersViewModel
    public let eventsViewModel: EventsViewModel
    public let advocacyViewModel: AdvocacyViewModel
    
    // MARK: - Initialization
    public init() {
        // Initialize services
        self.authenticationManager = AuthenticationManager()
        self.geospatialService = GeospatialService()
        self.notificationManager = NotificationManager()
        
        // Initialize package ViewModels (all take no parameters in package versions)
        self.chaptersViewModel = ChaptersViewModel()
        self.eventsViewModel = EventsViewModel()
        self.advocacyViewModel = AdvocacyViewModel()
    }
}
