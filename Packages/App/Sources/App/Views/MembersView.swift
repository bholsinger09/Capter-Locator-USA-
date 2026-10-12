import SwiftUI
import Common
import AppUI

struct MembersView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedChapter = "Texas State"
    @State private var chapterMembers: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.userLoadingState {
                case .idle:
                    emptyView
                case .loading:
                    LoadingView(message: "Loading profile...")
                case .success(let user):
                    contentView(user: user)
                case .failure(let error):
                    ErrorView(
                        title: "Failed to Load Profile",
                        message: error.errorDescription ?? "Unknown error",
                        retryAction: {
                            Task {
                                await viewModel.loadProfile()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Members")
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                Task {
                    await viewModel.loadProfile()
                }
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Tap to load your profile")
                .foregroundColor(.secondary)
            
            Button(action: {
                Task {
                    await viewModel.loadProfile()
                }
            }) {
                Text("Load Profile")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func contentView(user: User) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Current User Card
                VStack(spacing: 0) {
                    // User Header with better styling
                    HStack(spacing: 16) {
                        VStack(alignment: .center) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }
                        .frame(width: 64, height: 64)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Active Member")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                    
                    Divider()
                        .padding(.vertical, 0)
                    
                    // Membership Info with improved readability
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Membership")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 16)
                        
                        VStack(spacing: 14) {
                            // Email
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .font(.body)
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text("Email")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(user.email)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            
                            Divider()
                            
                            // Chapter
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "building.2.fill")
                                        .font(.body)
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text("Chapter")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(selectedChapter)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Divider()
                            
                            // Status
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.body)
                                        .foregroundColor(.green)
                                        .frame(width: 20)
                                    
                                    Text("Status")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Active")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(16)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Logout Button
                Button(action: {
                    Task {
                        await viewModel.logout()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.left.circle.fill")
                        Text("Logout")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .padding(.vertical, 16)
        }
    }
}



#Preview {
    MembersView()
}
