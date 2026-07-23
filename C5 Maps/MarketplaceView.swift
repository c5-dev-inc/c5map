//
//  MarketplaceView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-09.
//

import SwiftUI
import MapKit
import Combine

struct MarketplaceView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MarketplaceViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: StoreCategory = .all
    @State private var showingStoreCreation = false
    @State private var selectedStore: Store? = nil
    
    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Search stores...")
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Categories
                    CategoryFilterView(selectedCategory: $selectedCategory)
                        .padding(.horizontal)
                    
                    // Stores Grid
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if filteredStores.isEmpty {
                        EmptyStateView()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredStores) { store in
                                Button(action: {
                                    selectedStore = store
                                }) {
                                    StoreCardView(store: store)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80)
            }
            // Tap to dismiss keyboard
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .navigationTitle("Marketplace")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingStoreCreation) {
            CreateStoreView { newStore in
                viewModel.addStore(newStore)
            }
        }
        .sheet(item: $selectedStore) { store in
            NavigationView {
                StoreDetailView(store: store)
            }
        }
        .refreshable {
            await viewModel.fetchStores()
        }
        .onAppear {
            Task {
                await viewModel.fetchStores()
            }
        }
    }
    
    var filteredStores: [Store] {
        var filtered = viewModel.stores
        
        // Filter by category
        if selectedCategory != .all {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Category Filter

enum StoreCategory: String, CaseIterable {
    case all = "All"
    case food = "Food & Drinks"
    case retail = "Retail"
    case services = "Services"
    case health = "Health & Beauty"
    case entertainment = "Entertainment"
    case education = "Education"
    case other = "Other"
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: StoreCategory
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(StoreCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category.rawValue)
                            .font(.caption)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? Color.blue : (colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6)))
                            )
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Store Card

