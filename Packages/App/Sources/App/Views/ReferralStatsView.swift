//
//  ReferralStatsView.swift
//  App
//
//  Created on October 18, 2026.
//

import SwiftUI
import Common

public struct ReferralStatsView: View {
    let recruits: [ReferralLink]
    
    public init(recruits: [ReferralLink]) {
        self.recruits = recruits
    }
    
    var totalRecruits: Int {
        recruits.count
    }
    
    var activeRecruits: Int {
        recruits.filter { $0.status == .active }.count
    }
    
    var joinedRecruits: Int {
        recruits.filter { $0.status == .joined }.count
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Stats Grid
            HStack(spacing: 12) {
                StatCard(
                    value: "\(totalRecruits)",
                    label: "Total",
                    icon: "person.2",
                    color: .blue
                )
                
                StatCard(
                    value: "\(activeRecruits)",
                    label: "Active",
                    icon: "checkmark.circle",
                    color: .green
                )
                
                StatCard(
                    value: "\(joinedRecruits)",
                    label: "New",
                    icon: "star",
                    color: .orange
                )
            }
            
            // Achievement Text
            if totalRecruits > 0 {
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("You're building the movement!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    VStack {
        Text("With Recruits")
            .font(.headline)
        
        let mockRecruits = [
            ReferralLink(referrerId: UUID(), refereeId: UUID(), refereeName: "John", status: .active),
            ReferralLink(referrerId: UUID(), refereeId: UUID(), refereeName: "Jane", status: .active),
            ReferralLink(referrerId: UUID(), refereeId: UUID(), refereeName: "Mike", status: .joined),
        ]
        
        ReferralStatsView(recruits: mockRecruits)
        
        Spacer()
        
        Text("No Recruits")
            .font(.headline)
        
        ReferralStatsView(recruits: [])
    }
    .padding()
}
