//
//  ContentView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct ContentView: View {
    let container: DependencyContainer
    @State private var showDisclaimer = true
    
    private var isAuthenticated: Bool {
        container.authenticationManager.isAuthenticated
    }
    
    var body: some View {
        Group {
            if showDisclaimer {
                DisclaimerView(isPresented: $showDisclaimer)
            } else if isAuthenticated {
                MainTabView(container: container)
            } else {
                // Placeholder - in real app would show AuthenticationView from package
                Text("Authentication Required")
            }
        }
    }
}
