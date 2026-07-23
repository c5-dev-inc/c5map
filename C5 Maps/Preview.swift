//
//  PreviewView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-08.
//

import SwiftUI

struct PreviewView: View {
    @Environment(\.dismiss) var dismiss
    
    // Real data from submission
    let displayName: String
    let primaryCategory: String
    let city: String
    let state: String
    
    // Mock data
    private let distance = "0.9mi"
    private let rating = "4.8"
    private let priceLevel = "$$$$"
    private let hours = "Open"
    private let fromBusiness = "New Flavor Alert\nTreat yourself to the\ndecadent sweetness of"
    
    // FREE STOCK IMAGES
    private let heroImageURL = "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&q=80"
    private let gridImage1URL = "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80"
    private let gridImage2URL = "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400&q=80"
    private let fromBusinessImageURL = "https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=400&q=80"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Place Card Preview")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                            
                            // iPhone Device Frame - FULL HEIGHT
                            iPhoneDeviceFrame {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        // Status Bar
                                        HStack {
                                            Text("9:41")
                                                .font(.system(size: 15, weight: .bold))
                                            Spacer()
                                            Text("5G")
                                                .font(.system(size: 13, weight: .medium))
                                            Image(systemName: "wifi")
                                                .font(.system(size: 13))
                                            Image(systemName: "battery.100")
                                                .font(.system(size: 13))
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 10)
                                        .padding(.bottom, 6)
                                        
                                        // Hero Image
                                        AsyncImage(url: URL(string: heroImageURL)) { phase in
                                            switch phase {
                                            case .empty:
                                                Rectangle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(height: 200)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 200)
                                                    .clipped()
                                            case .failure:
                                                Rectangle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(height: 200)
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.secondary)
                                                    )
                                            @unknown default:
                                                Rectangle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(height: 200)
                                            }
                                        }
                                        
                                        // Business Name - ONLY split if 3+ words
                                        VStack(alignment: .leading, spacing: 2) {
                                            let nameParts = displayName.components(separatedBy: " ")
                                            if nameParts.count >= 3 {
                                                let firstLine = nameParts.prefix(2).joined(separator: " ")
                                                let secondLine = nameParts.dropFirst(2).joined(separator: " ")
                                                Text(firstLine)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.primary)
                                                Text(secondLine)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.primary)
                                            } else {
                                                Text(displayName)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            // Category & Address - BLUE city and state
                                            HStack(spacing: 0) {
                                                Text("\(primaryCategory)")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                                Text(" · ")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                                Text(city)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                                Text(", ")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                                Text(state)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.top, 14)
                                        .padding(.bottom, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Action Buttons
                                        HStack(spacing: 10) {
                                            ActionButton(icon: "clock", label: "8 min", color: .green)
                                            ActionButton(icon: "phone", label: "Call", color: .blue)
                                            ActionButton(icon: "globe", label: "Website", color: .blue)
                                            ActionButton(icon: "bag", label: "Order", color: .blue)
                                            ActionButton(icon: "ellipsis", label: "More", color: .secondary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        
                                        Divider()
                                            .padding(.horizontal, 16)
                                        
                                        // HOURS | RATINGS | COST | DISTANCE Row
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("HOURS")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                Text(hours)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(.green)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Divider()
                                                .frame(height: 30)
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("RATINGS")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                HStack(spacing: 2) {
                                                    Text(rating)
                                                        .font(.system(size: 13, weight: .medium))
                                                    Image(systemName: "star.fill")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.yellow)
                                                    Text("Rate")
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Divider()
                                                .frame(height: 30)
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("COST")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                Text(priceLevel)
                                                    .font(.system(size: 13, weight: .medium))
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Divider()
                                                .frame(height: 30)
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("DISTANCE")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                Text(distance)
                                                    .font(.system(size: 13, weight: .medium))
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        
                                        Divider()
                                            .padding(.horizontal, 16)
                                        
                                        // GRID 2 FREE STOCK IMAGES - WITH SPACING
                                        Text("From the Business")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 16)
                                            .padding(.top, 8)
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.flexible(), spacing: 16),
                                            GridItem(.flexible(), spacing: 16)
                                        ], spacing: 16) {
                                            // Grid Image 1
                                            AsyncImage(url: URL(string: gridImage1URL)) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                        .clipped()
                                                case .failure:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .font(.largeTitle)
                                                                .foregroundColor(.secondary)
                                                        )
                                                @unknown default:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                }
                                            }
                                            
                                            // Grid Image 2
                                            AsyncImage(url: URL(string: gridImage2URL)) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                        .clipped()
                                                case .failure:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .font(.largeTitle)
                                                                .foregroundColor(.secondary)
                                                        )
                                                @unknown default:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 180)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        
                                        Divider()
                                            .padding(.horizontal, 16)
                                        
                                        // From the Business - Image on RIGHT, white card
                                        HStack(alignment: .top, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("From the Business")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                Text(fromBusiness)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.primary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            
                                            Spacer()
                                            
                                            AsyncImage(url: URL(string: fromBusinessImageURL)) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(width: 56, height: 56)
                                                        .cornerRadius(8)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 56, height: 56)
                                                        .cornerRadius(8)
                                                        .clipped()
                                                case .failure:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(width: 56, height: 56)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                            Image(systemName: "photo")
                                                                .font(.title2)
                                                                .foregroundColor(.secondary)
                                                        )
                                                @unknown default:
                                                    Rectangle()
                                                        .fill(Color(.systemGray5))
                                                        .frame(width: 56, height: 56)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        
                                        Spacer(minLength: 20)
                                    }
                                    .background(Color.white)
                                }
                            }
                            
                            Text("This is sample preview — Photos can be added after Apple approves your location and brand. Check your status at Branding Profile section.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12)
                }
                .scrollIndicators(.visible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - iPhone Device Frame - FULL HEIGHT
struct iPhoneDeviceFrame<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: 375, height: 780)
            .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .stroke(Color.black, lineWidth: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black)
                    .frame(width: 120, height: 30)
                    .overlay(
                        Circle()
                            .fill(Color(white: 0.15))
                            .frame(width: 8, height: 8)
                            .offset(x: -28)
                    )
                    .offset(y: -4),
                alignment: .top
            )
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    PreviewView(
        displayName: "La Colombe Coffee Roasters",
        primaryCategory: "Cafe & Coffee Shop",
        city: "Fishtown",
        state: "Philadelphia"
    )
}
