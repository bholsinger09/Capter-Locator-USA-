//
//  SyncStatusView.swift
//  App
//
//  Shows the current sync status of data with CloudKit
//

import SwiftUI
import Authentication
import Common

public struct SyncStatusView: View {
    @StateObject private var syncService = CloudKitSyncService.shared
    @StateObject private var reachability = Reachability.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 8) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            // Status text
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch (syncService.syncStatus, reachability.isConnected) {
        case (.synced, _):
            return .green
        case (.syncing, _):
            return .blue
        case (.notSynced, true):
            return .orange
        case (.offline, _), (.notSynced, false):
            return .gray
        }
    }
    
    private var statusText: String {
        switch (syncService.syncStatus, reachability.isConnected) {
        case (.synced, _):
            return "✅ Synced"
        case (.syncing, _):
            return "⏳ Syncing..."
        case (.notSynced, true):
            return "❌ Sync failed - Retry?"
        case (.offline, _), (.notSynced, false):
            return "🔴 Offline - Using local data"
        }
    }
}

#Preview {
    SyncStatusView()
        .padding()
}
