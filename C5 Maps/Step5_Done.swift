//
//  Step5_Done.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-08.
//

import SwiftUI
import Supabase

// MARK: - Codable Struct for Location Insert
struct LocationInsert: Codable {
    let userId: Int
    let displayName: String
    let primaryCategory: String
    let country: String
    let phoneNumber: String
    let email: String  // ✅ NEW
    let street: String
    let unit: String?
    let city: String
    let state: String
    let zipCode: String
    let status: String
    let website: String?
    let brandWebsite: String?
    let hours: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case primaryCategory = "primary_category"
        case country
        case phoneNumber = "phone_number"
        case email
        case street
        case unit
        case city
        case state
        case zipCode = "zip_code"
        case status
        case website
        case brandWebsite = "brand_website"
        case hours
    }
}

struct Step5_Done: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var showPreview = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    // Actual data from submission
    let locationName: String
    let address: String
    let displayName: String
    let primaryCategory: String
    let city: String
    let state: String
    let country: String
    let phoneNumber: String
    let email: String  // ✅ NEW
    let street: String
    let unit: String
    let zipCode: String
    let website: String
    let brandWebsite: String
    let hours: [(String, String)]
    let onDismiss: () -> Void
    
    init(
        locationName: String,
        address: String,
        displayName: String,
        primaryCategory: String,
        city: String,
        state: String,
        country: String,
        phoneNumber: String,
        email: String,  // ✅ NEW
        street: String,
        unit: String,
        zipCode: String,
        website: String,
        brandWebsite: String,
        hours: [(String, String)],
        onDismiss: @escaping () -> Void
    ) {
        self.locationName = locationName
        self.address = address
        self.displayName = displayName
        self.primaryCategory = primaryCategory
        self.city = city
        self.state = state
        self.country = country
        self.phoneNumber = phoneNumber
        self.email = email
        self.street = street
        self.unit = unit
        self.zipCode = zipCode
        self.website = website
        self.brandWebsite = brandWebsite
        self.hours = hours
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Header with Icon
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Confirm Your Location")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Review your details before submitting")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    // Scrollable Content with ScrollBar
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 16) {
                            // Location Details
                            VStack(alignment: .leading, spacing: 12) {
                                // Address
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                // Display Name
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "building.2.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text(locationName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                // Email - ✅ NEW
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Website
                                if !website.isEmpty {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "globe")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        
                                        Text(website)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Info Notice
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Info")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                Text("Please review all details carefully before submitting.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(maxHeight: geometry.size.height * 0.55)
                    .scrollIndicators(.visible)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        // Preview Button
                        Button(action: {
                            showPreview = true
                        }) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .font(.body)
                                Text("Preview Location")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        
                        // Submit Button
                        Button(action: {
                            saveLocationToDatabase()
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSaving ? "Saving..." : "Submit Your Location")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isSaving ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isSaving)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(.systemGray6))
                .navigationBarHidden(true)
                .sheet(isPresented: $showPreview) {
                    PreviewView(
                        displayName: displayName,
                        primaryCategory: primaryCategory,
                        city: city,
                        state: state
                    )
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .alert("Success", isPresented: $showSuccess) {
                    Button("OK", role: .cancel) {
                        onDismiss()
                    }
                } message: {
                    Text("Location submitted successfully! Track its status in your Branding profile under the menu.")
                }
                
                // Overlay for saving
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
        }
    }
    
    // MARK: - Save to Database
    private func saveLocationToDatabase() {
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
                
                // Convert hours array to dictionary
                var hoursDict: [String: String] = [:]
                for (day, time) in hours {
                    hoursDict[day] = time
                }
                
                let locationData = LocationInsert(
                    userId: userId,
                    displayName: displayName,
                    primaryCategory: primaryCategory,
                    country: country,
                    phoneNumber: phoneNumber,
                    email: email,  // ✅ NEW
                    street: street,
                    unit: unit.isEmpty ? nil : unit,
                    city: city,
                    state: state,
                    zipCode: zipCode,
                    status: "pending",
                    website: website.isEmpty ? nil : website,
                    brandWebsite: brandWebsite.isEmpty ? nil : brandWebsite,
                    hours: hoursDict.isEmpty ? nil : hoursDict
                )
                
                try await supabase
                    .from("maps_locations")
                    .insert(locationData)
                    .execute()
                
                DispatchQueue.main.async {
                    isSaving = false
                    showSuccess = true
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

// MARK: - Preview
#Preview {
    Step5_Done(
        locationName: "Sample Business",
        address: "123 Main St, Edmonton, AB T6X 0E9, Canada",
        displayName: "Sample Business",
        primaryCategory: "Coffee Shop",
        city: "Edmonton",
        state: "Alberta",
        country: "Canada",
        phoneNumber: "+1 306-526-0047",
        email: "business@example.com",  // ✅ NEW
        street: "123 Main St",
        unit: "Suite 100",
        zipCode: "T6X 0E9",
        website: "https://example.com",
        brandWebsite: "https://brand.com",
        hours: [
            ("Mon – Fri", "9:00 AM – 5:00 PM"),
            ("Sat – Sun", "Closed")
        ],
        onDismiss: { print("Dismissed") }
    )
    .environmentObject(AuthManager())
}
