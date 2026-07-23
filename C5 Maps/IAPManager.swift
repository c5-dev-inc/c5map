//
//  IAPManager.swift
//  ShiftSay
//

import StoreKit
import Combine

@MainActor
class IAPManager: ObservableObject {
    static let shared = IAPManager()
    
    @Published var products: [StoreKit.Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let productIDs = [
        "com.c5maps.launch",
        "com.c5maps.growth.monthly",
        "com.c5maps.growth.yearly",
        "com.c5maps.scale.monthly",
        "com.c5maps.scale.yearly"
    ]
    
    private init() {
        print("📱 IAPManager initialized")
        print("📦 Product IDs to fetch: \(productIDs)")
        checkStoreKitFile()
        debugReadStoreKitFile()
        
        Task {
            await fetchProducts()
            await updatePurchasedStatus()
        }
    }
    
    // MARK: - Diagnostics
    
    private func checkStoreKitFile() {
        #if DEBUG
        print("🔍 Checking for StoreKit configuration file...")
        
        // Check if StoreKit configuration is in bundle
        let possibleNames = ["StoreKitConfig", "ShiftSay", "Products", "StoreKit", "IAP"]
        var found = false
        
        for name in possibleNames {
            if let path = Bundle.main.path(forResource: name, ofType: "storekit") {
                print("✅ StoreKit file found: \(path)")
                found = true
                break
            }
        }
        
        if !found {
            print("❌ No .storekit file found in bundle!")
            print("   Check that the file is added to your target")
        }
        
        // Check environment
        #if targetEnvironment(simulator)
        print("⚠️ Running in SIMULATOR - StoreKit may behave differently")
        #else
        print("✅ Running on DEVICE")
        #endif
        
        // Check if StoreKit is available (iOS 15+)
        if #available(iOS 15.0, *) {
            print("✅ StoreKit 2 available")
        } else {
            print("⚠️ StoreKit 2 not available (iOS < 15.0)")
        }
        #endif
    }
    
