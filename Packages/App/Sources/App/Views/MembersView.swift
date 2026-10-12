import SwiftUI
import Common
import AppUI
import Chapters

struct MembersView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var chaptersVM = ChaptersViewModel()
    @State private var selectedChapter = "Texas State"
    @State private var chapterMembers: [String] = []
    @State private var showChapterPicker = false
    @State private var showRemoveConfirmation = false
    
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
                    await chaptersVM.loadChapters()
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
                    
                    // Membership Info with high contrast - all on dark background
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your Membership")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(16)
                        
                        VStack(spacing: 0) {
                            // Email
                            HStack(spacing: 12) {
                                VStack(alignment: .center) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 40, height: 40)
                                .background(Color.blue)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                    
                                    Text(user.email)
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Chapter
                            HStack(spacing: 12) {
                                VStack(alignment: .center) {
                                    Image(systemName: "building.2.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 40, height: 40)
                                .background(Color.blue)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Chapter")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                    
                                    Text(selectedChapter)
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Status
                            HStack(spacing: 12) {
                                VStack(alignment: .center) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 40, height: 40)
                                .background(Color.green)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Status")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                    
                                    Text("Active")
                                        .font(.system(.body, design: .default))
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                        }
                        .background(Color(UIColor.systemGray5))
                    }
                    .background(Color(UIColor.systemGray5))
                }
                .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.white }))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Change Chapter Button
                Button(action: {
                    showChapterPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Member (Change Chapter)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding()
                
                // Remove Member Button
                Button(action: {
                    showRemoveConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Remove Member")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .alert("Remove Membership", isPresented: $showRemoveConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Remove", role: .destructive) {
                        selectedChapter = ""
                    }
                } message: {
                    Text("Are you sure you want to remove your membership from \(selectedChapter)?")
                }
                
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
        .sheet(isPresented: $showChapterPicker) {
            VStack(spacing: 0) {
                List {
                    ForEach(chaptersVM.chapters, id: \.id) { chapter in
                        Button(action: {
                            selectedChapter = chapter.displayName
                            showChapterPicker = false
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chapter.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if !chapter.presidentName.isEmpty {
                                        Text("President: \(chapter.presidentName)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("\(chapter.memberCount) members")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if chapter.displayName == selectedChapter {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Select Chapter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}



#Preview {
    MembersView()
}
