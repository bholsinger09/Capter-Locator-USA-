//
//  ContentView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
import Common
import Authentication

public struct ContentView: View {
    @State private var showDisclaimer = true
    @StateObject private var dependencyContainer = DependencyContainer()
    
    public var body: some View {
        Group {
            if showDisclaimer {
                DisclaimerView(isPresented: $showDisclaimer)
            } else {
                ZStack {
                    if dependencyContainer.authenticationManager.isAuthenticated {
                        MainTabView()
                            .environmentObject(dependencyContainer)
                    } else {
                        LoginView(authenticationManager: dependencyContainer.authenticationManager)
                    }
                }
            }
        }
        .onAppear {
            print("🎬 [ContentView] onAppear - isAuthenticated = \(dependencyContainer.authenticationManager.isAuthenticated)")
        }
    }
    
    public init() {}
}
