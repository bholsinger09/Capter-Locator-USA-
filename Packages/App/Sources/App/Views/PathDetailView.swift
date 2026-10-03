import SwiftUI

struct PathDetailView: View {
    let category: LifePathCategory
    @State private var milestones: [DailyMilestone]
    @State private var showChangePath = false
    @Environment(\.dismiss) var dismiss
    
    let userDefaults = UserDefaults.standard
    let pathKey = "selectedPath"
    let milestonesKey = "pathMilestones"
    
    init(category: LifePathCategory) {
        self.category = category
        
        // Initialize milestones from content
        if let savedMilestones = UserDefaults.standard.data(forKey: "pathMilestones_\(category.rawValue)"),
           let decoded = try? JSONDecoder().decode([DailyMilestone].self, from: savedMilestones) {
            _milestones = State(initialValue: decoded)
        } else {
            _milestones = State(initialValue: PathContent.paths[category] ?? [])
        }
    }
    
    var progressPercentage: Double {
        guard !milestones.isEmpty else { return 0 }
        let completed = milestones.filter { $0.completed }.count
        return Double(completed) / Double(milestones.count) * 100
    }
    
    var completedCount: Int {
        milestones.filter { $0.completed }.count
    }
    
    var body: some View {
        // Special handling for politics category
        if category == .politics {
            PoliticalPartyView()
        } else {
            // Standard 30-day path view
            VStack(spacing: 0) {
                // Header with category info
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text(category.emoji)
                                    .font(.title)
                                Text(category.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Text(category.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showChangePath = true }) {
                            Image(systemName: "arrow.2.circlepath")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Progress Bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(Int(progressPercentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView(value: progressPercentage, total: 100)
                            .tint(.blue)
                        
                        HStack {
                            Text("\(completedCount) of \(milestones.count) days completed")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                
                // Milestones List
                List {
                    ForEach(Array(milestones.enumerated()), id: \.offset) { index, milestone in
                        MilestoneRow(
                            milestone: milestone,
                            isCompleted: milestones[index].completed,
                            onToggle: {
                                milestones[index].completed.toggle()
                                saveMilestones()
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
            .sheet(isPresented: $showChangePath) {
                PathSelectionView()
            }
        }
    }
    
    private func saveMilestones() {
        if let encoded = try? JSONEncoder().encode(milestones) {
            userDefaults.set(encoded, forKey: "pathMilestones_\(category.rawValue)")
        }
    }
}

struct MilestoneRow: View {
    let milestone: DailyMilestone
    let isCompleted: Bool
    let onToggle: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isCompleted ? .green : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Day \(milestone.day)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(milestone.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .strikethrough(isCompleted, color: .gray)
                    }
                    
                    Text(milestone.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .padding(.vertical, 12)
            
            // Expanded action detail
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Today's Action", systemImage: "checkmark.square")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(milestone.action)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(6)
                    }
                }
                .padding(.top, 4)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationView {
        PathDetailView(category: .career)
    }
}
