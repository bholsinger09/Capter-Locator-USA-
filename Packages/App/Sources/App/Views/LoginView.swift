import SwiftUI
import AuthenticationServices
import Authentication

public struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @ObservedObject var authenticationManager: AuthenticationManager
    
    public var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 1.0),
                    Color(red: 0.8, green: 0.5, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // App Title
                VStack(spacing: 8) {
                    Text("Swift Chapter USA")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Finder")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Login Form
                VStack(spacing: 16) {
                    // Email Field
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        TextField("Enter your email", text: $email)
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack {
                            if showPassword {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Login Button
                Button(action: {
                    // Simple validation - in production, call auth service
                    if !email.isEmpty && !password.isEmpty {
                        // TODO: Implement email/password login with authenticationManager
                        authenticationManager.errorMessage = "Email/password login not yet implemented"
                    }
                }) {
                    Text("Login")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(
                            (email.isEmpty || password.isEmpty)
                                ? Color.gray.opacity(0.5)
                                : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.horizontal, 20)
                
                // Divider
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("or")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                    VStack {
                        Divider()
                    }
                }
                .padding(.horizontal, 20)
                
                // Sign in with Apple Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        print("🍎 [LoginView] Apple Sign-In completion handler triggered")
                        switch result {
                        case .success(let authorization):
                            print("🍎 [LoginView] SUCCESS - calling authenticationManager.signInWithApple")
                            authenticationManager.signInWithApple(authorization: authorization)
                        case .failure(let error):
                            print("🍎 [LoginView] FAILURE - \(error.localizedDescription)")
                            authenticationManager.errorMessage = error.localizedDescription
                        }
                    }
                )
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                }
                .font(.body)
                .padding(.vertical, 10)
                
                Spacer()
                    .frame(height: 40)
            }
        }
    }
    
    public init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
    }
}

#Preview {
    LoginView(authenticationManager: AuthenticationManager())
}
