//
//  ProfileView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @State private var showingEditProfile = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                        
                        Text(authManager.currentUser?.fullName ?? "User")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Profile Information
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Profile Information")
                            .font(.headline)
                        
                        ProfileInfoRow(icon: "envelope.fill", label: "Email", value: authManager.currentUser?.email ?? "")
                        
                        ProfileInfoRow(icon: "map.fill", label: "State", value: authManager.currentUser?.state ?? "")
                        
                        if let university = authManager.currentUser?.university {
                            ProfileInfoRow(icon: "graduationcap.fill", label: "University", value: university)
                        }
                        
                        ProfileInfoRow(icon: "calendar", label: "Member Since", value: authManager.currentUser?.dateJoined.formatted(date: .long, time: .omitted) ?? "")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Chapter Membership
                    if let chapterId = authManager.currentUser?.chapterId,
                       let chapter = chapterManager.chapters.first(where: { $0.id == chapterId }) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.blue)
                                Text("Chapter Membership")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                    Text("Active Member")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(chapter.displayName)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.caption)
                                        Text("\(chapter.city), \(chapter.state)")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Image(systemName: "person.2.fill")
                                            .font(.caption)
                                        Text("\(chapter.memberCount) members")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                    
                    // Actions
                    VStack(spacing: 15) {
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                Text("Edit Profile")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.primary)
                        
                        Button(action: {
                            authManager.logout()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Logout")
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.red)
                        
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash.circle.fill")
                                Text("Delete Account Permanently")
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.red)
                    }
                    
                    // App Information
                    VStack(spacing: 10) {
                        Text("Chapter Locator USA")
                            .font(.headline)
                        Text("Version 2.0 (Build 3)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: "https://www.tpusa.com")!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                Text("Visit Official TPUSA Website")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Permanently Delete Account?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Permanently", role: .destructive) {
                    authManager.deleteAccount()
                }
            } message: {
                Text("This will PERMANENTLY DELETE your account and all associated data. This action is IRREVERSIBLE.\n\nAll of the following will be permanently deleted:\n• Your profile and account information\n• All posts and content you've created\n• Your chapter membership\n• All app preferences and settings\n\nYou will NOT be able to recover this account or data.")
            }
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chapterManager: ChapterManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var university = ""
    @State private var selectedState = "Alabama"
    @State private var selectedChapterId: UUID?
    
    let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming"
    ]
    
    var availableChapters: [Chapter] {
        chapterManager.chaptersInState(selectedState)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("Location")) {
                    Picker("State", selection: $selectedState) {
                        ForEach(usStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                }
                
                Section(header: Text("Education")) {
                    TextField("University (Optional)", text: $university)
                }
                
                Section(header: Text("Chapter Membership")) {
                    if availableChapters.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("No chapters available in \(selectedState)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Picker("Select Your Chapter", selection: $selectedChapterId) {
                            Text("None").tag(nil as UUID?)
                            ForEach(availableChapters) { chapter in
                                Text(chapter.displayName).tag(chapter.id as UUID?)
                            }
                        }
                        
                        if let chapterId = selectedChapterId,
                           let chapter = chapterManager.chapters.first(where: { $0.id == chapterId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Text("\(chapter.city), \(chapter.state)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Text("\(chapter.memberCount) members")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            Text("Save Changes")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                if let user = authManager.currentUser {
                    firstName = user.firstName
                    lastName = user.lastName
                    selectedState = user.state
                    university = user.university ?? ""
                    selectedChapterId = user.chapterId
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func saveProfile() {
        guard var user = authManager.currentUser else { return }
        
        user.firstName = firstName
        user.lastName = lastName
        user.state = selectedState
        user.university = university.isEmpty ? nil : university
        user.chapterId = selectedChapterId
        user.isMember = selectedChapterId != nil
        
        authManager.updateUser(user)
        presentationMode.wrappedValue.dismiss()
    }
}
