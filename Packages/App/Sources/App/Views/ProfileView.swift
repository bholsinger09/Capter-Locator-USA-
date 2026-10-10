import SwiftUI
import AppUI

struct ProfileView: View {
    @State private var userName = "John Doe"
    @State private var userEmail = "john@example.com"
    @State private var userChapter = "Texas State"
    @State private var joinDate = "January 2024"
    @State private var isEditingProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    DetailHeaderCard(
                        title: userName,
                        subtitle: userEmail,
                        icon: "person.circle.fill",
                        iconColor: .blue
                    )
                    .padding(.horizontal)
                    
                    // Profile Details using new component
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
                    
                    // Account Settings using new FormSection
                    FormSection(title: "Account Settings") {
                        VStack(spacing: 12) {
                            SettingsLink(label: "Change Password", icon: "lock")
                            Divider()
                            SettingsLink(label: "Notification Settings", icon: "bell")
                            Divider()
                            SettingsLink(label: "Privacy Settings", icon: "shield")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Logout Button
                    DangerButton("Logout", icon: "arrowshape.turn.up.left") {
                        print("Logout tapped")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(userName: $userName, userEmail: $userEmail, userChapter: $userChapter)
            }
        }
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
    ProfileView()
}
