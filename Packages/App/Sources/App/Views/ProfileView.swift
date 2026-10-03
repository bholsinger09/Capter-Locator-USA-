import SwiftUI

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
                    VStack(spacing: 16) {
                        // Profile Picture Circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                        
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(userEmail)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // Profile Details
                    VStack(spacing: 16) {
                        ProfileDetailRow(label: "Chapter", value: userChapter)
                        Divider()
                        ProfileDetailRow(label: "Member Since", value: joinDate)
                        Divider()
                        ProfileDetailRow(label: "Status", value: "Active")
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Edit Profile Button
                    Button(action: { isEditingProfile = true }) {
                        Label("Edit Profile", systemImage: "pencil")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Account Settings
                    VStack(spacing: 12) {
                        SectionButton(label: "Change Password", icon: "lock")
                        Divider()
                        SectionButton(label: "Notification Settings", icon: "bell")
                        Divider()
                        SectionButton(label: "Privacy Settings", icon: "shield")
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Logout Button
                    Button(action: {}) {
                        Label("Logout", systemImage: "arrowshape.turn.up.left")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(userName: $userName, userEmail: $userEmail, userChapter: $userChapter)
            }
        }
    }
}

struct ProfileDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct SectionButton: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
            
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
