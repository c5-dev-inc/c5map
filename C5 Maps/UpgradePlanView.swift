//
//  UpgradePlanView.swift
//  C5 Maps
//

import SwiftUI

struct UpgradePlanView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedPlanId: String = "growth"
    @State private var billingCycle: BillingCycle = .monthly
    var onComplete: (() -> Void)?
    
    enum BillingCycle: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    let plans = [
        Plan(
            id: "launch",
            name: "Launch",
            tagline: "Get on map",
            price: "$99",
            yearlyPrice: nil,
            features: [
                "Add locations",
                "Full branding",
                "AI Assistant"
            ],
            popular: false,
            badge: "ONE-TIME",
            color: .blue
        ),
        Plan(
            id: "growth",
            name: "Growth",
            tagline: "Accept payments",
            price: "$29.99",
            yearlyPrice: "$287",
            features: [
                "Launch features",
                "Tap to Pay",
                "Priority support",
                "No commissions"
            ],
            popular: true,
            badge: "POPULAR",
            color: .purple
        ),
        Plan(
            id: "scale",
            name: "Scale",
            tagline: "Full suite",
            price: "$49.99",
            yearlyPrice: "$479",
            features: [
                "Growth features",
                "Early access",
                "Premium support",
                "Stripe Connect"
            ],
            popular: false,
            badge: "BEST VALUE",
            color: .orange
        )
    ]
    
    var currentPlan: Plan {
        plans.first(where: { $0.id == selectedPlanId }) ?? plans[1]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                                .blur(radius: 20)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .padding(.bottom, 4)
                        
                        Text("Choose Your Plan")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text("Pick the plan that fits your business")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Billing Toggle
                    HStack(spacing: 0) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Button(action: {
                                withAnimation(.spring()) {
                                    billingCycle = cycle
                                }
                            }) {
                                Text(cycle.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(billingCycle == cycle ? Color.blue : Color.clear)
                                    )
                                    .foregroundColor(billingCycle == cycle ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Plan Grid (3 Columns)
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 8) {
                        ForEach(plans, id: \.id) { plan in
                            PlanCard(
                                plan: plan,
                                isSelected: selectedPlanId == plan.id,
                                billingCycle: billingCycle,
                                onSelect: {
                                    withAnimation(.spring()) {
                                        selectedPlanId = plan.id
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - Continue Button
                    Button(action: continueTapped) {
                        VStack(spacing: 4) {
                            Text("Continue with \(currentPlan.name)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if billingCycle == .monthly {
                                Text("\(currentPlan.price)/month - Cancel anytime")
                                    .font(.caption)
                                    .opacity(0.8)
                            } else {
                                Text("\(currentPlan.yearlyPrice ?? currentPlan.price)/year - Cancel anytime")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Legal Footer
                    VStack(spacing: 12) {
                        Divider()
                        
                        HStack(spacing: 16) {
                            Link(destination: URL(string: "https://c5-dev.com/maps/terms")!) {
                                Text("Terms")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Link(destination: URL(string: "https://c5-dev.com/maps/privacy")!) {
                                Text("Privacy")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Link(destination: URL(string: "mailto:support@c5-dev.com")!) {
                                Text("Support")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24-hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .background(colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(colorScheme == .dark ? .gray : .gray)
                    }
                }
            }
        }
    }
    
    // MARK: - Continue Action
    private func continueTapped() {
        print("✅ User selected: \(currentPlan.name) - \(billingCycle.rawValue)")
        print("💰 Price: \(billingCycle == .monthly ? currentPlan.price : currentPlan.yearlyPrice ?? currentPlan.price)")
        
        // MARK: - THIS IS WHAT HAPPENS:
        // 1. Set subscription active in AuthManager
        authManager.setSubscriptionActive(true)
        print("✅ AuthManager.hasSubscription = \(authManager.hasSubscription)")
        
        // 2. Call the completion handler (which dismisses and transitions)
        onComplete?()
        
        // 3. Dismiss the view
        dismiss()
    }
}

// MARK: - Plan Card Component
struct PlanCard: View {
    let plan: Plan
    let isSelected: Bool
    let billingCycle: UpgradePlanView.BillingCycle
    let onSelect: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var displayPrice: String {
        billingCycle == .monthly ? plan.price : plan.yearlyPrice ?? plan.price
    }
    
    var pricePeriod: String {
        if plan.id == "launch" {
            return ""
        }
        return billingCycle == .monthly ? "/mo" : "/yr"
    }
    
    var backgroundColor: Color {
        if isSelected {
            return colorScheme == .dark ? plan.color.opacity(0.15) : plan.color.opacity(0.08)
        } else {
            return colorScheme == .dark ? Color(white: 0.12) : Color.white
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Badge
                if let badge = plan.badge {
                    Text(badge)
                        .font(.system(size: 7, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(plan.popular ? Color.purple : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(3)
                        .padding(.bottom, 4)
                }
                
                // Name
                Text(plan.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                // Tagline
                Text(plan.tagline)
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
                
                // Price
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(displayPrice)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(plan.color)
                    
                    if !pricePeriod.isEmpty {
                        Text(pricePeriod)
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                            .padding(.leading, 1)
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Features
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundColor(isSelected ? plan.color : .green)
                            
                            Text(feature)
                                .font(.system(size: 8))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? plan.color : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: isSelected ? plan.color.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Plan Model
struct Plan {
    let id: String
    let name: String
    let tagline: String
    let price: String
    let yearlyPrice: String?
    let features: [String]
    let popular: Bool
    let badge: String?
    let color: Color
}

// MARK: - Preview
#Preview {
    UpgradePlanView()
        .environmentObject(AuthManager())
}
