import SwiftUI
import AuthenticationServices
import WebKit

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    var onSignIn: () -> Void
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // MARK: - WebView State
    @State private var showPrivacy = false
    @State private var showTerms = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(.systemGray6),
                    Color(.systemGray5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    // Logo Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 140, height: 140)
                                .blur(radius: 20)
                            
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 110, height: 110)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "map.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }
                        
                        Text("C5 Maps")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Apple Maps advertising made simple")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 20)
                    
                    // Feature Cards
                    VStack(spacing: 12) {
                        FeatureRow(
                            icon: "building.2.fill",
                            title: "Add your Business location on Apple Maps",
                            color: .blue
                        )
                        
                        FeatureRow(
                            icon: "iphone.and.arrow.forward",
                            title: "Tap to Pay",
                            color: .orange
                        )
                        
                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "AI-Powered to help your business needs",
                            color: .purple
                        )
                        
                        FeatureRow(
                            icon: "paintbrush.fill",
                            title: "Add your brand",
                            color: .teal
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 20)
                    
                    // Sign In Button
                    VStack(spacing: 12) {
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authorization):
                                    handleAppleSignIn(authorization: authorization)
                                case .failure(let error):
                                    isLoading = false
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        )
                        .frame(height: 56)
                        .cornerRadius(16)
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.6 : 1.0)
                        
                        // Terms & Privacy Links
                        HStack(spacing: 8) {
                            Button(action: {
                                showTerms = true
                            }) {
                                Text("Terms of Service")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showPrivacy = true
                            }) {
                                Text("Privacy Policy")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("By continuing, you agree to our Terms\nand Privacy Policy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    Spacer(minLength: 0)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, 0)
            }
        }
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.3)
                                    .tint(.blue)
                                    .colorScheme(.dark)
                                Text("Connecting to Apple...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                        )
                }
            }
        )
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showPrivacy) {
            WebView(url: URL(string: "https://c5-dev.com/maps/privacy")!)
        }
        .sheet(isPresented: $showTerms) {
            WebView(url: URL(string: "https://c5-dev.com/maps/terms")!)
        }
    }
    
    // MARK: - Handle Apple Sign In
    private func handleAppleSignIn(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            isLoading = false
            errorMessage = "Invalid credential"
            showError = true
            return
        }
        
        isLoading = true
        
        // Get user info from Apple
        let appleUserId = appleIDCredential.user
        let email = appleIDCredential.email ?? ""
        let name = appleIDCredential.fullName?.givenName ?? ""
        
        // Store appleUserId locally
        UserDefaults.standard.set(appleUserId, forKey: "appleUserID")
        
        // Send to your API
        signInWithAPI(appleUserId: appleUserId, email: email, name: name)
    }
    
    private func signInWithAPI(appleUserId: String, email: String, name: String) {
        guard let url = URL(string: "https://c5-dev.com/api/map/auth/apple") else {
            isLoading = false
            errorMessage = "Invalid API URL"
            showError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "appleUserId": appleUserId,
            "email": email,
            "name": name
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request"
            showError = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showError = true
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received from server"
                    showError = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool,
                       success == true,
                       let userData = json["data"] as? [String: Any] {
                        
                        // Store user data — NO SUBSCRIPTION CHECK
                        if let userId = userData["id"] as? Int {
                            UserDefaults.standard.set(userId, forKey: "userId")
                            authManager.userId = userId
                        }
                        if let email = userData["email"] as? String {
                            UserDefaults.standard.set(email, forKey: "userEmail")
                            authManager.userEmail = email
                        }
                        if let name = userData["name"] as? String {
                            UserDefaults.standard.set(name, forKey: "userName")
                            authManager.userName = name
                        }
                        
                        // ✅ Set authenticated — NO SUBSCRIPTION CHECK
                        authManager.isAuthenticated = true
                        UserDefaults.standard.set(true, forKey: "isAuthenticated")
                        
                        // ✅ Call onSignIn — goes straight to app
                        onSignIn()
                        
                    } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let error = json["error"] as? String {
                        errorMessage = "Server error: \(error)"
                        showError = true
                    } else {
                        errorMessage = "Unexpected server response"
                        showError = true
                    }
                } catch {
                    errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    showError = true
                }
            }
        }.resume()
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.6))
        .cornerRadius(14)
    }
}

#Preview {
    SignInView(onSignIn: {})
        .environmentObject(AuthManager())
}
