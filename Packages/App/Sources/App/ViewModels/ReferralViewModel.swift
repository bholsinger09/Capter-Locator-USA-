//
//  ReferralViewModel.swift
//  App
//
//  Created on October 18, 2026.
//

import Foundation
import Combine
import Common
import Authentication
import UIKit

public class ReferralViewModel: ObservableObject {
    @Published public var currentUser: User?
    @Published public var recruits: [ReferralLink] = []
    @Published public var isLoading = false
    @Published public var referralCode: String?
    @Published public var referralLink: String?
    
    private let referralService: ReferralService
    private let authenticationManager: AuthenticationManager
    
    public init(
        referralService: ReferralService,
        authenticationManager: AuthenticationManager
    ) {
        self.referralService = referralService
        self.authenticationManager = authenticationManager
        self.currentUser = authenticationManager.currentUser
        
        setupBindings()
        loadReferralCode()
        loadRecruits()
    }
    
    private func setupBindings() {
        authenticationManager.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                self?.loadReferralCode()
                self?.loadRecruits()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    public func createPersonalReferralCode() {
        guard var user = currentUser else { return }
        
        isLoading = true
        
        let code = referralService.createPersonalReferralCode(for: &user)
        authenticationManager.updateUser(user)
        currentUser = user
        
        referralCode = code.code
        referralLink = QRCodeGenerator.generateReferralLink(for: user.id)
        
        isLoading = false
    }
    
    public func createChapterReferralCode(for chapterId: UUID) {
        guard let user = currentUser else { return }
        
        let code = referralService.createChapterReferralCode(for: user.id, chapterId: chapterId)
        referralCode = code.code
        referralLink = QRCodeGenerator.generateChapterReferralLink(for: user.id, chapterId: chapterId)
    }
    
    public func loadRecruits() {
        guard let userId = currentUser?.id else { return }
        
        recruits = referralService.getRecruitsForUser(userId: userId)
    }
    
    private func loadReferralCode() {
        print("DEBUG loadReferralCode: currentUser = \(currentUser != nil ? currentUser!.email : "nil")")
        guard let user = currentUser else { 
            print("DEBUG loadReferralCode: user is nil")
            return 
        }
        
        print("DEBUG loadReferralCode: user.referralCode = \(user.referralCode ?? "nil")")
        if let code = user.referralCode {
            referralCode = code
            referralLink = QRCodeGenerator.generateReferralLink(for: user.id)
            print("DEBUG loadReferralCode: Set referralCode=\(code), referralLink=\(referralLink ?? "nil")")
        } else {
            print("DEBUG loadReferralCode: user has no referralCode")
        }
    }
    
    public func recordNewRecruit(from referralCode: String, newUser: User, chapterId: UUID? = nil) {
        guard let referrerId = referralService.validateReferralCode(referralCode) else {
            return
        }
        
        _ = referralService.recordReferral(
            referrerId: referrerId,
            refereeId: newUser.id,
            refereeName: newUser.fullName,
            chapterId: chapterId
        )
        
        loadRecruits()
    }
    
    public func getQRImage() -> UIImage? {
        print("DEBUG getQRImage: referralLink = \(referralLink ?? "nil")")
        print("DEBUG getQRImage: referralCode = \(referralCode ?? "nil")")
        guard let link = referralLink else { 
            print("DEBUG: referralLink is nil, cannot generate QR")
            return nil 
        }
        let image = QRCodeGenerator.generateQRCode(from: link)
        print("DEBUG: Generated QR image: \(image != nil ? "success" : "failed")")
        return image
    }
    
    public func getShareText() -> String {
        guard let user = currentUser else { return "" }
        
        let greeting = """
        Join me on the Chapter Locator USA! 🇺🇸
        """
        
        let mainMessage = """
        Connect with conservative students at your university and take action for freedom and constitutional principles.
        """
        
        let callToAction = """
        Use my referral link or scan my QR code to join:
        """
        
        return """
        \(greeting)
        
        \(mainMessage)
        
        \(callToAction)
        \(referralLink ?? "")
        
        — \(user.firstName)
        """
    }
    
    public func shareReferralCode() {
        // This will be called from the UI to trigger the native share sheet
        // Implementation will be in the SwiftUI view
    }
    
    // MARK: - Post-Signup Referral Recording
    
    public func recordSignupFromReferral(newUser: User) {
        // Called after a new user completes signup via referral link
        // Checks if there's a pending referrer ID and records the relationship
        
        guard let referrerId = newUser.referredBy else {
            return // User wasn't referred
        }
        
        _ = referralService.recordReferral(
            referrerId: referrerId,
            refereeId: newUser.id,
            refereeName: newUser.fullName,
            chapterId: newUser.chapterId
        )
        
        // Reload recruits for all users (in case referrer is viewing)
        loadRecruits()
    }
}
