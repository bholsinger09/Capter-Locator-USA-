import SwiftUI
import AppUI
import Common
import Authentication
import Chapters

struct ProfileView: View {
    @State private var userChapter = "Texas State"
    @State private var joinDate = "January 2024"
    @State private var isEditingProfile = false
    @State private var showAdminTagEditor = false
    @ObservedObject var referralViewModel: ReferralViewModel
    @EnvironmentObject var authenticationManager: AuthenticationManager
    
    private var userName: String {
        authenticationManager.currentUser?.fullName ?? "Unknown User"
    }
    
    private var userEmail: String {
        authenticationManager.currentUser?.email ?? "No email"
    }
    
    private var isAdmin: Bool {
        let appleUserID = authenticationManager.currentUser?.appleUserID ?? ""
        return appleUserID == "000832.309eac005e8947f49cc100a8d29cd7bb.1828"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    DetailHeaderCard(
                        title: userName,
                        subtitle: userEmail,
                        icon: "person.circle.fill",
                        iconColor: .blue
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Profile Details
                    FormSection(title: "Profile Information") {
                        VStack(spacing: 12) {
                            DetailRow(label: "Chapter", value: userChapter, icon: "building.2.fill")
                            Divider()
                            DetailRow(label: "Member Since", value: joinDate, icon: "calendar")
                            Divider()
                            DetailRow(label: "Status", value: "Active", icon: "checkmark.circle.fill", valueColor: .green)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Edit Profile Button
                    PrimaryButton("Edit Profile", icon: "pencil") {
                        isEditingProfile = true
                    }
                    .padding(.horizontal)
                    
                    // Admin Section - Only for admin user
                    if isAdmin {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Admin Controls")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Button(action: { showAdminTagEditor = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "tag.fill")
                                        .font(.body)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text("Manage Chapter Tags")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Account Settings - WITHOUT FormSection to avoid grey background
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Account Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 0) {
                            SettingsLink(label: "Change Password", icon: "lock")
                            Divider()
                            SettingsLink(label: "Notification Settings", icon: "bell")
                            Divider()
                            SettingsLink(label: "Privacy Settings", icon: "shield")
                        }
                        .padding(12)
                    }
                    .padding(.horizontal)
                    
                    // Clear spacing before Referral Section
                    VStack { }
                        .frame(height: 0)
                    
                    // Referral Section - completely separate
                    VStack(spacing: 0) {
                        ReferralCodeView(viewModel: referralViewModel)
                    }
                    .padding(.top, 12)
                    
                    // Logout Button
                    DangerButton("Logout", icon: "arrowshape.turn.up.left") {
                        authenticationManager.logout()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(userChapter: $userChapter)
            }
            .sheet(isPresented: $showAdminTagEditor) {
                AdminTagEditorView()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SettingsLink: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userChapter: String
    
    var body: some View {
        NavigationView {
            Form {
                Section("Chapter Information") {
                    TextField("Chapter", text: $userChapter)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AdminTagEditorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ChaptersViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.chapters.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No chapters available")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ChapterTagsAdminView(viewModel: viewModel)
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadChapters()
            }
        }
    }
}

#Preview {
    let referralService = ReferralService()
    let authManager = AuthenticationManager()
    let referralViewModel = ReferralViewModel(
        referralService: referralService,
        authenticationManager: authManager
    )
    
    return ProfileView(referralViewModel: referralViewModel)
}
