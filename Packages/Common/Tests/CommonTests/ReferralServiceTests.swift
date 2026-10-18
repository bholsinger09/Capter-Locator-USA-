//
//  ReferralServiceTests.swift
//  CommonTests
//
//  Created on October 18, 2026.
//

import XCTest
@testable import Common

class ReferralServiceTests: XCTestCase {
    
    var sut: ReferralService!
    let testUserId = UUID()
    let testChapterId = UUID()
    
    override func setUp() {
        super.setUp()
        sut = ReferralService()
        
        // Clear UserDefaults before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
    }
    
    // MARK: - Code Generation Tests
    
    func testGenerateReferralCode_CreatesValidCode() {
        let code = sut.generateReferralCode(for: testUserId)
        
        XCTAssertFalse(code.isEmpty, "Code should not be empty")
        XCTAssert(code.count <= 12, "Code should be reasonable length")
        XCTAssert(code.allSatisfy({ $0.isHexDigit || $0 == "-" }), "Code should contain valid characters")
    }
    
    func testGenerateReferralCode_DifferentUsersGetDifferentCodes() {
        let userId1 = UUID()
        let userId2 = UUID()
        
        let code1 = sut.generateReferralCode(for: userId1)
        let code2 = sut.generateReferralCode(for: userId2)
        
        // Codes might theoretically collide, but extremely unlikely
        XCTAssertNotEqual(code1, code2, "Different users should get different codes")
    }
    
    // MARK: - Personal Referral Code Tests
    
    func testCreatePersonalReferralCode_UpdatesUserReferralCode() {
        var testUser = createTestUser()
        XCTAssertNil(testUser.referralCode, "User should not have referral code initially")
        
        let referralCode = sut.createPersonalReferralCode(for: &testUser)
        
        XCTAssertNotNil(testUser.referralCode, "User should have referral code after creation")
        XCTAssertEqual(testUser.referralCode, referralCode.code, "User's code should match returned code")
    }
    
    func testCreatePersonalReferralCode_HasNoChapterId() {
        var testUser = createTestUser()
        
        let referralCode = sut.createPersonalReferralCode(for: &testUser)
        
        XCTAssertNil(referralCode.chapterId, "Personal referral code should not have chapter ID")
    }
    
    // MARK: - Chapter Referral Code Tests
    
    func testCreateChapterReferralCode_IncludesChapterId() {
        let referralCode = sut.createChapterReferralCode(for: testUserId, chapterId: testChapterId)
        
        XCTAssertEqual(referralCode.chapterId, testChapterId, "Chapter code should have chapter ID")
        XCTAssert(referralCode.code.contains("-"), "Chapter code should be formatted differently")
    }
    
    // MARK: - Referral Recording Tests
    
    func testRecordReferral_CreatesValidLink() {
        let refereeId = UUID()
        let refereeName = "John Smith"
        
        let link = sut.recordReferral(
            referrerId: testUserId,
            refereeId: refereeId,
            refereeName: refereeName,
            chapterId: testChapterId
        )
        
        XCTAssertEqual(link.referrerId, testUserId)
        XCTAssertEqual(link.refereeId, refereeId)
        XCTAssertEqual(link.refereeName, refereeName)
        XCTAssertEqual(link.chapterId, testChapterId)
        XCTAssertEqual(link.status, .joined)
    }
    
    func testRecordReferral_WithoutChapterId() {
        let refereeId = UUID()
        let refereeName = "Jane Doe"
        
        let link = sut.recordReferral(
            referrerId: testUserId,
            refereeId: refereeId,
            refereeName: refereeName
        )
        
        XCTAssertNil(link.chapterId, "Referral should not require chapter ID")
    }
    
    // MARK: - Retrieval Tests
    
    func testGetRecruitsForUser_ReturnsOnlyUserRecruits() {
        let userId1 = UUID()
        let userId2 = UUID()
        let refereeId1 = UUID()
        let refereeId2 = UUID()
        let refereeId3 = UUID()
        
        sut.recordReferral(referrerId: userId1, refereeId: refereeId1, refereeName: "Alice")
        sut.recordReferral(referrerId: userId1, refereeId: refereeId2, refereeName: "Bob")
        sut.recordReferral(referrerId: userId2, refereeId: refereeId3, refereeName: "Charlie")
        
        let recruits = sut.getRecruitsForUser(userId: userId1)
        
        XCTAssertEqual(recruits.count, 2, "User 1 should have 2 recruits")
        XCTAssert(recruits.allSatisfy { $0.referrerId == userId1 })
    }
    
    func testGetRecruitsForUser_ReturnsSortedByDateDescending() {
        let refereeId1 = UUID()
        let refereeId2 = UUID()
        
        // Record first referral
        sut.recordReferral(referrerId: testUserId, refereeId: refereeId1, refereeName: "First")
        
        // Wait a moment and record second
        usleep(100000) // 0.1 second
        sut.recordReferral(referrerId: testUserId, refereeId: refereeId2, refereeName: "Second")
        
        let recruits = sut.getRecruitsForUser(userId: testUserId)
        
        XCTAssertEqual(recruits.count, 2)
        XCTAssertGreaterThan(recruits[0].joinDate, recruits[1].joinDate, "Most recent should be first")
    }
    
    func testGetRecruitsForUser_EmptyIfNoRecruitsYet() {
        let recruits = sut.getRecruitsForUser(userId: testUserId)
        
        XCTAssertEqual(recruits.count, 0, "User with no recruits should return empty array")
    }
    
    // MARK: - Validation Tests
    
    func testValidateReferralCode_ValidCode() {
        var testUser = createTestUser()
        let referralCode = sut.createPersonalReferralCode(for: &testUser)
        
        let validatedUserId = sut.validateReferralCode(referralCode.code)
        
        XCTAssertEqual(validatedUserId, testUser.id, "Should return referrer ID for valid code")
    }
    
    func testValidateReferralCode_InvalidCode() {
        let validatedUserId = sut.validateReferralCode("INVALID123")
        
        XCTAssertNil(validatedUserId, "Should return nil for invalid code")
    }
    
    func testValidateReferralCode_InactiveCode() {
        var testUser = createTestUser()
        let referralCode = sut.createPersonalReferralCode(for: &testUser)
        
        sut.deactivateReferralCode(referralCode.code)
        
        let validatedUserId = sut.validateReferralCode(referralCode.code)
        
        XCTAssertNil(validatedUserId, "Should return nil for inactive code")
    }
    
    // MARK: - Deactivation Tests
    
    func testDeactivateReferralCode_MakesCodeInvalid() {
        var testUser = createTestUser()
        let referralCode = sut.createPersonalReferralCode(for: &testUser)
        
        // Verify code is valid first
        XCTAssertNotNil(sut.validateReferralCode(referralCode.code))
        
        // Deactivate
        sut.deactivateReferralCode(referralCode.code)
        
        // Verify code is now invalid
        XCTAssertNil(sut.validateReferralCode(referralCode.code))
    }
    
    // MARK: - Helper Methods
    
    private func createTestUser(id: UUID = UUID()) -> User {
        User(
            id: id,
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            state: "California"
        )
    }
}
