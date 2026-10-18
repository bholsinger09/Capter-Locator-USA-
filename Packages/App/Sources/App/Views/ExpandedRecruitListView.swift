//
//  ExpandedRecruitListView.swift
//  App
//
//  Created on October 18, 2026.
//

import SwiftUI
import Common
import Authentication

public struct ExpandedRecruitListView: View {
    @ObservedObject var viewModel: ReferralViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var sortBy: SortOption = .joinDateNewest
    @State private var filterBy: StatusFilter = .all
    
    enum SortOption: String, CaseIterable {
        case joinDateNewest = "Newest First"
        case joinDateOldest = "Oldest First"
        case nameAZ = "Name (A-Z)"
        case nameZA = "Name (Z-A)"
        case statusActive = "Active First"
        
        var id: String { self.rawValue }
    }
    
    enum StatusFilter: String, CaseIterable {
        case all = "All"
        case joined = "Joined"
        case active = "Active"
        case inactive = "Inactive"
        
        var id: String { self.rawValue }
    }
    
    var filteredAndSortedRecruits: [ReferralLink] {
        var recruits = viewModel.recruits
        
        // Apply search filter
        if !searchText.isEmpty {
            recruits = recruits.filter { recruit in
                recruit.refereeName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        if filterBy != .all {
            recruits = recruits.filter { recruit in
                switch filterBy {
                case .all:
                    return true
                case .joined:
                    return recruit.status == .joined
                case .active:
                    return recruit.status == .active
                case .inactive:
                    return recruit.status == .inactive
                }
            }
        }
        
        // Apply sorting
        switch sortBy {
        case .joinDateNewest:
            recruits.sort { $0.joinDate > $1.joinDate }
        case .joinDateOldest:
            recruits.sort { $0.joinDate < $1.joinDate }
        case .nameAZ:
            recruits.sort { $0.refereeName < $1.refereeName }
        case .nameZA:
            recruits.sort { $0.refereeName > $1.refereeName }
        case .statusActive:
            recruits.sort { recruit1, recruit2 in
                let order: [ReferralStatus] = [.active, .joined, .inactive]
                let index1 = order.firstIndex(of: recruit1.status) ?? 3
                let index2 = order.firstIndex(of: recruit2.status) ?? 3
                return index1 < index2
            }
        }
        
        return recruits
    }
    
    var recruitStats: (total: Int, active: Int, joined: Int, inactive: Int) {
        let total = viewModel.recruits.count
        let active = viewModel.recruits.filter { $0.status == .active }.count
        let joined = viewModel.recruits.filter { $0.status == .joined }.count
        let inactive = viewModel.recruits.filter { $0.status == .inactive }.count
        return (total, active, joined, inactive)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("All Your Recruits")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(recruitStats.total) people invited")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Stats Row
                    HStack(spacing: 12) {
                        StatsPill(
                            count: recruitStats.total,
                            label: "Total",
                            color: .blue
                        )
                        
                        StatsPill(
                            count: recruitStats.active,
                            label: "Active",
                            color: .green
                        )
                        
                        StatsPill(
                            count: recruitStats.joined,
                            label: "Joined",
                            color: .orange
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                .background(Color(.systemGray6))
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // Controls Row
                HStack(spacing: 12) {
                    // Sort Dropdown
                    Menu {
                        ForEach(SortOption.allCases, id: \.id) { option in
                            Button(action: { sortBy = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortBy == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.caption2)
                            Text("Sort")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                    
                    // Filter Dropdown
                    Menu {
                        ForEach(StatusFilter.allCases, id: \.id) { filter in
                            Button(action: { filterBy = filter }) {
                                HStack {
                                    Text(filter.rawValue)
                                    if filterBy == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.caption2)
                            Text("Filter")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Recruits List
                if filteredAndSortedRecruits.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        VStack(spacing: 4) {
                            Text("No Recruits Found")
                                .font(.headline)
                            
                            if searchText.isEmpty && filterBy == .all {
                                Text("Start sharing your referral code to invite friends")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Try adjusting your search or filter")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredAndSortedRecruits, id: \.id) { recruit in
                                ExpandedRecruitRowView(recruit: recruit)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Expanded Recruit Row

struct ExpandedRecruitRowView: View {
    let recruit: ReferralLink
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row with Avatar and Name
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(recruit.refereeName.prefix(1)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    )
                
                // Name and Join Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(recruit.refereeName)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("Joined \(recruit.joinDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status Badge
                StatusBadge(status: recruit.status)
            }
            
            Divider()
            
            // Details Row
            HStack(spacing: 16) {
                // ID
                VStack(alignment: .leading, spacing: 4) {
                    Text("ID")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Text(recruit.id.uuidString.prefix(8).uppercased())
                            .font(.caption)
                            .monospaced()
                        
                        Button(action: {
                            UIPasteboard.general.string = recruit.id.uuidString
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                Spacer()
                
                // Days Since Join
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Member For")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        if let daysSince = daysSinceJoin {
                            Text("\(daysSince) days")
                                .font(.caption)
                                .fontWeight(.semibold)
                        } else {
                            Text("Today")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
    }
    
    var daysSinceJoin: Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: recruit.joinDate, to: Date())
        return components.day
    }
}

// MARK: - Stats Pill

struct StatsPill: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.headline)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Search recruits...", text: $text)
                .font(.body)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    let referralService = ReferralService()
    let authManager = AuthenticationManager()
    let viewModel = ReferralViewModel(
        referralService: referralService,
        authenticationManager: authManager
    )
    
    return ExpandedRecruitListView(viewModel: viewModel)
}
