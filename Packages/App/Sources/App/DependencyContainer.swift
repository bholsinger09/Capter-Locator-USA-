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
    @Published public var authenticationManager: AuthenticationManager
    public let geospatialService: GeospatialService
    public let notificationManager: NotificationManager
    public let referralService: ReferralService
    
    // MARK: - Package ViewModels
    public let chaptersViewModel: ChaptersViewModel
    public let eventsViewModel: EventsViewModel
    public let advocacyViewModel: AdvocacyViewModel
    public let referralViewModel: ReferralViewModel
    
    private var authManagerCancellable: AnyCancellable?
    
    // MARK: - Initialization
    public init() {
        // Initialize services FIRST
        let authMgr = AuthenticationManager()
        self.authenticationManager = authMgr
        self.geospatialService = GeospatialService()
        self.notificationManager = NotificationManager()
        let refService = ReferralService()
        self.referralService = refService
        
        // Initialize package ViewModels
        self.chaptersViewModel = ChaptersViewModel()
        self.eventsViewModel = EventsViewModel()
        self.advocacyViewModel = AdvocacyViewModel()
        self.referralViewModel = ReferralViewModel(
            referralService: refService,
            authenticationManager: authMgr
        )
        
        print("📦 [DependencyContainer] Initialized")
        
        // NOW set up auth manager change forwarding AFTER all properties are initialized
        authManagerCancellable = authMgr.objectWillChange.sink { [weak self] in
            print("📦 [DependencyContainer] Auth state changed, forwarding to subscribers")
            self?.objectWillChange.send()
        }
    }
}
