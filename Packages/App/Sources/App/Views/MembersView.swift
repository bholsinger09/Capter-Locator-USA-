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
            VStack(alignment: .leading, spacing: 16) {
                // Current User Card
                VStack(spacing: 16) {
                    // User Header
                    DetailHeaderCard(
                        title: user.fullName,
                        subtitle: "Active Member",
                        icon: "person.circle.fill",
                        iconColor: .blue
                    )
                    
                    // Member Info
                    FormSection(title: "Your Membership") {
                        VStack(spacing: 12) {
                            DetailRow(
                                label: "Email",
                                value: user.email,
                                icon: "envelope.fill"
                            )
                            
                            Divider()
                            
                            DetailRow(
                                label: "Chapter",
                                value: selectedChapter,
                                icon: "building.2.fill"
                            )
                            
                            Divider()
                            
                            DetailRow(
                                label: "Status",
                                value: "Active",
                                icon: "checkmark.circle.fill",
                                valueColor: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                }
                .padding()
                
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
        }
    }
}



#Preview {
    MembersView()
}
