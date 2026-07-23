//
//  StoreDetailView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-09.
//

import SwiftUI
import MapKit

struct StoreDetailView: View {
    let store: Store
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: Product?
    @State private var showingPayment = false
    @State private var showingAppleMaps = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Store Header Image
                StoreHeaderView(store: store, dismiss: dismiss)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Store Info
                    StoreInfoSection(store: store)
                    
                    Divider()
                    
                    // Products Section
                    ProductsSection(
                        products: store.products,
                        onBuyTapped: { product in
                            selectedProduct = product
                            showingPayment = true
                        }
                    )
                    
                    Divider()
                    
                    // View on Apple Maps Button
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
            colorScheme == .dark ? Color.black : Color(.systemGroupedBackground)
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedProduct) { product in
            PaymentView(product: product, store: store)
        }
        .sheet(isPresented: $showingAppleMaps) {
            AppleMapsView(store: store)
        }
    }
}

// MARK: - Store Header

struct StoreHeaderView: View {
    let store: Store
    let dismiss: DismissAction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image or Gradient
            if let imageURL = store.imageURL, !imageURL.isEmpty {
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
                    Text(store.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if store.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                
                HStack(spacing: 12) {
                    Label(store.category.rawValue, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Single Star + Not Verified
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Not Tracked")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Address on banner
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text(store.address)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Close Button - Top Right Overlay
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

// MARK: - Store Info Section

struct StoreInfoSection: View {
    let store: Store
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("About")
                    .font(.headline)
                
                Spacer()
                
                if store.isVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Verified")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            Text(store.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            // Website icon
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
                    icon: "star.fill",
                    color: .yellow,
                    value: "Not Tracked",
                    label: "Rating"
                )
                
                StatItem(
                    icon: "map.fill",
                    color: .blue,
                    value: "View",
                    label: "Maps"
                )
                
                StatItem(
                    icon: "bag",
                    color: .green,
                    value: "\(store.products.count)",
                    label: "Products"
                )
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Products Section

struct ProductsSection: View {
    let products: [Product]
    let onBuyTapped: (Product) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    let sampleImages = [
        "https://picsum.photos/seed/coffee/400/400",
        "https://picsum.photos/seed/croissant/400/400",
        "https://picsum.photos/seed/phone/400/400",
        "https://picsum.photos/seed/laptop/400/400",
        "https://picsum.photos/seed/plant/400/400",
        "https://picsum.photos/seed/garden/400/400"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products")
                .font(.headline)
            
            if products.isEmpty {
                Text("No products available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductGridView(product: product, imageURL: sampleImages[index % sampleImages.count], onBuyTapped: onBuyTapped)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Product Grid View

struct ProductGridView: View {
    let product: Product
    let imageURL: String
    let onBuyTapped: (Product) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                case .failure:
                    productPlaceholder
                @unknown default:
                    productPlaceholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: { onBuyTapped(product) }) {
                        Text("Buy")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    var productPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            
            Image(systemName: "bag")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Payment View

struct PaymentView: View {
    let product: Product
    let store: Store
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Product Info
                VStack(spacing: 12) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(store.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Payment Button
                VStack(spacing: 16) {
                    Button(action: processPayment) {
                        HStack {
                            Image(systemName: "applepay")
                            Text("Pay with Apple Pay")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func processPayment() {
        print("💳 Processing payment for: \(product.name)")
        dismiss()
    }
}

// MARK: - Apple Maps View

struct AppleMapsView: View {
    let store: Store
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(store.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.yellow)
                                
                                Text("Not Tracked")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        if store.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(store.address)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Button(action: openInAppleMaps) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Open in Maps")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        Button(action: copyAddress) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                    
                    MapPreviewView(address: store.address, name: store.name)
                        .frame(height: 300)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if let website = store.website, !website.isEmpty {
                        Button(action: openWebsite) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Visit Website")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding(.top, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func openInAppleMaps() {
        let addressEncoded = store.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?address=\(addressEncoded)&q=\(store.name)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func copyAddress() {
        UIPasteboard.general.string = store.address
    }
    
    private func openWebsite() {
        guard let website = store.website, let url = URL(string: website) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Map Preview

struct MapPreviewView: View {
    let address: String
    let name: String
    @State private var region: MKCoordinateRegion?
    
    var body: some View {
        VStack {
            if let region = region {
                Map(coordinateRegion: .constant(region), interactionModes: [.zoom, .pan])
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(ProgressView())
                    .onAppear {
                        geocodeAddress()
                    }
            }
        }
    }
    
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        StoreDetailView(store: Store(
            name: "C5 Coffee House",
            description: "Premium coffee and pastries. Join us for the best brew in town!",
            category: .food,
            address: "123 Main St, San Francisco, CA",
            website: "https://c5coffee.com",
            imageURL: nil,
            products: [
                Product(name: "Latte", description: "Premium espresso with steamed milk", price: 4.99, imageURL: nil),
                Product(name: "Croissant", description: "Buttery, flaky pastry", price: 3.49, imageURL: nil),
                Product(name: "Mocha", description: "Chocolate espresso delight", price: 5.49, imageURL: nil),
                Product(name: "Pastry Box", description: "Assorted pastries", price: 12.99, imageURL: nil)
            ],
            ratings: [],
            isVerified: true,
            distance: 0.5,
            ownerID: "owner1"
        ))
    }
}
