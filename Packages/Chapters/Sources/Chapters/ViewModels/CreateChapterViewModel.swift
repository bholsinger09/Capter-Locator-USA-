//
//  CreateChapterViewModel.swift
//  Chapters
//
//  Part of SwiftChapterUSA Package Migration
//

import Foundation
import Common

public class CreateChapterViewModel: ObservableObject {
    @Published public var name: String = ""
    @Published public var state: String = "Alabama"
    @Published public var city: String = ""
    @Published public var university: String = ""
    @Published public var presidentName: String = ""
    @Published public var contactEmail: String = ""
    @Published public var phoneNumber: String = ""
    @Published public var description: String = ""
    @Published public var meetingLocation: String = ""
    @Published public var meetingSchedule: String = ""
    @Published public var errorMessage: String?
    
    public init() {}
    
    public var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !presidentName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !contactEmail.isEmpty &&
        Validators.isValidEmail(contactEmail) &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    public func createChapter() -> Chapter? {
        guard isFormValid else {
            errorMessage = "Please fill all required fields"
            return nil
        }
        
        let chapter = Chapter(
            name: name,
            state: state,
            city: city,
            university: university.isEmpty ? nil : university,
            presidentName: presidentName,
            contactEmail: contactEmail,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            description: description,
            memberCount: 1,
            meetingLocation: meetingLocation.isEmpty ? nil : meetingLocation,
            meetingSchedule: meetingSchedule.isEmpty ? nil : meetingSchedule,
            dateEstablished: Date()
        )
        
        return chapter
    }
    
    public func resetForm() {
        name = ""
        state = "Alabama"
        city = ""
        university = ""
        presidentName = ""
        contactEmail = ""
        phoneNumber = ""
        description = ""
        meetingLocation = ""
        meetingSchedule = ""
        errorMessage = nil
    }
}
