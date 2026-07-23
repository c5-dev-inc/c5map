//
//  Step4_Brand.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-08.
//

import SwiftUI

struct Step4_Brand: View {
    var backAction: () -> Void
    var submitAction: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var brandWebsite = ""
    
    // Actual data from previous steps
    let displayName: String
    let primaryCategory: String
    let country: String
    let phoneNumber: String
    let street: String
    let city: String
    let state: String
    let hours: [(String, String)]
    let website: String
    
    // UserDefaults keys
    private let defaults = UserDefaults.standard
    private let brandWebsiteKey = "brand_website"
    
    init(backAction: @escaping () -> Void, submitAction: @escaping () -> Void, displayName: String, primaryCategory: String, country: String, phoneNumber: String, street: String, city: String, state: String, hours: [(String, String)], website: String) {
        self.backAction = backAction
        self.submitAction = submitAction
        self.displayName = displayName
        self.primaryCategory = primaryCategory
        self.country = country
        self.phoneNumber = phoneNumber
        self.street = street
        self.city = city
        self.state = state
        self.hours = hours
        self.website = website
        
        // Load saved website
        let defaults = UserDefaults.standard
        _brandWebsite = State(initialValue: defaults.string(forKey: brandWebsiteKey) ?? "")
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // MARK: - Header with Icon
                VStack(spacing: 12) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Review your brand details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your brand organizes a group of locations. This information is saved on the Brands page.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .background(Color(.systemGray6))
                
                // MARK: - Scrollable Content with ScrollBar (Mac + iOS)
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        BrandDetailRow(label: "Brand Name", value: displayName)
                        Divider()
                        BrandDetailRow(label: "Location Name", value: displayName)
                        Divider()
                        BrandDetailRow(label: "Country/Region", value: country)
                        Divider()
                        BrandDetailRow(label: "Primary Category", value: primaryCategory)
                        Divider()
                        BrandDetailRow(label: "Phone", value: phoneNumber)
                        Divider()
                        BrandDetailRow(label: "Location Website", value: website)  // ✅ ADDED
                        Divider()
                        BrandDetailRow(label: "Address", value: "\(street), \(city), \(state)")
                        
                        if !hours.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Hours")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ForEach(hours, id: \.0) { day, time in
                                    HStack {
                                        Text(day)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(time)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Brand Website (editable)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Brand Website (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter website URL", text: $brandWebsite)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                                .onChange(of: brandWebsite) { _, newValue in
                                    defaults.set(newValue, forKey: brandWebsiteKey)
                                }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxHeight: geometry.size.height * 0.6)
                .scrollIndicators(.visible)
                .background(Color(.systemGray6))
                
                Spacer()
                
                // MARK: - Navigation Buttons
                HStack {
                    Button(action: backAction) {
                        Text("Back")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(14)
                    }
                    
                    Button(action: submitAction) {
                        Text("Done")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Step Indicator
                Text("Step 4 of 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 12)
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Brand Detail Row
struct BrandDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 130, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview
#Preview {
    Step4_Brand(
        backAction: {},
        submitAction: {},
        displayName: "Sample Business",
        primaryCategory: "Software Development Service",
        country: "Canada",
        phoneNumber: "+1 306-526-0047",
        street: "5 Ave SW",
        city: "Edmonton",
        state: "Alberta",
        hours: [
            ("Mon – Fri", "9:00 AM – 5:00 PM"),
            ("Sat – Sun", "Closed")
        ],
        website: "https://example.com"
    )
}
