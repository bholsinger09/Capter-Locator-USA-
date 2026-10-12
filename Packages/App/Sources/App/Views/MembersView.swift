import SwiftUI
import Common
import AppUI

struct MembersView: View {
    @StateObject private var viewModel = ProfileViewModel()
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
            NavigationView {
                VStack(spacing: 0) {
                    List {
                        ForEach(chapters, id: \.self) { chapter in
                            Button(action: {
                                selectedChapter = chapter
                                showChapterPicker = false
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(chapter)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    if chapter == selectedChapter {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .navigationTitle("Join Chapter")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showChapterPicker = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var chapters: [String] {
        [
            "Arizona State",
            "Alabama State",
            "Arkansas State",
            "Auburn University",
            "Brigham Young University",
            "University of California, Berkeley",
            "Clemson University",
            "Colorado State",
            "University of Connecticut",
            "Cornell University",
            "Duke University",
            "University of Florida",
            "Georgia Tech",
            "Harvard University",
            "University of Illinois",
            "Indiana University",
            "University of Iowa",
            "Kansas State",
            "University of Kansas",
            "University of Kentucky",
            "Louisiana State",
            "University of Maine",
            "University of Maryland",
            "MIT",
            "University of Massachusetts",
            "University of Michigan",
            "Michigan State",
            "University of Minnesota",
            "Mississippi State",
            "University of Mississippi",
            "University of Missouri",
            "University of Montana",
            "University of Nebraska",
            "University of Nevada, Las Vegas",
            "University of New Hampshire",
            "University of New Mexico",
            "New York University",
            "University of North Carolina",
            "North Carolina State",
            "University of North Dakota",
            "Northwestern University",
            "Ohio State",
            "University of Oklahoma",
            "Oklahoma State",
            "University of Oregon",
            "Pennsylvania State",
            "University of Pennsylvania",
            "Pepperdine University",
            "Princeton University",
            "University of Rhode Island",
            "Rice University",
            "Rutgers University",
            "Stanford University",
            "Southern Methodist University",
            "University of South Carolina",
            "South Dakota State",
            "University of Tennessee",
            "Texas A&M",
            "Texas State",
            "University of Texas at Austin",
            "Texas Tech",
            "University of Toledo",
            "Tulane University",
            "University of Utah",
            "Vanderbilt University",
            "University of Virginia",
            "Virginia Tech",
            "University of Washington",
            "Washington State",
            "University of Wisconsin",
            "University of Wyoming",
            "Yale University"
        ]
    }
}



#Preview {
    MembersView()
}
