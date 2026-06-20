import SwiftUI
import Charts
import StoreKit

struct DashboardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPeriod = 0
    @State private var isMenuOpen = false
    let periods = ["Today", "This Week", "This Month"]
    
    // Sample data for chart
    let dailyData: [DailyMetric] = [
        DailyMetric(day: "Mon", taps: 42, spend: 21.00),
        DailyMetric(day: "Tue", taps: 38, spend: 19.00),
        DailyMetric(day: "Wed", taps: 55, spend: 27.50),
        DailyMetric(day: "Thu", taps: 48, spend: 24.00),
        DailyMetric(day: "Fri", taps: 67, spend: 33.50),
        DailyMetric(day: "Sat", taps: 89, spend: 44.50),
        DailyMetric(day: "Sun", taps: 72, spend: 36.00)
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header Section
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Dashboard")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Track your ad performance at a glance")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 20)
                        
                        // Period Selector
                        Picker("Period", selection: $selectedPeriod) {
                            ForEach(0..<periods.count, id: \.self) { index in
                                Text(periods[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                    }
                    
                    // Key Metrics Row
                    HStack(spacing: 12) {
                        KeyMetricCard(
                            title: "Total Taps",
                            value: "271",
                            change: "+12%",
                            changeIsPositive: true,
                            icon: "hand.tap.fill",
                            color: .blue
                        )
                        
                        KeyMetricCard(
                            title: "Total Spend",
                            value: "$156.00",
                            change: "+8%",
                            changeIsPositive: false,
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    HStack(spacing: 12) {
                        KeyMetricCard(
                            title: "Impressions",
                            value: "11.2K",
                            change: "+23%",
                            changeIsPositive: true,
                            icon: "eye.fill",
                            color: .purple
                        )
                        
                        KeyMetricCard(
                            title: "Tap Rate",
                            value: "2.8%",
                            change: "-0.3%",
                            changeIsPositive: false,
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Performance Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Performance Trend")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        Chart {
                            ForEach(dailyData) { data in
                                LineMark(
                                    x: .value("Day", data.day),
                                    y: .value("Taps", data.taps)
                                )
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("Day", data.day),
                                    y: .value("Taps", data.taps)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .frame(height: 200)
                        .chartYAxisLabel(position: .leading) {
                            Text("Taps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Top Campaigns
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Campaigns")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            ForEach(mockCampaigns.prefix(3), id: \.id) { campaign in
                                CampaignPerformanceRow(campaign: campaign)
                                
                                if campaign.id != mockCampaigns.prefix(3).last?.id {
                                    Divider()
                                        .padding(.leading, 68)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Button(action: {
                            dismiss()
                            NotificationCenter.default.post(name: NSNotification.Name("navigateToCampaigns"), object: nil)
                        }) {
                            Text("View All Campaigns")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
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
                    NotificationCenter.default.post(name: NSNotification.Name("navigateToCampaigns"), object: nil)
                case .dashboard:
                    dismiss()
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
    }
}

// MARK: - Key Metric Card
struct KeyMetricCard: View {
    let title: String
    let value: String
    let change: String
    let changeIsPositive: Bool
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
            
            HStack(spacing: 2) {
                Image(systemName: changeIsPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2)
                Text(change)
                    .font(.caption2)
            }
            .foregroundColor(changeIsPositive ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Campaign Performance Row
struct CampaignPerformanceRow: View {
    let campaign: MockCampaign
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(campaign.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                if campaign.isActive {
                    Text("Active")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                } else {
                    Text("Paused")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
            }
            
            HStack(spacing: 16) {
                MetricLabel(value: "\(campaign.taps)", label: "Taps")
                MetricLabel(value: "\(campaign.impressions)", label: "Impressions")
                MetricLabel(value: "$\(String(format: "%.2f", campaign.spent))", label: "Spent")
                Spacer()
            }
            
            // Progress bar for CTR
            let ctr = campaign.taps > 0 ? Double(campaign.taps) / Double(campaign.impressions) * 100 : 0
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("CTR")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", ctr))
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.primary)
                }
                ProgressView(value: ctr, total: 10)
                    .tint(.blue)
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Metric Label
struct MetricLabel: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Daily Metric Model
struct DailyMetric: Identifiable {
    let id = UUID()
    let day: String
    let taps: Int
    let spend: Double
}

// MARK: - Preview
#Preview {
    DashboardView()
}
