import SwiftUI
import MapKit
import Supabase

// MARK: - My Store Model
struct MyStore: Identifiable, Codable {
    let id: Int
    let userId: Int
    let displayName: String
    let primaryCategory: String
    let description: String?
    let street: String
    let unit: String?
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let phoneNumber: String
    let website: String?
    let brandWebsite: String?
    let hours: String?
    let status: String
    let isVerified: Bool?
    let imageUrl: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case displayName = "display_name"
        case primaryCategory = "primary_category"
        case description
        case street
        case unit
        case city
        case state
        case zipCode = "zip_code"
        case country
        case phoneNumber = "phone_number"
        case website
        case brandWebsite = "brand_website"
        case hours
        case status
        case isVerified = "is_verified"
        case imageUrl = "image_url"
        case latitude
        case longitude
        case createdAt = "created_at"
    }
    
    var fullAddress: String {
        [street, unit, city, state, zipCode, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Update About Struct
struct StoreAboutUpdate: Codable {
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case description
    }
}

struct MyStoreView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var store: MyStore?
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var aboutText = ""
    @State private var isEditingAbout = false
    @State private var isSavingAbout = false
    @State private var showSaveSuccess = false
    @State private var showingAddProducts = false
    @State private var showingAnalytics = false
    @State private var showingMessages = false
    @State private var showingAppleMaps = false
    @State private var supabaseClient: SupabaseClient?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "storefront")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Loading your store...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else if let store = store {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Store Header
                            MyStoreHeaderView(store: store, dismiss: dismiss)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // Store Info with Website
                                MyStoreInfoSection(
                                    store: store,
                                    aboutText: $aboutText,
                                    isEditingAbout: $isEditingAbout,
                                    isSavingAbout: $isSavingAbout,
                                    onSaveAbout: saveAboutText
                                )
                                
                                Divider()
                                
                                // Tab Buttons - each opens existing sheet
                                VStack(spacing: 12) {
                                    // Add Products Tab
                                    Button(action: { showingAddProducts = true }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Products")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    // Analytics Tab
                                    Button(action: { showingAnalytics = true }) {
                                        HStack {
                                            Image(systemName: "chart.bar.fill")
                                            Text("Analytics")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    // Messages Tab
                                    Button(action: { showingMessages = true }) {
                                        HStack {
                                            Image(systemName: "message.fill")
                                            Text("Messages")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding()
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                Divider()
                                
                                // View on Apple Maps
                                VStack(spacing: 8) {
                                    Button(action: { showingAppleMaps = true }) {
                                        HStack {
                                            Image(systemName: "map.fill")
                                            Text("View on Apple Maps")
                                            Spacer()
                                            Image(systemName: "arrow.up.right.circle")
                                        }
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    Text("See reviews, photos, hours, and more on Apple Maps")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                    .background(
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()
                    )
                    .scrollIndicators(.hidden)
                } else {
                    // No Store
                    VStack(spacing: 16) {
                        Image(systemName: "storefront")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Store Found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Add your first location to create your store")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { dismiss() }) {
                            Text("Add Location")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .padding(.horizontal, 32)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                initializeSupabase()
                fetchMyStore()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("About text saved successfully!")
            }
            .sheet(isPresented: $showingAddProducts) {
                AddProductsView()
            }
            .sheet(isPresented: $showingAnalytics) {
                AnalyticsView()
            }
            .sheet(isPresented: $showingMessages) {
                MessagesView()
            }
            .sheet(isPresented: $showingAppleMaps) {
                if let store = store {
                    AppleMapsView(store: Store(
                        name: store.displayName,
                        description: store.description ?? "",
                        category: .food,
                        address: store.fullAddress,
                        website: store.website,
                        imageURL: store.imageUrl,
                        products: [],
                        ratings: [],
                        isVerified: store.isVerified ?? false,
                        distance: 0,
                        ownerID: ""
                    ))
                }
            }
        }
    }
    
    // MARK: - Initialize Supabase
    private func initializeSupabase() {
        supabaseClient = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    // MARK: - Fetch Store
    private func fetchMyStore() {
        guard let userId = authManager.userId else {
            errorMessage = "User not signed in. Please sign in first."
            showError = true
            isLoading = false
            return
        }
        
        guard let supabase = supabaseClient else {
            errorMessage = "Supabase client not initialized"
            showError = true
            isLoading = false
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let response = try await supabase
                    .from("maps_locations")
                    .select("*")
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .execute()
                
                let decoder = JSONDecoder()
                
                do {
                    let locations = try decoder.decode([MyStore].self, from: response.data)
                    DispatchQueue.main.async {
                        if let firstStore = locations.first {
                            self.store = firstStore
                            self.aboutText = firstStore.description ?? ""
                        }
                        self.isLoading = false
                    }
                } catch {
                    do {
                        let location = try decoder.decode(MyStore.self, from: response.data)
                        DispatchQueue.main.async {
                            self.store = location
                            self.aboutText = location.description ?? ""
                            self.isLoading = false
                        }
                    } catch {
                        DispatchQueue.main.async {
                            if response.data.isEmpty {
                                self.errorMessage = "No store found for this user. Please create a store location."
                            } else {
                                self.errorMessage = "Data format error: \(error.localizedDescription)"
                            }
                            self.showError = true
                            self.isLoading = false
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    let errorDescription = error.localizedDescription
                    if errorDescription.contains("relation") && errorDescription.contains("does not exist") {
                        self.errorMessage = "The 'maps_locations' table doesn't exist in your database. Please create it first."
                    } else if errorDescription.contains("permission denied") {
                        self.errorMessage = "Permission denied. Please check your Supabase permissions."
                    } else if errorDescription.contains("column") && errorDescription.contains("does not exist") {
                        self.errorMessage = "Column mismatch. Please check if all columns exist in 'maps_locations' table."
                    } else {
                        self.errorMessage = "Failed to load store: \(errorDescription)"
                    }
                    self.showError = true
                    self.isLoading = false
                    print("Detailed error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Save About Text
    private func saveAboutText() {
        guard let store = store else { return }
        guard let supabase = supabaseClient else {
            errorMessage = "Supabase client not initialized"
            showError = true
            return
        }
        
        isSavingAbout = true
        
        Task {
            do {
                let updates = StoreAboutUpdate(description: aboutText)
                
                try await supabase
                    .from("maps_locations")
                    .update(updates)
                    .eq("id", value: store.id)
                    .execute()
                
                let response = try await supabase
                    .from("maps_locations")
                    .select("*")
                    .eq("id", value: store.id)
                    .single()
                    .execute()
                
                let decoder = JSONDecoder()
                let updatedStore = try decoder.decode(MyStore.self, from: response.data)
                
                DispatchQueue.main.async {
                    self.store = updatedStore
                    self.aboutText = updatedStore.description ?? ""
                    isSavingAbout = false
                    isEditingAbout = false
                    showSaveSuccess = true
                }
                
            } catch {
                DispatchQueue.main.async {
                    isSavingAbout = false
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - My Store Header
struct MyStoreHeaderView: View {
    let store: MyStore
    let dismiss: DismissAction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            if let imageURL = store.imageUrl, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    case .failure:
                        headerGradient
                    @unknown default:
                        headerGradient
                    }
                }
            } else {
                headerGradient
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)
            
            // Store Info Overlay
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(store.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // VERIFIED BADGE - RESTORED
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                
                
                HStack(spacing: 12) {
                    Label(store.primaryCategory, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if store.status == "active" {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("Pending")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text(store.fullAddress)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .frame(height: 250)
    }
    
    var headerGradient: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            
            Image(systemName: "storefront")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

// MARK: - My Store Info Section
struct MyStoreInfoSection: View {
    let store: MyStore
    @Binding var aboutText: String
    @Binding var isEditingAbout: Bool
    @Binding var isSavingAbout: Bool
    let onSaveAbout: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // About Section
            HStack {
                Text("About")
                    .font(.headline)
                
                Spacer()
                
                if !isEditingAbout {
                    Button(action: { isEditingAbout = true }) {
                        Text("Edit")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if isEditingAbout {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Tell customers about your business...", text: $aboutText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            isEditingAbout = false
                            aboutText = store.description ?? ""
                        }) {
                            Text("Cancel")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: onSaveAbout) {
                            if isSavingAbout {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Text("Save")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(isSavingAbout)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
            } else {
                Text(aboutText.isEmpty ? "No description yet. Tap Edit to add one." : aboutText)
                    .font(.body)
                    .foregroundColor(aboutText.isEmpty ? .gray : .secondary)
                    .lineSpacing(4)
            }
            
            // Website
            if let website = store.website, !website.isEmpty {
                Button(action: {
                    if let url = URL(string: website) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Text(website.replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: ""))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                        Image(systemName: "arrow.up.right.circle")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            // Store Stats
            HStack(spacing: 20) {
                StatItem(
                    icon: "phone.fill",
                    color: .green,
                    value: store.phoneNumber,
                    label: "Phone"
                )
                
                StatItem(
                    icon: "envelope.fill",
                    color: .blue,
                    value: "Contact",
                    label: "Email"
                )
                
                StatItem(
                    icon: "mappin.circle.fill",
                    color: .red,
                    value: "Map",
                    label: "Location"
                )
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview {
    MyStoreView()
        .environmentObject(AuthManager())
}
