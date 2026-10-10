import SwiftUI
import Events
import AppUI

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let event: Event?
    
    init(event: Event? = nil) {
        self.event = event ?? Event.sample
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                DetailHeaderCard(
                    title: event?.title ?? "Event",
                    subtitle: event?.eventDate.formatted("MMM dd, yyyy") ?? "",
                    icon: "calendar.badge.clock",
                    iconColor: .blue
                )
                .padding(.horizontal)
                
                // Event Details Section
                FormSection(title: "Event Details") {
                    VStack(spacing: 12) {
                        DetailRow(
                            label: "Date & Time",
                            value: event?.eventDate.formatted("MMM dd, yyyy 'at' h:mm a") ?? "",
                            icon: "calendar"
                        )
                        
                        Divider()
                        
                        DetailRow(
                            label: "Location",
                            value: event?.location ?? "TBA",
                            icon: "mappin.circle.fill"
                        )
                        
                        Divider()
                        
                        DetailRow(
                            label: "Capacity",
                            value: event?.capacity.map { "\($0) people" } ?? "Unlimited",
                            icon: "person.2.fill"
                        )
                    }
                }
                .padding(.horizontal)
                
                // Organizer Section
                FormSection(title: "Organizer") {
                    DetailRow(
                        label: "Name",
                        value: event?.organizerName ?? "Unknown",
                        icon: "person.fill"
                    )
                }
                .padding(.horizontal)
                
                // Description Section
                if let description = event?.description, !description.isEmpty {
                    FormSection(title: "About This Event") {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    PrimaryButton("RSVP to Event", icon: "checkmark.circle") {
                        print("RSVP tapped")
                    }
                    
                    SecondaryButton("Share Event", icon: "square.and.arrow.up") {
                        print("Share tapped")
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Event Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationView {
        EventDetailView()
    }
}

