import SwiftUI
import AppUI

struct ContactDeveloperView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    DetailHeaderCard(
                        title: "Contact Developer",
                        subtitle: "Share feedback or report issues",
                        icon: "envelope.fill",
                        iconColor: .blue
                    )
                    .padding(.horizontal)
                    
                    // Form Section
                    FormSection(title: "Contact Information") {
                        VStack(spacing: 12) {
                            TextField("Your Name", text: $name)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Your Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                #if os(iOS)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                #endif
                        }
                    }
                    .padding(.horizontal)
                    
                    // Subject & Message
                    FormSection(title: "Message") {
                        VStack(spacing: 12) {
                            TextField("Subject", text: $subject)
                                .textFieldStyle(.roundedBorder)
                            
                            TextEditor(text: $message)
                                .frame(height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Section
                    FormSection(title: "Other Ways to Connect") {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                
                                Link("Visit Website", destination: URL(string: "https://www.example.com") ?? URL(fileURLWithPath: ""))
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                
                                Link("Email Direct", destination: URL(string: "mailto:developer@example.com") ?? URL(fileURLWithPath: ""))
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Send Button
                    VStack(spacing: 12) {
                        PrimaryButton("Send Message", icon: "paperplane.fill") {
                            sendMessage()
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Contact")
            .alert("Message Sent", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sendMessage() {
        // Simulate sending message
        alertMessage = "Your message has been sent. Thank you for reaching out!"
        showAlert = true
        
        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            name = ""
            email = ""
            subject = ""
            message = ""
        }
    }
}

#Preview {
    ContactDeveloperView()
}
