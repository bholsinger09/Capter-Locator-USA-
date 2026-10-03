import SwiftUI

struct PathSelectionView: View {
    @State private var selectedPath: LifePathCategory?
    @Environment(\.dismiss) var dismiss
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("You're at a Turning Point")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("What are you trying to change?")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                
                // Path Selection Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(LifePathCategory.allCases, id: \.self) { category in
                            NavigationLink(destination: PathDetailView(category: category)) {
                                PathSelectionCard(category: category)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PathSelectionCard: View {
    let category: LifePathCategory
    
    var body: some View {
        VStack(spacing: 12) {
            Text(category.emoji)
                .font(.system(size: 48))
            
            Text(category.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(category.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 160)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    PathSelectionView()
}
