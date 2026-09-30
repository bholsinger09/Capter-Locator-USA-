import SwiftUI

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Event Details")
                .font(.title)
            Spacer()
        }
    }
}
