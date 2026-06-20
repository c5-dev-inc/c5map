import SwiftUI
import StoreKit

struct CampaignListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingCreateCampaign = false
    @State private var showingAIAssistant = false
    @State private var selectedFilter = 0
    @State private var isMenuOpen = false
    let filters = ["Active", "Paused", "All"]
    
    var filteredCampaigns: [MockCampaign] {
        switch selectedFilter {
        case 0:
            return mockCampaigns.filter { $0.isActive }
        case 1:
            return mockCampaigns.filter { !$0.isActive }
        default:
            return mockCampaigns
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "megaphone.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Campaigns")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Create and manage your Apple Maps ad campaigns")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 20)
                        
                        // Two Create Buttons
                        VStack(spacing: 12) {
                            Button(action: { showingCreateCampaign = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.body)
                                    Text("Create Campaign (Manual)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                        .font(.body)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                            
                            Button(action: { showingAIAssistant = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.body)
                                    Text("Create with AI (30 sec)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(0..<filters.count, id: \.self) { index in
                                Text(filters[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                    }
                    
                    // MARK: - Campaigns List Section
                    if !filteredCampaigns.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Campaigns")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                ForEach(filteredCampaigns) { campaign in
                                    CampaignRow(campaign: campaign)
                                    
                                    if campaign.id != filteredCampaigns.last?.id {
                                        Divider()
                                            .padding(.leading, 68)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "megaphone")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text(selectedFilter == 0 ? "No Active Campaigns" : "No Campaigns Yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(selectedFilter == 0 ? "Create a campaign to start getting customers" : "Tap the button above to create your first campaign")
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
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToBusiness"), object: nil)
                case .campaigns:
                    dismiss()
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
        .sheet(isPresented: $showingCreateCampaign) {
            CreateCampaignView()
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView()
        }
    }
}

// MARK: - Campaign Row
struct CampaignRow: View {
    let campaign: MockCampaign
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(campaign.isActive ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: campaign.isActive ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(campaign.isActive ? .green : .red)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(campaign.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(campaign.taps) taps", systemImage: "hand.tap")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Label("$\(String(format: "%.2f", campaign.spent))", systemImage: "dollar")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if campaign.isActive {
                        Text("Active")
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    } else {
                        Text("Paused")
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                    
                    Text("CTR: \(String(format: "%.1f%%", campaign.taps > 0 ? Double(campaign.taps) / Double(campaign.impressions) * 100 : 0))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetails) {
            CampaignDetailView(campaign: campaign)
        }
    }
}

// MARK: - Campaign Detail View
struct CampaignDetailView: View {
    let campaign: MockCampaign
    @Environment(\.dismiss) var dismiss
    @State private var isActive = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "megaphone.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text(campaign.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        HStack {
                            Text("Campaign Status")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle(isOn: $isActive) {
                                Text(isActive ? "Active" : "Paused")
                                    .font(.subheadline)
                                    .foregroundColor(isActive ? .green : .red)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .frame(width: 100)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: 12) {
                            DetailMetricCard(title: "Total Taps", value: "\(campaign.taps)", icon: "hand.tap.fill", color: .blue)
                            DetailMetricCard(title: "Total Spend", value: "$\(String(format: "%.2f", campaign.spent))", icon: "dollarsign.circle.fill", color: .green)
                        }
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: 12) {
                            DetailMetricCard(title: "Impressions", value: "\(campaign.impressions)", icon: "eye.fill", color: .purple)
                            DetailMetricCard(title: "Tap Rate", value: String(format: "%.1f%%", campaign.taps > 0 ? Double(campaign.taps) / Double(campaign.impressions) * 100 : 0), icon: "chart.line.uptrend.xyaxis", color: .orange)
                        }
                        .padding(.horizontal, 16)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Budget")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("Daily Budget")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$10.00")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("Total Spent")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(String(format: "%.2f", campaign.spent))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            
                            ProgressView(value: campaign.spent, total: 300)
                                .tint(.blue)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack { Spacer(); Text("Edit Campaign").font(.headline).fontWeight(.semibold); Spacer() }
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                HStack { Spacer(); Text("Duplicate Campaign").font(.headline).fontWeight(.semibold); Spacer() }
                                .padding(.vertical, 14)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { dismiss() }) {
                                HStack { Spacer(); Text("Delete Campaign").font(.headline).fontWeight(.semibold); Spacer() }
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Detail Metric Card
struct DetailMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    CampaignListView()
}
