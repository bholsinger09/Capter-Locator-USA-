import SwiftUI

struct PoliticalPartyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedParty: PoliticalParty?
    @State private var showDetailView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.08, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        
                        Text("Find Your Political Alignment")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Explore where your values align")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // Political Parties List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(PoliticalPartyGuidance.parties) { party in
                                NavigationLink(destination: PoliticalPartyDetailView(party: party)) {
                                    PoliticalPartyCard(party: party)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PoliticalPartyCard: View {
    let party: PoliticalParty
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(party.emoji)
                    .font(.system(size: 48))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(party.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(party.tagline)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            
            Text(party.description)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white.opacity(0.8))
                .lineLimit(2)
        }
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PoliticalPartyDetailView: View {
    let party: PoliticalParty
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Party Header
                        VStack(alignment: .center, spacing: 12) {
                            Text(party.emoji)
                                .font(.system(size: 72))
                            
                            Text(party.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(party.tagline)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                        
                        // Core Values
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Core Values")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(party.coreValues, id: \.self) { value in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.green)
                                        
                                        Text(value)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(Color.white.opacity(0.9))
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                        
                        // Economic Approach
                        DetailSection(
                            title: "Economic Approach",
                            description: party.economicApproach,
                            icon: "💰"
                        )
                        
                        // Social Approach
                        DetailSection(
                            title: "Social Approach",
                            description: party.socialApproach,
                            icon: "👥"
                        )
                        
                        // Environmental Approach
                        DetailSection(
                            title: "Environmental Approach",
                            description: party.environmentalApproach,
                            icon: "🌍"
                        )
                        
                        // Full Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(party.description)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct DetailSection: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}

#Preview {
    PoliticalPartyView()
}
