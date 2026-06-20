import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var showingUpgradePlan = false
    @State private var isSubscribed = false
    
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
                        
                        Text("C5 Maps User")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("user@example.com")
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
                                Text("Pro Monthly")
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
                            }
                        }
                        
                        HStack {
                            Text("$79/month")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("billed monthly")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                    
                    // Support Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", color: .blue) {
                                openURL("https://c5-dev.com/maps/support")
                            }
                            Divider().padding(.leading, 52)
                            SettingsRow(icon: "envelope.fill", title: "Contact Us", color: .blue) {
                                openURL("mailto:support@c5-dev.com")
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // Legal Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legal")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", color: .secondary) {
                                openURL("https://c5-dev.com/maps/privacy")
                            }
                            Divider().padding(.leading, 52)
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", color: .secondary) {
                                openURL("https://c5-dev.com/maps/terms")
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // App Info Section
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
                                    Text("Rate C5 Maps")
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
                    
                    // Sign Out Button
                    Button(action: signOut) {
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
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingUpgradePlan) {
            UpgradePlanView()
        }
    }
    
    private func openURL(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func signOut() { }
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

#Preview {
    SettingsView()
}
