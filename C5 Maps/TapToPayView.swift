import SwiftUI
import Supabase

// MARK: - Payment Link Model
struct PaymentLink: Identifiable, Codable {
    let id: Int
    let userId: Int
    let provider: String
    let paymentLink: String
    let status: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case provider
        case paymentLink = "payment_link"
        case status
        case createdAt = "created_at"
    }
}

struct PaymentLinkInsert: Codable {
    let userId: Int
    let provider: String
    let paymentLink: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case provider
        case paymentLink = "payment_link"
        case status
    }
}

struct TapToPayView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var paymentLinks: [PaymentLink] = []
    @State private var selectedProvider: PaymentProvider = .stripe
    @State private var paymentLink = ""
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingUpgrade = false
    @FocusState private var isLinkFocused: Bool
    
    @AppStorage("cachedPaymentLinks") private var cachedPaymentLinksData: Data = Data()
    
    enum PaymentProvider: String, CaseIterable {
        case stripe = "Stripe"
        case paypal = "PayPal"
        case square = "Square"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .stripe: return "creditcard.fill"
            case .paypal: return "dollarsign.circle.fill"
            case .square: return "square.fill"
            case .other: return "link.circle.fill"
            }
        }
        
        var placeholder: String {
            switch self {
            case .stripe: return "https://buy.stripe.com/your-link"
            case .paypal: return "https://www.paypal.com/paypalme/yourname"
            case .square: return "https://square.link/u/yourlink"
            case .other: return "https://your-payment-link.com"
            }
        }
    }
    
    // MARK: - Computed Status
    private var activeLink: PaymentLink? {
        paymentLinks.first(where: { $0.status == "active" })
    }
    
    private var pendingLinks: [PaymentLink] {
        paymentLinks.filter { $0.status == "pending" }
    }
    
    private var statusColor: Color {
        if let active = activeLink {
            return .green
        } else if !pendingLinks.isEmpty {
            return .orange
        } else {
            return .gray
        }
    }
    
    private var statusIcon: String {
        if let _ = activeLink {
            return "checkmark.seal.fill"
        } else if !pendingLinks.isEmpty {
            return "clock.fill"
        } else {
            return "xmark.circle.fill"
        }
    }
    
    private var statusTitle: String {
        if let _ = activeLink {
            return "Active"
        } else if !pendingLinks.isEmpty {
            return "Pending Approval"
        } else {
            return "Not Connected"
        }
    }
    
    private var statusDescription: String {
        if let _ = activeLink {
            return "You're all set! Accept payments now."
        } else if !pendingLinks.isEmpty {
            return "Your link is being reviewed."
        } else {
            return "Add a payment link to get started."
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
                .onTapGesture {
                    isLinkFocused = false
                }
            
            // MARK: - Subscription Check
            if !authManager.hasSubscription {
                // Upgrade Required View
                VStack(spacing: 24) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Upgrade Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Tap to Pay is a premium feature. Upgrade your plan to accept payments.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        showingUpgrade = true
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade Plan")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 32)
                    }
                    .sheet(isPresented: $showingUpgrade) {
                        UpgradePlanView(onComplete: {
                            showingUpgrade = false
                            authManager.setSubscriptionActive(true)
                        })
                        .environmentObject(authManager)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 20)
                
            } else {
                // MARK: - Full Content (Active Subscription)
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header
                        VStack(spacing: 20) {
                            VStack(spacing: 12) {
                                Image(systemName: "iphone.and.arrow.forward")
                                    .font(.system(size: 48))
                                    .foregroundColor(.blue)
                                
                                Text("Tap to Pay")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Accept payments by sharing your payment link with customers")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 24)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 20)
                        }
                        
                        // MARK: - Status Card
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(statusColor.opacity(0.15))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: statusIcon)
                                        .font(.system(size: 24))
                                        .foregroundColor(statusColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(statusTitle)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text(statusDescription)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // MARK: - Existing Payment Links
                        if !paymentLinks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Saved Payment Links")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                
                                VStack(spacing: 0) {
                                    ForEach(paymentLinks) { link in
                                        PaymentLinkRow(link: link)
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // MARK: - Add Payment Link
                        VStack(spacing: 16) {
                            // Provider Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Payment Provider")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Menu {
                                    ForEach(PaymentProvider.allCases, id: \.self) { provider in
                                        Button(action: {
                                            selectedProvider = provider
                                        }) {
                                            HStack {
                                                Image(systemName: provider.icon)
                                                Text(provider.rawValue)
                                                if provider == selectedProvider {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: selectedProvider.icon)
                                            .foregroundColor(.blue)
                                        Text(selectedProvider.rawValue)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                            
                            // Payment Link Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Payment Link")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16))
                                    
                                    TextField(selectedProvider.placeholder, text: $paymentLink)
                                        .autocapitalization(.none)
                                        .keyboardType(.URL)
                                        .font(.subheadline)
                                        .focused($isLinkFocused)
                                    
                                    if !paymentLink.isEmpty {
                                        Button(action: {
                                            paymentLink = ""
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 4)
                            
                            if !paymentLink.isEmpty {
                                Button(action: {
                                    savePaymentLink()
                                }) {
                                    HStack(spacing: 12) {
                                        if isSaving {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.body)
                                        }
                                        Text(isSaving ? "Saving..." : "Save Payment Link")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.body)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(isSaving ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                }
                                .disabled(isSaving || paymentLink.isEmpty)
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // MARK: - Getting Started
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Getting Started")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                GettingStartedRow(number: "1", text: "Create a payment link from your payment provider")
                                GettingStartedRow(number: "2", text: "Paste the link above and save")
                                GettingStartedRow(number: "3", text: "Wait for approval, then start accepting payments")
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    isLinkFocused = false
                }
                .onAppear {
                    loadFromCache()
                    updateInBackground()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Success", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your payment link has been saved successfully.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .overlay(
            Group {
                if isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.3)
                                    .tint(.blue)
                                Text("Saving...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
        )
    }
    
    // MARK: - Load from Cache
    private func loadFromCache() {
        guard !cachedPaymentLinksData.isEmpty else { return }
        do {
            let decoded = try JSONDecoder().decode([PaymentLink].self, from: cachedPaymentLinksData)
            paymentLinks = decoded
        } catch {
            print("Failed to load cache: \(error)")
        }
    }
    
    // MARK: - Update in Background
    private func updateInBackground() {
        guard let userId = authManager.userId else { return }
        
        Task {
            do {
                let supabase = SupabaseClient(
                    supabaseURL: Config.supabaseURL,
                    supabaseKey: Config.supabaseAnonKey
                )
                
                let response = try await supabase
                    .from("maps_payment_links")
                    .select("*")
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .execute()
                
                let decoder = JSONDecoder()
                let fetched = try decoder.decode([PaymentLink].self, from: response.data)
                
                // Update cache
                let encoded = try JSONEncoder().encode(fetched)
                cachedPaymentLinksData = encoded
                
                DispatchQueue.main.async {
                    self.paymentLinks = fetched
                }
            } catch {
                print("Background update failed: \(error)")
            }
        }
    }
    
    // MARK: - Save Payment Link
    private func savePaymentLink() {
        guard !paymentLink.isEmpty else { return }
        guard let userId = authManager.userId else {
            errorMessage = "User not signed in"
            showError = true
            return
        }
        
        isSaving = true
        isLinkFocused = false
        
        Task {
            do {
                let supabase = SupabaseClient(
                    supabaseURL: Config.supabaseURL,
                    supabaseKey: Config.supabaseAnonKey
                )
                
                let paymentData = PaymentLinkInsert(
                    userId: userId,
                    provider: selectedProvider.rawValue,
                    paymentLink: paymentLink,
                    status: "pending"
                )
                
                try await supabase
                    .from("maps_payment_links")
                    .insert(paymentData)
                    .execute()
                
                DispatchQueue.main.async {
                    paymentLink = ""
                    isSaving = false
                    showSaveSuccess = true
                    updateInBackground()
                }
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Payment Link Row
struct PaymentLinkRow: View {
    let link: PaymentLink
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 16))
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(link.provider)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(link.paymentLink)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(link.status.capitalized)
                .font(.caption)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    var statusColor: Color {
        switch link.status {
        case "active": return .green
        case "pending": return .orange
        default: return .red
        }
    }
    
    var statusIcon: String {
        switch link.status {
        case "active": return "checkmark.circle.fill"
        case "pending": return "clock.fill"
        default: return "xmark.circle.fill"
        }
    }
}

// MARK: - Getting Started Row
struct GettingStartedRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Text(number)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    TapToPayView()
        .environmentObject(AuthManager())
}
