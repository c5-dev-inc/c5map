import SwiftUI
import StoreKit
import WebKit

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingUpgradePlan = false
    @State private var isSubscribed = false
    @State private var showingWebView = false
    @State private var webViewURL: URL?
    @State private var showingDeleteAccountAlert = false
    @State private var showingSignOutAlert = false
    @State private var isDeleting = false
    @State private var showingAIAssistant = false
    
    // MARK: - WebView State (EXACTLY like LandingView)
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showHelp = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Profile Section
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Text(authManager.userName.isEmpty ? "C5-Maps User" : authManager.userName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(authManager.userEmail.isEmpty ? "user@example.com" : authManager.userEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Subscription Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Plan")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(isSubscribed ? "Pro Monthly" : "Free")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            if isSubscribed {
                                Text("Active")
                                    .font(.caption2)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            } else {
                                Text("Inactive")
                                    .font(.caption2)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.15))
                                    .foregroundColor(.gray)
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack {
                            Text(isSubscribed ? "$79/month" : "Free")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(isSubscribed ? .blue : .secondary)
                            
                            if isSubscribed {
                                Text("billed monthly")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        Button(action: { showingUpgradePlan = true }) {
                            HStack {
                                Text(isSubscribed ? "Manage Subscription" : "Upgrade Plan")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    // MARK: - Support Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", color: .blue) {
                                showHelp = true  // Using same pattern as LandingView
                            }
                            Divider().padding(.leading, 52)
                            SettingsRow(icon: "envelope.fill", title: "Contact Us", color: .blue) {
                                showingAIAssistant = true
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // MARK: - Legal Section (EXACTLY like LandingView)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legal")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", color: .secondary) {
                                showPrivacy = true  // Using same pattern as LandingView
                            }
                            Divider().padding(.leading, 52)
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", color: .secondary) {
                                showTerms = true  // Using same pattern as LandingView
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // MARK: - App Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "iphone.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .frame(width: 32)
                                Text("Version")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider().padding(.leading, 52)
                            
                            Button(action: rateApp) {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                        .frame(width: 32)
                                    Text("Rate C5-Maps")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .foregroundColor(.primary)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // MARK: - Account Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            showingSignOutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        
                        Button(action: {
                            showingDeleteAccountAlert = true
                        }) {
                            HStack {
                                Spacer()
                                if isDeleting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                } else {
                                    Text("Delete Account")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isDeleting)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingUpgradePlan) {
            UpgradePlanView(onComplete: {
                showingUpgradePlan = false
                authManager.setSubscriptionActive(true)
            })
        }
        // MARK: - WebView Sheets (EXACTLY like LandingView)
        .sheet(isPresented: $showHelp) {
            WebView(url: URL(string: "https://c5-dev.com/maps/support")!)
        }
        .sheet(isPresented: $showPrivacy) {
            WebView(url: URL(string: "https://c5-dev.com/maps/privacy")!)
        }
        .sheet(isPresented: $showTerms) {
            WebView(url: URL(string: "https://c5-dev.com/maps/terms")!)
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView()
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
        }
        .onAppear {
            isSubscribed = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
        }
    }
    
    // MARK: - Functions
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func signOut() {
        authManager.signOut()
        NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
    }
    
    private func deleteAccount() {
        isDeleting = true
        
        guard let userId = authManager.userId,
              let url = URL(string: "https://c5-dev.com/api/maps/users/\(userId)") else {
            isDeleting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isDeleting = false
                authManager.signOut()
                NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
            }
        }.resume()
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - WebView (EXACTLY like LandingView)
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
