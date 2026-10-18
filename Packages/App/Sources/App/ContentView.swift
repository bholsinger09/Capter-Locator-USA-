//
//  ContentView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI
import Common

public struct ContentView: View {
    @State private var showDisclaimer = true
    @State private var isAuthenticated = false
    @StateObject private var dependencyContainer = DependencyContainer()
    
    public var body: some View {
        Group {
            if showDisclaimer {
                DisclaimerView(isPresented: $showDisclaimer)
            } else if isAuthenticated {
                MainTabView()
                    .environmentObject(dependencyContainer)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
    
    public init() {}
}