    // Add this to IAPManager
    func debugReadStoreKitFile() {
        print("📖 Reading StoreKit file directly...")
        
        guard let path = Bundle.main.path(forResource: "ShiftSay", ofType: "storekit") else {
            print("❌ File not found")
            return
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            print("📄 File contents:")
            print(content)
            
            // Try to parse as JSON to validate
            if let data = content.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ JSON is valid: \(json)")
                    
                    // Check products array
                    if let dict = json as? [String: Any],
                       let products = dict["products"] as? [[String: Any]] {
                        print("📦 Found \(products.count) products in file")
                        for (index, product) in products.enumerated() {
                            print("   Product \(index + 1): \(product["productId"] ?? "unknown")")
                        }
                    } else {
                        print("❌ JSON structure invalid - expected { \"products\": [...] }")
                    }
                } catch {
                    print("❌ JSON parse error: \(error)")
                }
            }
        } catch {
            print("❌ Failed to read file: \(error)")
        }
    }
    
    // MARK: - Fetch Products
    
    func fetchProducts() async {
        await MainActor.run {
            isLoading = true
            print("🔄 Starting product fetch...")
        }
        
        do {
            print("🔍 Fetching products with IDs: \(productIDs)")
            let startTime = Date()
            
            // Try to load products with explicit configuration
            #if DEBUG
            // Attempt to use StoreKit configuration file directly
            let configURL = Bundle.main.url(forResource: "StoreKitConfig", withExtension: "storekit")
            if let configURL = configURL {
                print("📁 Found StoreKit config at: \(configURL)")
                
                // Read the file and extract product IDs to verify
                let content = try String(contentsOf: configURL, encoding: .utf8)
                if let data = content.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let productsArray = json["products"] as? [[String: Any]] {
                    
                    let productIds = productsArray.compactMap { $0["productId"] as? String }
                    print("📋 Product IDs in config: \(productIds)")
                    
                    // Check if our requested IDs match
                    let missingIds = productIDs.filter { !productIds.contains($0) }
                    if !missingIds.isEmpty {
                        print("⚠️ Missing product IDs in config: \(missingIds)")
                    }
                }
            } else {
                print("⚠️ StoreKitConfig.storekit not found in bundle")
            }
            #endif
            
            let products = try await StoreKit.Product.products(for: productIDs)
            
            let elapsed = Date().timeIntervalSince(startTime)
            print("⏱️ Fetch completed in \(String(format: "%.2f", elapsed)) seconds")
            print("✅ Products found: \(products.map { $0.id })")
            print("📊 Total products returned: \(products.count)")
            
            await MainActor.run {
                self.products = products
                self.isLoading = false
                
                if products.isEmpty {
                    print("⚠️ CRITICAL: No products returned!")
                    print("   Possible causes:")
                    print("   1. StoreKit configuration not selected in scheme")
                    print("   2. Product IDs don't match the .storekit file")
                    print("   3. .storekit file not added to target")
                    print("   4. Need to clean build and restart")
                    
                    self.errorMessage = "No products found. Check StoreKit configuration."
                } else {
                    // Log each product
                    print("📦 PRODUCT DETAILS:")
                    for product in products {
                        print("   ----------------------------------------")
                        print("   ID: \(product.id)")
                        print("   Name: \(product.displayName)")
                        print("   Description: \(product.description)")
                        print("   Price: \(product.price)")
                        print("   Type: \(product.type)")
                        #if os(iOS)
                        if let subscription = product.subscription {
                            print("   Subscription: Yes")
                            print("   Duration: \(subscription.subscriptionPeriod.value) \(subscription.subscriptionPeriod.unit)")
                        } else {
                            print("   Subscription: No")
                        }
                        #endif
                        print("   ----------------------------------------")
                    }
                    
                    self.errorMessage = nil
                }
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            print("   Error type: \(type(of: error))")
            print("   Localized: \(error.localizedDescription)")
            
            // Log more details about the error
            if let storeKitError = error as? StoreKitError {
                print("   StoreKitError: \(storeKitError)")
            }
            
            await MainActor.run {
                self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Purchase
    
    func purchase(productID: String) async -> Bool {
        print("🛒 Attempting to purchase: \(productID)")
        
        await MainActor.run {
            isPurchasing = true
            print("💰 Purchase started for: \(productID)")
        }
        
        // If no products, try to fetch first
        if products.isEmpty {
            print("⚠️ Products array is empty, attempting to fetch...")
            await fetchProducts()
            
            if products.isEmpty {
                print("❌ Still no products after fetch attempt")
                await MainActor.run {
                    errorMessage = "No products available. Please try again."
                    isPurchasing = false
                }
                return false
            }
        }
        
        // Find the product
        guard let product = products.first(where: { $0.id == productID }) else {
            print("❌ Product not found: \(productID)")
            print("   Available products: \(products.map { $0.id })")
            await MainActor.run {
                errorMessage = "Product '\(productID)' not found"
                isPurchasing = false
            }
            return false
        }
        
        print("✅ Found product: \(product.displayName) for \(product.price)")
        print("💰 Starting purchase flow...")
        
        do {
            let result = try await product.purchase()
            print("📱 Purchase result received")
            
            switch result {
            case .success(let verification):
                print("✅ Purchase success, verifying transaction...")
                
                switch verification {
                case .verified(let transaction):
                    print("✅ Transaction verified: \(transaction.id)")
                    print("   Product: \(transaction.productID)")
                    print("   Purchase date: \(transaction.purchaseDate)")
                    
                    await transaction.finish()
                    print("✅ Transaction finished")
                    
                    await updatePurchasedStatus()
                    print("✅ Purchased status updated")
                    
                    await MainActor.run {
                        isPurchasing = false
                    }
                    return true
                    
                case .unverified:
                    print("❌ Transaction verification failed")
                    await MainActor.run {
                        isPurchasing = false
                        errorMessage = "Transaction verification failed"
                    }
                    return false
                }
                
            case .userCancelled:
                print("❌ User cancelled purchase")
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = "Purchase cancelled"
                }
                return false
                
            case .pending:
                print("⏳ Purchase pending (awaiting approval)")
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = "Purchase pending"
                }
                return false
                
            @unknown default:
                print("⚠️ Unknown purchase result")
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = "Unknown error"
                }
                return false
            }
        } catch {
            print("❌ Purchase failed with error: \(error)")
            print("   Error type: \(type(of: error))")
            print("   Localized: \(error.localizedDescription)")
            
            await MainActor.run {
                isPurchasing = false
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() async -> Bool {
        print("🔄 Starting restore purchases...")
        
        do {
            try await AppStore.sync()
            print("✅ AppStore.sync completed")
            
            await updatePurchasedStatus()
            print("✅ Purchased status updated after restore")
            return true
        } catch {
            print("❌ Restore failed: \(error)")
            await MainActor.run {
                errorMessage = "Restore failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Status
    
    func updatePurchasedStatus() async {
        print("🔄 Updating purchased status...")
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIDs.contains(transaction.productID) {
                    purchased.insert(transaction.productID)
                    print("✅ Found entitlement: \(transaction.productID)")
                }
            }
        }
        
        await MainActor.run {
            self.purchasedProductIDs = purchased
            print("📊 Current entitlements: \(purchased)")
        }
        
        let isPaid = !purchased.isEmpty
        UserDefaults.standard.set(isPaid, forKey: "isPaidUser")
        print("💾 Saved isPaidUser: \(isPaid)")
    }
    
    var isPaid: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    func isProductPurchased(productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    // MARK: - Debug
    
    func debugPrintState() {
        print("=== IAPManager State ===")
        print("Products count: \(products.count)")
        print("Product IDs: \(products.map { $0.id })")
        print("Purchased products: \(purchasedProductIDs)")
        print("Is purchasing: \(isPurchasing)")
        print("Is loading: \(isLoading)")
        print("Error: \(errorMessage ?? "None")")
        print("Is paid user: \(isPaid)")
        print("========================")
    }
}
