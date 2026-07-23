import SwiftUI
import StoreKit
import Supabase

// MARK: - Location Brand Model
struct LocationBrand: Identifiable, Codable {
    let id: Int
    let displayName: String
    let primaryCategory: String
    let status: String
    let userId: Int
    let website: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case primaryCategory = "primary_category"
        case status
        case userId = "user_id"
        case website
    }
}

// MARK: - Update Location Model
struct LocationUpdate: Codable {
    let displayName: String
    let primaryCategory: String
    let website: String?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case primaryCategory = "primary_category"
        case website
    }
}

struct BrandingListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    // Local cache
    @AppStorage("cachedBrands") private var cachedBrandsData: Data = Data()
    @State private var locations: [LocationBrand] = []
    @State private var selectedLocation: LocationBrand?
    @State private var showingEditSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Background update flag
    @State private var isBackgroundUpdating = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.purple)
                            
                            Text("Branding Profiles")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Manage your brand identity across Apple services")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 20)
                    }
                    
                    // MARK: - Locations List Section
                    if locations.isEmpty {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Brand Profiles")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Add your first location to create a brand profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Brands")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                ForEach(locations) { location in
                                    BrandRow(
                                        location: location,
                                        onEdit: {
                                            selectedLocation = location
                                            showingEditSheet = true
                                        }
                                    )
                                    
                                    if location.id != locations.last?.id {
                                        Divider()
                                            .padding(.leading, 68)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load from cache instantly
            loadFromCache()
            
            // Update in background silently
            updateInBackground()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let location = selectedLocation {
                EditBrandView(location: location, onUpdate: {
                    updateInBackground()
                })
                .environmentObject(authManager)
            }
        }
    }
    
    // MARK: - Load from Cache
    private func loadFromCache() {
        guard !cachedBrandsData.isEmpty else { return }
        
        do {
            let decoded = try JSONDecoder().decode([LocationBrand].self, from: cachedBrandsData)
            locations = decoded
        } catch {
            print("Failed to load cache: \(error)")
        }
    }
    
    // MARK: - Update in Background (No Loading UI)
    private func updateInBackground() {
        guard let userId = authManager.userId else {
            print("User not signed in — skipping update")
            return
        }
        
        Task {
            do {
                let supabase = SupabaseClient(
                    supabaseURL: Config.supabaseURL,
                    supabaseKey: Config.supabaseAnonKey
                )
                
                let response = try await supabase
                    .from("maps_locations")
                    .select("id, display_name, primary_category, status, user_id, website")
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .execute()
                
                let decoder = JSONDecoder()
                let fetchedLocations = try decoder.decode([LocationBrand].self, from: response.data)
                
                // Update cache
                let encoded = try JSONEncoder().encode(fetchedLocations)
                cachedBrandsData = encoded
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.locations = fetchedLocations
                }
                
            } catch {
                print("Background update failed: \(error)")
                // Don't show error — user has cache
            }
        }
    }
}

// MARK: - Brand Row
struct BrandRow: View {
    let location: LocationBrand
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 16) {
                // Brand Icon/Logo
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text(String(location.displayName.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(location.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(location.primaryCategory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge - Added "Rejected"
                if location.status == "active" {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else if location.status == "pending" {
                    Label("Pending", systemImage: "clock.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                } else if location.status == "rejected" {
                    Label("Rejected", systemImage: "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                } else {
                    Label("Inactive", systemImage: "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
    
    var statusColor: Color {
        switch location.status {
        case "active": return .green
        case "pending": return .orange
        case "rejected": return .red
        default: return .red
        }
    }
}

// MARK: - Edit Brand View
struct EditBrandView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    let location: LocationBrand
    let onUpdate: () -> Void
    
    @State private var displayName: String
    @State private var primaryCategory: String
    @State private var website: String
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    init(location: LocationBrand, onUpdate: @escaping () -> Void) {
        self.location = location
        self.onUpdate = onUpdate
        _displayName = State(initialValue: location.displayName)
        _primaryCategory = State(initialValue: location.primaryCategory)
        _website = State(initialValue: location.website ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Brand Details") {
                    TextField("Brand Name", text: $displayName)
                    TextField("Category", text: $primaryCategory)
                    TextField("Website (Optional)", text: $website)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    // Status Display (non-editable) - Added "Rejected"
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(location.status.capitalized)
                            .foregroundColor(statusColor)
                    }
                }
            }
            .navigationTitle("Edit Brand")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateLocation()
                    }
                    .disabled(displayName.isEmpty || primaryCategory.isEmpty || isSaving)
                }
            }
            .overlay(
                Group {
                    if isSaving {
                        ZStack {
                            Color.black.opacity(0.2)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(0.9)
                                    .tint(.blue)
                                
                                Text("Saving...")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8)
                            )
                        }
                    }
                }
            )
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                    onUpdate()
                }
            } message: {
                Text("Brand updated successfully!")
            }
        }
    }
    
    var statusColor: Color {
        switch location.status {
        case "active": return .green
        case "pending": return .orange
        case "rejected": return .red
        default: return .red
        }
    }
    
    private func updateLocation() {
        guard let userId = authManager.userId else {
            errorMessage = "User not signed in"
            showError = true
            return
        }
        
        isSaving = true
        
        Task {
            do {
                let supabase = SupabaseClient(
                    supabaseURL: Config.supabaseURL,
                    supabaseKey: Config.supabaseAnonKey
                )
                
                let updates = LocationUpdate(
                    displayName: displayName,
                    primaryCategory: primaryCategory,
                    website: website.isEmpty ? nil : website
                )
                
                try await supabase
                    .from("maps_locations")
                    .update(updates)
                    .eq("id", value: location.id)
                    .execute()
                
                DispatchQueue.main.async {
                    isSaving = false
                    showSuccess = true
                    // Update cache via callback
                    onUpdate()
                }
                
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = "Failed to update: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    BrandingListView()
        .environmentObject(AuthManager())
}
