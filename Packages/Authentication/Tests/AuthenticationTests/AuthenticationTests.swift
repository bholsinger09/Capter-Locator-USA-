import XCTest
@testable import Authentication
import Common

final class AuthenticationManagerTests: XCTestCase {
    var authManager: AuthenticationManager!
    
    override func setUp() {
        super.setUp()
        authManager = AuthenticationManager()
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
    }
    
    func testInitialState() {
        let manager = AuthenticationManager()
        XCTAssertFalse(manager.isAuthenticated)
        XCTAssertNil(manager.currentUser)
        XCTAssertNil(manager.errorMessage)
    }
    
    func testSuccessfulRegistration() {
        authManager.register(
            email: "test@example.com",
            password: "password123",
            firstName: "John",
            lastName: "Doe",
            state: "California",
            university: "UC Berkeley"
        )
        
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertNotNil(authManager.currentUser)
        XCTAssertEqual(authManager.currentUser?.email, "test@example.com")
        XCTAssertEqual(authManager.currentUser?.firstName, "John")
        XCTAssertNil(authManager.errorMessage)
    }
    
    func testRegistrationWithDuplicateEmail() {
        // First registration
        authManager.register(
            email: "test@example.com",
            password: "password123",
            firstName: "John",
            lastName: "Doe",
            state: "California",
            university: nil
        )
        
        // Second registration with same email
        authManager.register(
            email: "test@example.com",
            password: "password456",
            firstName: "Jane",
            lastName: "Smith",
            state: "Texas",
            university: nil
        )
        
        XCTAssertNotNil(authManager.errorMessage)
        XCTAssertTrue(authManager.errorMessage?.contains("already exists") ?? false)
    }
    
    func testLoginWithValidCredentials() {
        // Register first
        authManager.register(
            email: "test@example.com",
            password: "password123",
            firstName: "John",
            lastName: "Doe",
            state: "California",
            university: nil
        )
        
        // Logout
        authManager.logout()
        XCTAssertFalse(authManager.isAuthenticated)
        
        // Login
        authManager.login(email: "test@example.com", password: "password123")
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertNotNil(authManager.currentUser)
    }
    
    func testLogout() {
        authManager.register(
            email: "test@example.com",
            password: "password123",
            firstName: "John",
            lastName: "Doe",
            state: "California",
            university: nil
        )
        
        authManager.logout()
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.currentUser)
    }
    
    func testDemoAccount() {
        authManager.login(email: "demo@appstore.com", password: "AppReview2025")
        
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertNotNil(authManager.currentUser)
        XCTAssertEqual(authManager.currentUser?.firstName, "Demo")
    }
}

final class AuthenticationViewModelTests: XCTestCase {
    var viewModel: AuthenticationViewModel!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        viewModel = AuthenticationViewModel(authService: mockAuthService)
    }
    
    func testLoginFormValidation() {
        XCTAssertFalse(viewModel.isLoginFormValid)
        
        viewModel.email = "test@example.com"
        XCTAssertFalse(viewModel.isLoginFormValid)
        
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isLoginFormValid)
    }
    
    func testRegistrationFormValidation() {
        XCTAssertFalse(viewModel.isRegistrationFormValid)
        
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password456"
        XCTAssertFalse(viewModel.isRegistrationFormValid) // Passwords don't match
        
        viewModel.confirmPassword = "password123"
        XCTAssertTrue(viewModel.isRegistrationFormValid)
    }
    
    func testToggleMode() {
        let initialMode = viewModel.isLoginMode
        viewModel.toggleMode()
        XCTAssertNotEqual(initialMode, viewModel.isLoginMode)
    }
    
    func testClearForm() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.firstName = "John"
        
        viewModel.clearForm()
        
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertTrue(viewModel.firstName.isEmpty)
    }
}

// Mock Authentication Service for testing
final class MockAuthenticationService: AuthenticationServiceProtocol {
    public var isAuthenticated = false
    public var currentUser: User?
    public var errorMessage: String?
    
    public func register(email: String, password: String, firstName: String, lastName: String, state: String, university: String?) {
        let newUser = User(
            email: email,
            firstName: firstName,
            lastName: lastName,
            state: state,
            university: university
        )
        currentUser = newUser
        isAuthenticated = true
    }
    
    public func login(email: String, password: String) {
        currentUser = User(email: email, firstName: "Test", lastName: "User", state: "California")
        isAuthenticated = true
    }
    
    public func logout() {
        isAuthenticated = false
        currentUser = nil
    }
    
    public func updateUser(_ user: User) {
        currentUser = user
    }
    
    public func signInWithApple(authorization: AuthenticationServices.ASAuthorization) {
        // Mock implementation
    }
}