struct StoreCardView: View {
    let store: Store
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                // Store Image / Avatar
                if let imageURL = store.imageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 60)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            storePlaceholder
                        @unknown default:
                            storePlaceholder
                        }
                    }
                } else {
                    storePlaceholder
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text(store.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        // 5 Stars
                        HStack(spacing: 2) {
                            ForEach(1...1, id: \.self) { star in
                                Image(systemName: star <= Int(store.averageRating.rounded()) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(star <= Int(store.averageRating.rounded()) ? .yellow : .gray.opacity(0.3))
                            }
                        }
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize()

                        Text("(Not Tracked)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize()

                        Button(action: { store.openInAppleMaps() }) {
                            Text("View On Maps")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .fixedSize()
                        }

                        if store.isVerified {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fixedSize()
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                                .fixedSize()
                        }
                    }
                }
                
                Spacer()
                
                // Distance
                if let distance = store.distance {
                    Text(String(format: "%.1f mi", distance))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Description
            if !store.description.isEmpty {
                Text(store.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // Products Preview
            if !store.products.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.products.prefix(3)) { product in
                            ProductTagView(product: product)
                        }
                        if store.products.count > 3 {
                            Text("+\(store.products.count - 3) more")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            // Footer
            HStack {
                // Apple Maps Directions Button
                Button(action: { store.openInAppleMaps() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text("Directions")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                
                if let website = store.website, !website.isEmpty {
                    Button(action: { store.openWebsite() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.caption)
                            Text("Website")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Price range indicator
                if !store.products.isEmpty {
                    let minPrice = store.products.map { $0.price }.min() ?? 0
                    let maxPrice = store.products.map { $0.price }.max() ?? 0
                    Text("$\(String(format: "%.0f", minPrice)) - $\(String(format: "%.0f", maxPrice))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    var storePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: "storefront")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Product Tag

struct ProductTagView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 4) {
            Text(product.name)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text("$\(String(format: "%.2f", product.price))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "storefront")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Stores Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Be the first to create a store and start selling!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: CreateStoreView { newStore in
                // This will be handled by the parent
            }) {
                Text("Create Your Store")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .padding(.top, 40)
    }
}

// MARK: - Models

struct Store: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: StoreCategory
    let address: String
    let website: String?
    let imageURL: String?
    let products: [Product]
    let ratings: [Rating]
    let isVerified: Bool
    let distance: Double?
    let ownerID: String
    
    var averageRating: Double {
        guard !ratings.isEmpty else { return 0 }
        let total = ratings.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(ratings.count)
    }
    
    var totalReviews: Int {
        ratings.count
    }
    
    func openInAppleMaps() {
        let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?address=\(addressEncoded)&q=\(name)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func openWebsite() {
        guard let website = website, let url = URL(string: website) else { return }
        UIApplication.shared.open(url)
    }
}

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
}

struct Rating: Identifiable {
    let id = UUID()
    let userID: String
    let userName: String
    let rating: Int
    let review: String?
    let date: Date
}

// MARK: - ViewModel

@MainActor
class MarketplaceViewModel: ObservableObject {
    @Published var stores: [Store] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Load mock data for testing
        loadMockData()
    }
    
    func fetchStores() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Use mock data
        loadMockData()
        
        isLoading = false
    }
    
    func addStore(_ store: Store) {
        stores.append(store)
    }
    
    private func loadMockData() {
        stores = [
            Store(
                name: "C5 Coffee House",
                description: "Premium coffee and pastries. Join us for the best brew in town!",
                category: .food,
                address: "123 Main St, San Francisco, CA",
                website: "https://c5coffee.com",
                imageURL: nil,
                products: [
                    Product(name: "Latte", description: "Premium espresso with steamed milk", price: 4.99, imageURL: nil),
                    Product(name: "Croissant", description: "Buttery, flaky pastry", price: 3.49, imageURL: nil)
                ],
                ratings: [
                    Rating(userID: "user1", userName: "Alex", rating: 5, review: "Best coffee ever!", date: Date()),
                    Rating(userID: "user2", userName: "Sarah", rating: 4, review: "Great atmosphere", date: Date())
                ],
                isVerified: true,
                distance: 0.5,
                ownerID: "owner1"
            ),
            Store(
                name: "TechFix Repair",
                description: "Same-day phone and laptop repairs. Expert technicians.",
                category: .services,
                address: "456 Oak Ave, San Francisco, CA",
                website: "https://techfix.com",
                imageURL: nil,
                products: [
                    Product(name: "Screen Repair", description: "Phone screen replacement", price: 79.99, imageURL: nil),
                    Product(name: "Battery Replacement", description: "New battery installation", price: 49.99, imageURL: nil)
                ],
                ratings: [
                    Rating(userID: "user3", userName: "Mike", rating: 5, review: "Fixed my phone in 20 minutes!", date: Date())
                ],
                isVerified: true,
                distance: 1.2,
                ownerID: "owner2"
            ),
            Store(
                name: "Green Thumb Garden",
                description: "Plants, tools, and expert advice for your garden.",
                category: .retail,
                address: "789 Pine St, San Francisco, CA",
                website: nil,
                imageURL: nil,
                products: [
                    Product(name: "Monstera Plant", description: "Large tropical plant", price: 45.00, imageURL: nil),
                    Product(name: "Garden Set", description: "Complete gardening tool set", price: 29.99, imageURL: nil)
                ],
                ratings: [],
                isVerified: false,
                distance: 2.0,
                ownerID: "owner3"
            )
        ]
    }
}

// MARK: - Create Store View

struct CreateStoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let onSave: (Store) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory: StoreCategory = .other
    @State private var address = ""
    @State private var website = ""
    @State private var products: [Product] = []
    @State private var showingAddProduct = false
    @State private var isVerified = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Store Details") {
                    TextField("Store Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(StoreCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section("Location") {
                    TextField("Address", text: $address)
                    TextField("Website (optional)", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section("Products") {
                    ForEach(products) { product in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .font(.subheadline)
                                Text("$\(String(format: "%.2f", product.price))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    
                    Button(action: { showingAddProduct = true }) {
                        Label("Add Product", systemImage: "plus.circle")
                    }
                }
                
                Section {
                    Toggle("Verified Store", isOn: $isVerified)
                }
                
                Section {
                    Button(action: saveStore) {
                        Text("Create Store")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(name.isEmpty || address.isEmpty)
                }
            }
            .navigationTitle("New Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductView { product in
                    products.append(product)
                }
            }
        }
    }
    
    private func saveStore() {
        let store = Store(
            name: name,
            description: description,
            category: selectedCategory,
            address: address,
            website: website.isEmpty ? nil : website,
            imageURL: nil,
            products: products,
            ratings: [],
            isVerified: isVerified,
            distance: nil,
            ownerID: "current_user"
        )
        
        onSave(store)
        dismiss()
    }
}

// MARK: - Add Product View

struct AddProductView: View {
    @Environment(\.dismiss) var dismiss
    
    let onSave: (Product) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var imageURL = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Product Details") {
                    TextField("Product Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Image URL (optional)", text: $imageURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: saveProduct) {
                        Text("Add Product")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .navigationTitle("New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveProduct() {
        guard let priceDouble = Double(price) else { return }
        
        let product = Product(
            name: name,
            description: description,
            price: priceDouble,
            imageURL: imageURL.isEmpty ? nil : imageURL
        )
        
        onSave(product)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    MarketplaceView()
}
