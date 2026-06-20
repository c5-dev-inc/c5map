import SwiftUI
import StoreKit

// MARK: - Plan Model
struct Plan {
    let name: String
    let price: String
    let yearlyPrice: String?
    let features: [String]
    let popular: Bool
    let badge: String?
}

struct UpgradePlanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan = 1
    @State private var isPurchasing = false
    @State private var billingCycle: BillingCycle = .monthly
    var onComplete: (() -> Void)?
    
    enum BillingCycle: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly (Save 20%)"
    }
    
    let plans = [
        Plan(
            name: "Starter",
            price: "$29",
            yearlyPrice: "$278",
            features: [
                "1 business location",
                "Basic analytics dashboard",
                "Email support (24h response)",
                "AI keyword suggestions",
                "Monthly performance report"
            ],
            popular: false,
            badge: nil
        ),
        Plan(
            name: "Professional",
            price: "$79",
            yearlyPrice: "$758",
            features: [
                "5 business locations",
                "Advanced analytics & insights",
                "Priority support (4h response)",
                "AI campaign optimization",
                "Push notifications",
                "Real-time performance alerts",
                "Customer behavior tracking"
            ],
            popular: true,
            badge: "BEST VALUE"
        ),
        Plan(
            name: "Enterprise",
            price: "$199",
            yearlyPrice: "$1,990",
            features: [
                "Unlimited locations",
                "White-label reports",
                "API access & webhooks",
                "Dedicated account manager",
                "Team collaboration tools",
                "Custom branding",
                "SLA guarantee",
                "Advanced security features"
            ],
            popular: false,
            badge: nil
        )
    ]
    
    var currentPrice: String {
        let plan = plans[selectedPlan]
        return billingCycle == .monthly ? plan.price : plan.yearlyPrice ?? plan.price
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Hero Section
                        VStack(spacing: 16) {
                            // Animated crown
                            Image(systemName: "crown.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                                .padding(.top, 20)
                            
                            Text("Unlock Premium Features")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Get found by more customers and grow your business")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.bottom, 32)
                        
                        // MARK: - Billing Cycle Toggle
                        HStack(spacing: 8) {
                            ForEach(BillingCycle.allCases, id: \.self) { cycle in
                                Button(action: { withAnimation(.spring()) { billingCycle = cycle } }) {
                                    Text(cycle.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(billingCycle == cycle ? Color.blue : Color.clear)
                                        )
                                        .foregroundColor(billingCycle == cycle ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(
                            Capsule()
                                .fill(Color(.systemGray5))
                                .padding(2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        
                        // MARK: - Plan Cards
                        VStack(spacing: 16) {
                            ForEach(Array(plans.enumerated()), id: \.offset) { index, plan in
                                PlanCard(
                                    plan: plan,
                                    isSelected: selectedPlan == index,
                                    billingCycle: billingCycle,
                                    onSelect: { selectedPlan = index }
                                )
                                .scaleEffect(selectedPlan == index && plan.popular ? 1.02 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedPlan)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                        
                        // MARK: - Subscribe Button
                        VStack(spacing: 12) {
                            Button(action: startPurchase) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Start 7-Day Free Trial")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Text(currentPrice)
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .opacity(0.9)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(isPurchasing)
                            
                            Text("No commitment • Cancel anytime")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        
                        // MARK: - Footer
                        VStack(spacing: 12) {
                            Divider()
                            
                            HStack(spacing: 16) {
                                Link("Terms", destination: URL(string: "https://c5-dev.com/maps/terms")!)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Link("Privacy", destination: URL(string: "https://c5-dev.com/maps/privacy")!)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Link("Support", destination: URL(string: "mailto:support@c5-dev.com")!)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                            
                            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 30)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .overlay {
                if isPurchasing {
                    ProcessingOverlay()
                }
            }
        }
    }
    
    private func startPurchase() {
        withAnimation { isPurchasing = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isPurchasing = false
                onComplete?()
                dismiss()
            }
        }
    }
}

// MARK: - Plan Card Component
struct PlanCard: View {
    let plan: Plan
    let isSelected: Bool
    let billingCycle: UpgradePlanView.BillingCycle
    let onSelect: () -> Void
    
    var displayPrice: String {
        billingCycle == .monthly ? plan.price : plan.yearlyPrice ?? plan.price
    }
    
    var pricePeriod: String {
        billingCycle == .monthly ? "per month" : "per year"
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(plan.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else if plan.popular {
                            Text("POPULAR")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Price
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(displayPrice)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text(pricePeriod)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if billingCycle == .yearly && plan.yearlyPrice != nil {
                        Text("Save 20% vs monthly billing")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                            .padding(.top, 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(isSelected ? .blue : .green)
                            
                            Text(feature)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                // Selection indicator
                if isSelected {
                    HStack {
                        Spacer()
                        Text("SELECTED")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.05),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Processing Overlay
struct ProcessingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Processing your subscription...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    UpgradePlanView()
}
