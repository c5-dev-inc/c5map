// StripeConnectManager.swift
import Foundation
import Combine
import Supabase

// MARK: - Codable Structs for Supabase
struct StripeAccountUpdate: Codable {
    let stripeAccountId: String
    let connected: Bool
    let onboardingComplete: Bool
    let chargesEnabled: Bool
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case stripeAccountId = "stripe_account_id"
        case connected
        case onboardingComplete = "onboarding_complete"
        case chargesEnabled = "charges_enabled"
        case updatedAt = "updated_at"
    }
}

struct StripeAccountInsert: Codable {
    let userId: String
    let stripeAccountId: String
    let connected: Bool
    let onboardingComplete: Bool
    let chargesEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case stripeAccountId = "stripe_account_id"
        case connected
        case onboardingComplete = "onboarding_complete"
        case chargesEnabled = "charges_enabled"
    }
}

class StripeConnectManager: ObservableObject {
    @Published var isConnecting = false
    @Published var onboardingURL: URL?
    @Published var isConnected = false
    @Published var stripeAccountId: String?
    @Published var connectionError: String?
    
    private let supabase: SupabaseClient
    private var userId: String?
    private var userEmail: String?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.supabase = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    func setUserId(_ userId: String) {
        self.userId = userId
        print("User ID set: \(userId)")
    }
    
    func setUserEmail(_ email: String) {
        self.userEmail = email
        print("User email set: \(email)")
    }
    
    func checkConnectionStatus() async {
        guard let userId = userId else {
            print("User ID not set")
            return
        }
        
        print("Checking status for user ID: \(userId)")
        
        do {
            let response = try await supabase
                .from("stripe_accounts")
                .select("connected, stripe_account_id, charges_enabled")
                .eq("user_id", value: userId)
                .execute()
            
            let json = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]]
            print("Response: \(json ?? [])")
            
            if let first = json?.first {
                DispatchQueue.main.async {
                    self.isConnected = (first["connected"] as? Bool) ?? false
                    self.stripeAccountId = first["stripe_account_id"] as? String
                }
            }
        } catch {
            print("Error checking stripe status:", error)
            DispatchQueue.main.async {
                self.connectionError = error.localizedDescription
            }
        }
    }
    
    func startOnboarding() async throws -> URL {
        guard let userId = userId else {
            print("User ID not set")
            throw StripeError.userNotFound
        }
        
        print("Starting onboarding for user ID: \(userId)")
        
        DispatchQueue.main.async {
            self.isConnecting = true
            self.connectionError = nil
        }
        
        do {
            // ✅ REMOVED Supabase Auth - using your own API
            // Just use the userId and email you already have
            
            var request = URLRequest(url: Config.stripeOnboardFunction)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "userId": userId,
                "email": userEmail ?? ""
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("Edge function response: \(json ?? [:])")
            
            guard let urlString = json?["url"] as? String,
                  let url = URL(string: urlString) else {
                let error = json?["error"] as? String ?? "Failed to start onboarding"
                throw StripeError.onboardingFailed(error)
            }
            
            DispatchQueue.main.async {
                self.isConnecting = false
                self.onboardingURL = url
            }
            
            return url
            
        } catch {
            print("Onboarding error:", error)
            DispatchQueue.main.async {
                self.isConnecting = false
                self.connectionError = error.localizedDescription
            }
            throw error
        }
    }
    
    func completeOnboarding(accountId: String) async throws {
        guard let userId = userId else {
            throw StripeError.userNotFound
        }
        
        print("Completing onboarding for user ID: \(userId), account ID: \(accountId)")
        
        let dateFormatter = ISO8601DateFormatter()
        let now = dateFormatter.string(from: Date())
        
        // Check if record exists
        let response = try await supabase
            .from("stripe_accounts")
            .select("id")
            .eq("user_id", value: userId)
            .execute()
        
        let json = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]]
        let exists = json?.first?["id"] != nil
        
        if exists {
            // Update existing - use Codable struct
            let update = StripeAccountUpdate(
                stripeAccountId: accountId,
                connected: true,
                onboardingComplete: true,
                chargesEnabled: true,
                updatedAt: now
            )
            
            try await supabase
                .from("stripe_accounts")
                .update(update)
                .eq("user_id", value: userId)
                .execute()
        } else {
            // Insert new - use Codable struct
            let insert = StripeAccountInsert(
                userId: userId,
                stripeAccountId: accountId,
                connected: true,
                onboardingComplete: true,
                chargesEnabled: true
            )
            
            try await supabase
                .from("stripe_accounts")
                .insert(insert)
                .execute()
        }
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.stripeAccountId = accountId
            self.onboardingURL = nil
        }
    }
}

enum StripeError: LocalizedError {
    case userNotFound
    case onboardingFailed(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found. Please sign in again."
        case .onboardingFailed(let message):
            return "Onboarding failed: \(message)"
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
