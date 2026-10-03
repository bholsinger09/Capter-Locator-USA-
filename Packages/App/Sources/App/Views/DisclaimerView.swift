import SwiftUI

struct DisclaimerView: View {
    @Binding var isPresented: Bool
    @State private var hasAgreed = false
    
    var body: some View {
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
                
                // Warning Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                // Title
                Text("Important Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Disclaimer Box
                VStack(alignment: .leading, spacing: 12) {
                    Text("This application is NOT the official Turning Point USA app.")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("This app is an independent tool created to help people find local Turning Point USA chapters and connect with other members.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("For the official Turning Point USA app and resources, please visit:")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Link(destination: URL(string: "https://www.tpusa.com")!) {
                        Text("www.tpusa.com")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Agreement Toggle
                HStack {
                    Text("I understand and agree to continue")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $hasAgreed)
                        .labelsHidden()
                        .tint(.blue)
                }
                .padding(.horizontal, 20)
                
                // Continue Button
                Button(action: {
                    if hasAgreed {
                        isPresented = false
                    }
                }) {
                    Text("Continue")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(hasAgreed ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!hasAgreed)
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 30)
            }
        }
    }
}
