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
    
    private var currentNonce: String?
    
    override init() {
        super.init()
        checkExistingUser()
    }
    
    private func checkExistingUser() {
        // Check if user has subscription from UserDefaults
        hasSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
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
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasActiveSubscription")
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
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
            userEmail = appleIDCredential.email ?? ""
            userName = appleIDCredential.fullName?.givenName ?? ""
            
            // Store user info
            UserDefaults.standard.set(userEmail, forKey: "userEmail")
            UserDefaults.standard.set(userName, forKey: "userName")
            
            // Authentication successful
            isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            hasSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
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
