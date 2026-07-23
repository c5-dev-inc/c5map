//
//  AddPhoto.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-08.
//

import SwiftUI
import PhotosUI

struct AddPhoto: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showingPhotoPicker = false
    @State private var isMenuOpen = false
    
    let businessName = "Jeni's Splendid Ice Cream"
    let category = "Ice Cream"
    let location = "Atlanta"
    let rating = "312 ratings"
    let score = "98%"
    let distance = "1.2 mi"
    let hours = "12 min"
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Apple Business Header
                    HStack {
                        Text("Apple Business")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("Home")
                        Text("People")
                        Text("Brands")
                        Text("Ads")
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // MARK: - Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Show off your best features.")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Add photos that show customers what's special about your business.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // MARK: - Add Photos Button
                    Button(action: {
                        showingPhotoPicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.body)
                            Text("Add Photos")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.body)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // MARK: - iPhone Preview Card
                    VStack(spacing: 0) {
                        // iPhone Frame
                        VStack(spacing: 0) {
                            // Status Bar
                            HStack {
                                Text("9:41")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: "wifi")
                                Image(systemName: "battery.100")
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            
                            // Map Pin
                            VStack(spacing: 0) {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.red)
                                    Text(businessName)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "building.2.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(category) · \(location)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            }
                            .background(Color(.systemGray6))
                            
                            // Hours
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text(hours)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("· Hours Open")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            
                            // Action Buttons
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Text("Call")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {}) {
                                    Text("\(rating) · \(score)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "globe")
                                        .font(.subheadline)
                                        .frame(width: 40)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            
                            // Footer
                            HStack {
                                Text("Accepts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(distance)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Order")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        
                        // "jenis" label (matches the screenshot)
                        Text("jenis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    
                    Spacer(minLength: 40)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedItems, matching: .images)
        .onChange(of: selectedItems) { _, newItems in
            for item in newItems {
                item.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        if let data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                selectedImages.append(image)
                            }
                        }
                    case .failure(let error):
                        print("Error loading image: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddPhoto()
}
