//
//  ContentView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
import Authentication
import App

struct ContentView: View {
    @State private var showDisclaimer = true
    let container: DependencyContainer
    
    var body: some View {
        Group {
            if showDisclaimer {
                DisclaimerView(isPresented: $showDisclaimer)
            } else if container.authenticationManager.isAuthenticated {
                MainTabView(container: container)
            } else {
                AuthenticationView()
            }
        }
    }
}

