import SwiftUI
import StoreKit

struct BusinessView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingRegisterBusiness = false
    @State private var showingConnectExisting = false
    @State private var connectedLocations: [MockLocation] = mockLocations
    @State private var isMenuOpen = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 52))
                                .foregroundColor(.blue)
                            
                            Text("Your Businesses")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Register a new business or connect an existing one to start running ads on Apple Maps.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 20)
                        
                        // Action Cards
                        VStack(spacing: 16) {
                            // Register New Business Card
                            Button(action: { showingRegisterBusiness = true }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Register New Business")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text("Add your business to Apple Maps for the first time")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            
                            // Connect Existing Business Card
                            Button(action: { showingConnectExisting = true }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "link.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Connect Existing Business")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text("Link your verified Apple Business account")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // MARK: - Connected Businesses Section
                    if !connectedLocations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connected Businesses")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(connectedLocations) { location in
                                    BusinessLocationCard(location: location)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "building.2")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Connected Businesses")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Tap above to register or connect your first business")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            
            // MARK: - Menu Button Overlay
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.25)) {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                Spacer()
            }
            
            // MARK: - Menu View
            MenuView(isMenuOpen: $isMenuOpen) { action in
                switch action {
                case .business:
                    dismiss()
                case .campaigns:
                    dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToCampaigns"), object: nil)
                case .dashboard:
                    dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToDashboard"), object: nil)
                case .upgrade:
                    dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToUpgrade"), object: nil)
                case .help:
                    if let url = URL(string: "https://c5-dev.com/maps/support") {
                        UIApplication.shared.open(url)
                    }
                case .contact:
                    if let url = URL(string: "mailto:support@c5-dev.com") {
                        UIApplication.shared.open(url)
                    }
                case .privacy:
                    if let url = URL(string: "https://c5-dev.com/maps/privacy") {
                        UIApplication.shared.open(url)
                    }
                case .terms:
                    if let url = URL(string: "https://c5-dev.com/maps/terms") {
                        UIApplication.shared.open(url)
                    }
                case .rate:
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                case .signOut:
                    dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("signOut"), object: nil)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingRegisterBusiness) {
            ConnectBusinessView()
        }
        .sheet(isPresented: $showingConnectExisting) {
            ConnectExistingView()
        }
    }
}

// MARK: - Business Location Card
struct BusinessLocationCard: View {
    let location: MockLocation
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(location.status == "Connected" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: location.status == "Connected" ? "checkmark.circle.fill" : "clock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(location.status == "Connected" ? .green : .orange)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(location.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(location.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(location.status == "Connected" ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(location.status)
                        .font(.caption2)
                        .foregroundColor(location.status == "Connected" ? .green : .orange)
                }
            }
            
            Spacer()
            
            if location.status == "Pending" {
                Text("Verify")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    BusinessView()
}
