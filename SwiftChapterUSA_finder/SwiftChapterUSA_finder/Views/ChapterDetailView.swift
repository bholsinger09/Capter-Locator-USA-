import SwiftUI

struct ChapterDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Chapter Details")
                .font(.title)
            Spacer()
        }
    }
}
