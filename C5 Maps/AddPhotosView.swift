//
//  AddPhotosView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-09.
//

import SwiftUI
import PhotosUI

struct AddPhotosView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedBrand: String = ""
    @State private var selectedBannerImage: UIImage?
    @State private var selectedAdditionalImages: [UIImage] = []
    @State private var showingBannerPicker = false
    @State private var showingAdditionalPicker = false
    @State private var showingPreview = false
    @State private var isProcessing = false
    
    // PhotosPicker items
    @State private var bannerPickerItem: PhotosPickerItem?
    @State private var additionalPickerItems: [PhotosPickerItem] = []
    
    // Sample brands - replace with your actual data
    let brands = ["La Colombe Coffee Roasters", "Starbucks", "Dunkin'", "Blue Bottle Coffee", "Philz Coffee"]
    
    // Mock data for preview
    @State private var previewDisplayName = "La Colombe Coffee Roasters"
    @State private var previewCategory = "Cafe & Coffee Shop"
    @State private var previewCity = "Fishtown"
    @State private var previewState = "Philadelphia"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "photo.stack.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Add Photos")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Upload photos for your business location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        
                        // Brand Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Brand")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Picker("Select Brand", selection: $selectedBrand) {
                                Text("Choose a brand").tag("")
                                ForEach(brands, id: \.self) { brand in
                                    Text(brand).tag(brand)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: selectedBrand) { _, newValue in
                                if !newValue.isEmpty {
                                    previewDisplayName = newValue
                                }
                            }
                            
                            if selectedBrand.isEmpty {
                                Text("Please select a brand to continue")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if !selectedBrand.isEmpty {
                            // Banner Image
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Banner Image")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("This will appear at the top of your place card")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                PhotosPicker(selection: $bannerPickerItem, matching: .images) {
                                    if let image = selectedBannerImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 160)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(12)
                                            .clipped()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue, lineWidth: 2)
                                            )
                                            .overlay(
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Spacer()
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 24))
                                                            .foregroundColor(.blue)
                                                            .background(Color.white.clipShape(Circle()))
                                                            .padding(8)
                                                    }
                                                }
                                            )
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 160)
                                            .frame(maxWidth: .infinity)
                                            .overlay(
                                                VStack(spacing: 12) {
                                                    Image(systemName: "photo.badge.plus")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.secondary)
                                                    Text("Tap to select banner image")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            )
                                    }
                                }
                                .onChange(of: bannerPickerItem) { _, newValue in
                                    Task {
                                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            await MainActor.run {
                                                selectedBannerImage = image
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Additional Images (2 max)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Additional Photos")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Add up to 2 additional photos for your place card")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    // First additional image
                                    PhotosPicker(selection: $additionalPickerItems, maxSelectionCount: 2, matching: .images) {
                                        if selectedAdditionalImages.indices.contains(0) {
                                            Image(uiImage: selectedAdditionalImages[0])
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 120)
                                                .cornerRadius(12)
                                                .clipped()
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.blue, lineWidth: 2)
                                                )
                                                .overlay(
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            Spacer()
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .font(.system(size: 20))
                                                                .foregroundColor(.blue)
                                                                .background(Color.white.clipShape(Circle()))
                                                                .padding(6)
                                                        }
                                                    }
                                                )
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray5))
                                                .frame(height: 120)
                                                .overlay(
                                                    VStack(spacing: 8) {
                                                        Image(systemName: "plus.circle")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(.secondary)
                                                        Text("Add Photo")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                )
                                        }
                                    }
                                    .onChange(of: additionalPickerItems) { _, newItems in
                                        Task {
                                            var images: [UIImage] = []
                                            for item in newItems.prefix(2) {
                                                if let data = try? await item.loadTransferable(type: Data.self),
                                                   let image = UIImage(data: data) {
                                                    images.append(image)
                                                }
                                            }
                                            await MainActor.run {
                                                selectedAdditionalImages = images
                                            }
                                        }
                                    }
                                    
                                    // Second additional image
                                    PhotosPicker(selection: $additionalPickerItems, maxSelectionCount: 2, matching: .images) {
                                        if selectedAdditionalImages.indices.contains(1) {
                                            Image(uiImage: selectedAdditionalImages[1])
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 120)
                                                .cornerRadius(12)
                                                .clipped()
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.blue, lineWidth: 2)
                                                )
                                                .overlay(
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            Spacer()
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .font(.system(size: 20))
                                                                .foregroundColor(.blue)
                                                                .background(Color.white.clipShape(Circle()))
                                                                .padding(6)
                                                        }
                                                    }
                                                )
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray5))
                                                .frame(height: 120)
                                                .overlay(
                                                    VStack(spacing: 8) {
                                                        Image(systemName: "plus.circle")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(.secondary)
                                                        Text("Add Photo")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                )
                                        }
                                    }
                                    .onChange(of: additionalPickerItems) { _, newItems in
                                        Task {
                                            var images: [UIImage] = []
                                            for item in newItems.prefix(2) {
                                                if let data = try? await item.loadTransferable(type: Data.self),
                                                   let image = UIImage(data: data) {
                                                    images.append(image)
                                                }
                                            }
                                            await MainActor.run {
                                                selectedAdditionalImages = images
                                            }
                                        }
                                    }
                                }
                                
                                if selectedAdditionalImages.count >= 2 {
                                    Text("Maximum 2 additional photos reached")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                // Preview Button
                                Button(action: {
                                    showingPreview = true
                                }) {
                                    HStack {
                                        Image(systemName: "eye.fill")
                                        Text("Preview Place Card")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                                .disabled(selectedBannerImage == nil)
                                .opacity(selectedBannerImage == nil ? 0.5 : 1.0)
                                
                                // Upload Button
                                Button(action: uploadPhotos) {
                                    HStack {
                                        if isProcessing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Image(systemName: "icloud.and.arrow.up.fill")
                                            Text("Upload Photos")
                                        }
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(isProcessing ? Color.gray : Color.green)
                                    .cornerRadius(12)
                                }
                                .disabled(selectedBannerImage == nil || isProcessing)
                                .opacity(selectedBannerImage == nil ? 0.5 : 1.0)
                                
                                // Upload Status
                                if isProcessing {
                                    Text("Uploading photos...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingPreview) {
                PreviewView(
                    displayName: previewDisplayName,
                    primaryCategory: previewCategory,
                    city: previewCity,
                    state: previewState
                )
            }
        }
    }
    
    // MARK: - Functions
    private func uploadPhotos() {
        guard selectedBannerImage != nil else { return }
        
        isProcessing = true
        
        // Simulate upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isProcessing = false
            // Show success or handle upload
            dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    AddPhotosView()
}
