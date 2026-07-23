import SwiftUI
import AuthenticationServices
import CryptoKit
import Combine

class AuthManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasSubscription = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userEmail: String = ""
    @Published var userName: String = ""
    @Published var userId: Int?
    @Published var supabaseUserId: String?  // ✅ UUID for Stripe
    
    private var currentNonce: String?
    
    override init() {
        super.init()
        checkExistingUser()
    }
    
    private func checkExistingUser() {
        // Check if user has subscription from UserDefaults
        hasSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        userId = UserDefaults.standard.integer(forKey: "userId")
        supabaseUserId = UserDefaults.standard.string(forKey: "supabaseUserId")
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        
        // Check for existing Apple ID credential
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let userID = UserDefaults.standard.string(forKey: "appleUserID") ?? ""
        
        if !userID.isEmpty {
            appleIDProvider.getCredentialState(forUserID: userID) { state, error in
                DispatchQueue.main.async {
                    if state == .authorized {
                        self.isAuthenticated = true
                        UserDefaults.standard.set(true, forKey: "isAuthenticated")
                    } else {
                        self.isAuthenticated = false
                        UserDefaults.standard.set(false, forKey: "isAuthenticated")
                    }
                }
            }
        }
    }
    
    func startSignInWithApple() {
        isLoading = true
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - API Sign In
    func signInWithAPI(appleUserId: String, email: String, name: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://c5-dev.com/api/map/auth/apple") else {
            completion(false, "Invalid API URL")
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
            completion(false, "Failed to encode request")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    completion(false, "No data received from server")
                    return
                }
                
                // ✅ Print the raw response to debug
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📱 RAW API RESPONSE:", jsonString)
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool,
                       success == true,
                       let userData = json["data"] as? [String: Any] {
                        
                        print("📱 userData keys:", userData.keys)
                        
                        // Store user data - Integer ID
                        if let userId = userData["id"] as? Int {
                            self?.userId = userId
                            UserDefaults.standard.set(userId, forKey: "userId")
                            print("✅ Saved userId:", userId)
                        }
                        
                        // Store Supabase UUID - API returns "supabase_user_id"
                        if let supabaseUserId = userData["supabase_user_id"] as? String {
                            self?.supabaseUserId = supabaseUserId
                            UserDefaults.standard.set(supabaseUserId, forKey: "supabaseUserId")
                            print("✅ Saved supabaseUserId:", supabaseUserId)
                        } else {
                            print("❌ supabase_user_id NOT found in response")
                        }
                        
                        if let email = userData["email"] as? String {
                            self?.userEmail = email
                            UserDefaults.standard.set(email, forKey: "userEmail")
                            print("✅ Saved email:", email)
                        }
                        
                        if let name = userData["name"] as? String {
                            self?.userName = name
                            UserDefaults.standard.set(name, forKey: "userName")
                            print("✅ Saved name:", name)
                        }
                        
                        if let hasSubscription = userData["hasSubscription"] as? Bool {
                            self?.hasSubscription = hasSubscription
                            UserDefaults.standard.set(hasSubscription, forKey: "hasActiveSubscription")
                            print("✅ Saved hasSubscription:", hasSubscription)
                        }
                        
                        // Set authenticated
                        self?.isAuthenticated = true
                        UserDefaults.standard.set(true, forKey: "isAuthenticated")
                        print("✅ User authenticated")
                        
                        completion(true, nil)
                        
                    } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let error = json["error"] as? String {
                        completion(false, "Server error: \(error)")
                    } else {
                        completion(false, "Unexpected server response")
                    }
                } catch {
                    completion(false, "Failed to parse response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func setAuthenticated(_ authenticated: Bool) {
        isAuthenticated = authenticated
        UserDefaults.standard.set(authenticated, forKey: "isAuthenticated")
    }
    
    func setSubscriptionActive(_ active: Bool) {
        hasSubscription = active
        UserDefaults.standard.set(active, forKey: "hasActiveSubscription")
        if active {
            setAuthenticated(true)
        }
    }
    
    func signOut() {
        isAuthenticated = false
        hasSubscription = false
        userEmail = ""
        userName = ""
        userId = nil
        supabaseUserId = nil
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasActiveSubscription")
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "supabaseUserId")
        print("✅ User signed out")
    }
    
    func reset() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        isAuthenticated = false
        hasSubscription = false
        userEmail = ""
        userName = ""
        userId = nil
        supabaseUserId = nil
        print("✅ App reset")
    }
    
    // MARK: - Helper Methods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isLoading = false
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                errorMessage = "Invalid state: A login callback was received, but no login request was sent."
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                errorMessage = "Unable to fetch identity token"
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errorMessage = "Unable to serialize token string from data"
                return
            }
            
            // Store user ID
            let userID = appleIDCredential.user
            UserDefaults.standard.set(userID, forKey: "appleUserID")
            
            // Get user info
            let email = appleIDCredential.email ?? ""
            let name = appleIDCredential.fullName?.givenName ?? ""
            
            // Send to API
            signInWithAPI(appleUserId: userID, email: email, name: name) { [weak self] success, error in
                if success {
                    // API sign-in successful - AuthManager already updated
                    self?.isLoading = false
                } else {
                    self?.isLoading = false
                    self?.errorMessage = error ?? "Failed to sign in"
                    self?.isAuthenticated = false
                    UserDefaults.standard.set(false, forKey: "isAuthenticated")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
