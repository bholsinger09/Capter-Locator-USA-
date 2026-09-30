import SwiftUI

struct DisclaimerView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Disclaimer")
                .font(.title)
            
            Text("This application is provided as-is.")
                .font(.body)
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Text("I Agree")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
