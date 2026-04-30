//
//  CreateChapterView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct CreateChapterView: View {
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var chapterName = ""
    @State private var selectedState = "Alabama"
    @State private var city = ""
    @State private var university = ""
    @State private var presidentName = ""
    @State private var contactEmail = ""
    @State private var phoneNumber = ""
    @State private var description = ""
    @State private var meetingLocation = ""
    @State private var meetingSchedule = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chapter Information")) {
                    TextField("Chapter Name", text: $chapterName)
                    
                    Picker("State", selection: $selectedState) {
                        ForEach(usStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    
                    TextField("City", text: $city)
                    
                    TextField("University (Optional)", text: $university)
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("President Name", text: $presidentName)
                    
                    TextField("Contact Email", text: $contactEmail)
                    
                    TextField("Phone Number (Optional)", text: $phoneNumber)
                }
                
                Section(header: Text("Chapter Details")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Meeting Information (Optional)")) {
                    TextField("Meeting Location", text: $meetingLocation)
                    
                    TextField("Meeting Schedule (e.g., Mondays 6PM)", text: $meetingSchedule)
                }
                
                Section {
                    Button(action: createChapter) {
                        HStack {
                            Spacer()
                            Text("Create Chapter")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Create Chapter")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Chapter Created", isPresented: $showingAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private var isFormValid: Bool {
        !chapterName.isEmpty &&
        !city.isEmpty &&
        !presidentName.isEmpty &&
        !contactEmail.isEmpty &&
        contactEmail.contains("@") &&
        !description.isEmpty
    }
    
    private func createChapter() {
        let newChapter = Chapter(
            name: chapterName,
            state: selectedState,
            city: city,
            university: university.isEmpty ? nil : university,
            presidentName: presidentName,
            contactEmail: contactEmail,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            description: description,
            memberCount: 1,
            meetingLocation: meetingLocation.isEmpty ? nil : meetingLocation,
            meetingSchedule: meetingSchedule.isEmpty ? nil : meetingSchedule,
            dateEstablished: Date(),
            isActive: true
        )
        
        chapterManager.addChapter(newChapter)
        
        alertMessage = "Your chapter '\(chapterName)' has been successfully created!"
        showingAlert = true
    }
}
