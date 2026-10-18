import SwiftUI
import AppUI
import Common
import Authentication

struct ProfileView: View {
    @State private var userName = "John Doe"
    @State private var userEmail = "john@example.com"
    @State private var userChapter = "Texas State"
    @State private var joinDate = "January 2024"
    @State private var isEditingProfile = false
    @ObservedObject var referralViewModel: ReferralViewModel
    
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
                        print("Logout tapped")
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(userName: $userName, userEmail: $userEmail, userChapter: $userChapter)
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
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var userChapter: String
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $userName)
                    TextField("Email", text: $userEmail)
                }
                
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

#Preview {
    let referralService = ReferralService()
    let authManager = AuthenticationManager()
    let referralViewModel = ReferralViewModel(
        referralService: referralService,
        authenticationManager: authManager
    )
    
    return ProfileView(referralViewModel: referralViewModel)
}
