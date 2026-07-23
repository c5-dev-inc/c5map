import SwiftUI
import PhotosUI
import Supabase

// MARK: - Product Model - MATCH YOUR DATABASE EXACTLY
struct InventoryProduct: Identifiable, Codable {
    let id: Int?
    let storeId: Int
    let name: String
    let description: String?
    let price: Double
    let imageUrl: String?
    let isAvailable: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case name
        case description
        case price
        case imageUrl = "image_url"
        case isAvailable = "is_available"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: Int? = nil, storeId: Int, name: String, description: String? = nil, price: Double, imageUrl: String? = nil, isAvailable: Bool? = true, createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self.storeId = storeId
        self.name = name
        self.description = description
        self.price = price
        self.imageUrl = imageUrl
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Product Image Model - MATCH YOUR DATABASE EXACTLY
struct ProductImage: Codable {
    let id: Int?
    let productId: Int
    let imageUrl: String
    let isMain: Bool
    let order: Int
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case imageUrl = "image_url"
        case isMain = "is_main"
        case order
        case createdAt = "created_at"
    }
    
    init(id: Int? = nil, productId: Int, imageUrl: String, isMain: Bool = false, order: Int = 0, createdAt: String? = nil) {
        self.id = id
        self.productId = productId
        self.imageUrl = imageUrl
        self.isMain = isMain
        self.order = order
        self.createdAt = createdAt
    }
}

// MARK: - Add Products Sheet
struct AddProductsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var products: [InventoryProduct] = []
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingAddProduct = false
    @State private var selectedProduct: InventoryProduct?
    @State private var showingEditProduct = false
    @State private var supabaseClient: SupabaseClient?
    @State private var storeId: Int?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if products.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Products Added")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Tap the + button to add your first product")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(products) { product in
                                ProductCardView(
                                    product: product,
                                    onEdit: {
                                        selectedProduct = product
                                        showingEditProduct = true
                                    },
                                    onDelete: {
                                        deleteProduct(product)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddProduct = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                initializeSupabase()
                fetchStoreId()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductFormView(storeId: storeId ?? 0, onProductAdded: {
                    fetchProducts()
                })
            }
            .sheet(isPresented: $showingEditProduct) {
                if let product = selectedProduct {
                    EditProductFormView(product: product, onProductUpdated: {
                        fetchProducts()
                    })
                }
            }
        }
    }
    
    private func initializeSupabase() {
        supabaseClient = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    private func fetchStoreId() {
        guard let userId = authManager.userId else {
            errorMessage = "User not signed in"
            showError = true
            return
        }
        
        guard let supabase = supabaseClient else {
            errorMessage = "Supabase client not initialized"
            showError = true
            return
        }
        
        Task {
            do {
                let response = try await supabase
                    .from("maps_locations")
                    .select("id")
                    .eq("user_id", value: userId)
                    .limit(1)
                    .execute()
                
                let decoder = JSONDecoder()
                let locations = try decoder.decode([MyStore].self, from: response.data)
                
                DispatchQueue.main.async {
                    if let firstStore = locations.first {
                        self.storeId = firstStore.id
                        self.fetchProducts()
                    } else {
                        self.isLoading = false
                        self.errorMessage = "No store found"
                        self.showError = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Failed to fetch store: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func fetchProducts() {
        guard let storeId = storeId else { return }
        guard let supabase = supabaseClient else { return }
        
        isLoading = true
        
        Task {
            do {
                let response = try await supabase
                    .from("maps_products")
                    .select("*")
                    .eq("store_id", value: storeId)
                    .order("created_at", ascending: false)
                    .execute()
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                let fetchedProducts = try decoder.decode([InventoryProduct].self, from: response.data)
                
                DispatchQueue.main.async {
                    self.products = fetchedProducts
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Failed to fetch products: \(error.localizedDescription)"
                    showError = true
                    print("Decoding error: \(error)")
                }
            }
        }
    }
    
    private func deleteProduct(_ product: InventoryProduct) {
        guard let productId = product.id else { return }
        guard let supabase = supabaseClient else { return }
        
        Task {
            do {
                let imagesResponse = try await supabase
                    .from("maps_products_images")
                    .select("image_url")
                    .eq("product_id", value: productId)
                    .execute()
                
                let decoder = JSONDecoder()
                let images = try decoder.decode([ProductImage].self, from: imagesResponse.data)
                
                for image in images {
                    let path = image.imageUrl.replacingOccurrences(of: "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/", with: "")
                    try await supabase
                        .storage
                        .from("maps_products_images")
                        .remove(paths: [path])
                }
                
                try await supabase
                    .from("maps_products_images")
                    .delete()
                    .eq("product_id", value: productId)
                    .execute()
                
                try await supabase
                    .from("maps_products")
                    .delete()
                    .eq("id", value: productId)
                    .execute()
                
                DispatchQueue.main.async {
                    fetchProducts()
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to delete product: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Product Card View
struct ProductCardView: View {
    let product: InventoryProduct
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var mainImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let mainImage = mainImage {
                    Image(uiImage: mainImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                    
                    if let description = product.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    if let isAvailable = product.isAvailable {
                        Text(isAvailable ? "Available" : "Unavailable")
                            .font(.caption2)
                            .foregroundColor(isAvailable ? .green : .red)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            loadMainImage()
        }
    }
    
    private func loadMainImage() {
        guard let imageUrl = product.imageUrl else { return }
        
        Task {
            do {
                let supabase = SupabaseClient(
                    supabaseURL: Config.supabaseURL,
                    supabaseKey: Config.supabaseAnonKey
                )
                
                let path = imageUrl.replacingOccurrences(of: "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/", with: "")
                let data = try await supabase
                    .storage
                    .from("maps_products_images")
                    .download(path: path)
                
                DispatchQueue.main.async {
                    self.mainImage = UIImage(data: data)
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}

// MARK: - Add Product Form
struct AddProductFormView: View {
    @Environment(\.dismiss) var dismiss
    let storeId: Int
    let onProductAdded: () -> Void
    
    @State private var productName = ""
    @State private var productDescription = ""
    @State private var productPrice = ""
    @State private var isAvailable = true
    @State private var selectedMainImage: PhotosPickerItem?
    @State private var mainImageData: Data?
    @State private var selectedAdditionalImages: [PhotosPickerItem] = []
    @State private var additionalImagesData: [Data] = []
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var supabaseClient: SupabaseClient?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Product Name", text: $productName)
                    TextField("Description", text: $productDescription, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Price", text: $productPrice)
                        .keyboardType(.decimalPad)
                    Toggle("Available", isOn: $isAvailable)
                }
                
                Section("Main Image") {
                    PhotosPicker(selection: $selectedMainImage, matching: .images) {
                        HStack {
                            if let mainImageData, let image = UIImage(data: mainImageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                                Text("Select Main Image")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onChange(of: selectedMainImage) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                mainImageData = data
                            }
                        }
                    }
                }
                
                Section("Additional Images (Max 3)") {
                    PhotosPicker(selection: $selectedAdditionalImages, maxSelectionCount: 3, matching: .images) {
                        HStack {
                            Image(systemName: "photo.stack.badge.plus")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            Text("Add Additional Images")
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(additionalImagesData.count >= 3)
                    .onChange(of: selectedAdditionalImages) { _, newItems in
                        Task {
                            var newData: [Data] = []
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    newData.append(data)
                                }
                            }
                            let total = additionalImagesData.count + newData.count
                            if total <= 3 {
                                additionalImagesData.append(contentsOf: newData)
                            } else {
                                let remaining = 3 - additionalImagesData.count
                                additionalImagesData.append(contentsOf: newData.prefix(remaining))
                            }
                        }
                    }
                    
                    if !additionalImagesData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(additionalImagesData.enumerated()), id: \.offset) { index, imageData in
                                    if let image = UIImage(data: imageData) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            Button(action: {
                                                additionalImagesData.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text("\(additionalImagesData.count)/3 additional images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: saveProduct) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Add Product")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.blue)
                    .disabled(productName.isEmpty || productPrice.isEmpty || mainImageData == nil || isSaving)
                }
            }
            .navigationTitle("New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeSupabase()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func initializeSupabase() {
        supabaseClient = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    private func saveProduct() {
        guard let price = Double(productPrice),
              let mainImageData = mainImageData,
              let supabase = supabaseClient else { return }
        
        isSaving = true
        
        Task {
            do {
                // 1. Upload main image
                let mainImagePath = "\(storeId)/\(UUID().uuidString).jpg"
                try await supabase
                    .storage
                    .from("maps_products_images")
                    .upload(
                        path: mainImagePath,
                        file: mainImageData,
                        options: FileOptions(contentType: "image/jpeg")
                    )
                
                let mainImageUrl = "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/\(mainImagePath)"
                
                // 2. Insert product
                let newProduct = InventoryProduct(
                    storeId: storeId,
                    name: productName,
                    description: productDescription.isEmpty ? nil : productDescription,
                    price: price,
                    imageUrl: mainImageUrl,
                    isAvailable: isAvailable
                )
                
                let productData = try JSONEncoder().encode(newProduct)
                let productResponse = try await supabase
                    .from("maps_products")
                    .insert(productData)
                    .select()
                    .single()
                    .execute()
                
                let decoder = JSONDecoder()
                let insertedProduct = try decoder.decode(InventoryProduct.self, from: productResponse.data)
                
                guard let productId = insertedProduct.id else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get product ID"])
                }
                
                // 3. Upload additional images
                for (index, imageData) in additionalImagesData.enumerated() {
                    let imagePath = "\(storeId)/\(productId)/additional_\(index)_\(UUID().uuidString).jpg"
                    try await supabase
                        .storage
                        .from("maps_products_images")
                        .upload(
                            path: imagePath,
                            file: imageData,
                            options: FileOptions(contentType: "image/jpeg")
                        )
                    
                    let imageUrl = "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/\(imagePath)"
                    
                    let productImage = ProductImage(
                        productId: productId,
                        imageUrl: imageUrl,
                        isMain: false,
                        order: index
                    )
                    
                    let imageData = try JSONEncoder().encode(productImage)
                    try await supabase
                        .from("maps_products_images")
                        .insert(imageData)
                        .execute()
                }
                
                DispatchQueue.main.async {
                    isSaving = false
                    onProductAdded()
                    dismiss()
                }
                
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = "Failed to save product: \(error.localizedDescription)"
                    showError = true
                    print("Save error: \(error)")
                }
            }
        }
    }
}

// MARK: - Edit Product Form
struct EditProductFormView: View {
    @Environment(\.dismiss) var dismiss
    let product: InventoryProduct
    let onProductUpdated: () -> Void
    
    @State private var productName: String
    @State private var productDescription: String
    @State private var productPrice: String
    @State private var isAvailable: Bool
    @State private var mainImageData: Data?
    @State private var additionalImagesData: [Data] = []
    @State private var existingAdditionalImages: [String] = []
    @State private var selectedMainImage: PhotosPickerItem?
    @State private var selectedAdditionalImages: [PhotosPickerItem] = []
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var supabaseClient: SupabaseClient?
    @State private var existingImageUrl: String
    
    init(product: InventoryProduct, onProductUpdated: @escaping () -> Void) {
        self.product = product
        self.onProductUpdated = onProductUpdated
        _productName = State(initialValue: product.name)
        _productDescription = State(initialValue: product.description ?? "")
        _productPrice = State(initialValue: String(format: "%.2f", product.price))
        _isAvailable = State(initialValue: product.isAvailable ?? true)
        _existingImageUrl = State(initialValue: product.imageUrl ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Product Name", text: $productName)
                    TextField("Description", text: $productDescription, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Price", text: $productPrice)
                        .keyboardType(.decimalPad)
                    Toggle("Available", isOn: $isAvailable)
                }
                
                Section("Main Image") {
                    PhotosPicker(selection: $selectedMainImage, matching: .images) {
                        HStack {
                            if let mainImageData, let image = UIImage(data: mainImageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else if !existingImageUrl.isEmpty {
                                AsyncImage(url: URL(string: existingImageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    case .failure:
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                            .frame(width: 100, height: 100)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                                Text("Change Main Image")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onChange(of: selectedMainImage) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                mainImageData = data
                            }
                        }
                    }
                }
                
                Section("Additional Images (Max 3)") {
                    PhotosPicker(selection: $selectedAdditionalImages, maxSelectionCount: 3, matching: .images) {
                        HStack {
                            Image(systemName: "photo.stack.badge.plus")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            Text("Add More Images")
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(additionalImagesData.count >= 3)
                    .onChange(of: selectedAdditionalImages) { _, newItems in
                        Task {
                            var newData: [Data] = []
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    newData.append(data)
                                }
                            }
                            let total = additionalImagesData.count + newData.count
                            if total <= 3 {
                                additionalImagesData.append(contentsOf: newData)
                            } else {
                                let remaining = 3 - additionalImagesData.count
                                additionalImagesData.append(contentsOf: newData.prefix(remaining))
                            }
                        }
                    }
                    
                    if !existingAdditionalImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(existingAdditionalImages.enumerated()), id: \.offset) { index, imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        if case .success(let image) = phase {
                                            ZStack(alignment: .topTrailing) {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                                Button(action: {
                                                    existingAdditionalImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if !additionalImagesData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(additionalImagesData.enumerated()), id: \.offset) { index, imageData in
                                    if let image = UIImage(data: imageData) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            Button(action: {
                                                additionalImagesData.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text("\(existingAdditionalImages.count + additionalImagesData.count)/3 additional images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: saveProduct) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.blue)
                    .disabled(productName.isEmpty || productPrice.isEmpty || isSaving)
                }
                
                Section {
                    Button(action: deleteProduct) {
                        Text("Delete Product")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeSupabase()
                fetchProductImages()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func initializeSupabase() {
        supabaseClient = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    private func fetchProductImages() {
        guard let productId = product.id else { return }
        guard let supabase = supabaseClient else { return }
        
        Task {
            do {
                let response = try await supabase
                    .from("maps_products_images")
                    .select("image_url")
                    .eq("product_id", value: productId)
                    .eq("is_main", value: false)
                    .order("order", ascending: true)
                    .execute()
                
                let decoder = JSONDecoder()
                let images = try decoder.decode([ProductImage].self, from: response.data)
                
                DispatchQueue.main.async {
                    self.existingAdditionalImages = images.map { $0.imageUrl }
                }
            } catch {
                print("Failed to fetch images: \(error)")
            }
        }
    }
    
    private func saveProduct() {
        guard let price = Double(productPrice),
              let supabase = supabaseClient,
              let productId = product.id else { return }
        
        isSaving = true
        
        Task {
            do {
                // 1. Update product
                let updatedProduct = InventoryProduct(
                    id: productId,
                    storeId: product.storeId,
                    name: productName,
                    description: productDescription.isEmpty ? nil : productDescription,
                    price: price,
                    imageUrl: existingImageUrl,
                    isAvailable: isAvailable
                )
                
                let productData = try JSONEncoder().encode(updatedProduct)
                try await supabase
                    .from("maps_products")
                    .update(productData)
                    .eq("id", value: productId)
                    .execute()
                
                // 2. Handle main image change
                if let mainImageData = mainImageData {
                    if !existingImageUrl.isEmpty {
                        let oldPath = existingImageUrl.replacingOccurrences(of: "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/", with: "")
                        try await supabase
                            .storage
                            .from("maps_products_images")
                            .remove(paths: [oldPath])
                    }
                    
                    let mainImagePath = "\(product.storeId)/\(productId)/main_\(UUID().uuidString).jpg"
                    try await supabase
                        .storage
                        .from("maps_products_images")
                        .upload(
                            path: mainImagePath,
                            file: mainImageData,
                            options: FileOptions(contentType: "image/jpeg")
                        )
                    
                    let newImageUrl = "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/\(mainImagePath)"
                    
                    try await supabase
                        .from("maps_products")
                        .update(["image_url": newImageUrl])
                        .eq("id", value: productId)
                        .execute()
                    
                    let imageUpdate = ProductImage(
                        productId: productId,
                        imageUrl: newImageUrl,
                        isMain: true,
                        order: 0
                    )
                    let imageData = try JSONEncoder().encode(imageUpdate)
                    try await supabase
                        .from("maps_products_images")
                        .upsert(imageData)
                        .eq("product_id", value: productId)
                        .eq("is_main", value: true)
                        .execute()
                }
                
                // 3. Handle new additional images
                for (index, imageData) in additionalImagesData.enumerated() {
                    let imagePath = "\(product.storeId)/\(productId)/additional_\(index)_\(UUID().uuidString).jpg"
                    try await supabase
                        .storage
                        .from("maps_products_images")
                        .upload(
                            path: imagePath,
                            file: imageData,
                            options: FileOptions(contentType: "image/jpeg")
                        )
                    
                    let imageUrl = "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/\(imagePath)"
                    
                    let productImage = ProductImage(
                        productId: productId,
                        imageUrl: imageUrl,
                        isMain: false,
                        order: existingAdditionalImages.count + index
                    )
                    
                    let imageData = try JSONEncoder().encode(productImage)
                    try await supabase
                        .from("maps_products_images")
                        .insert(imageData)
                        .execute()
                }
                
                // 4. Handle deleted additional images
                let currentImages = try await supabase
                    .from("maps_products_images")
                    .select("image_url")
                    .eq("product_id", value: productId)
                    .eq("is_main", value: false)
                    .execute()
                
                let decoder = JSONDecoder()
                let currentImageUrls = try decoder.decode([ProductImage].self, from: currentImages.data).map { $0.imageUrl }
                
                let imagesToDelete = currentImageUrls.filter { !existingAdditionalImages.contains($0) }
                for imageUrl in imagesToDelete {
                    let path = imageUrl.replacingOccurrences(of: "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/", with: "")
                    try await supabase
                        .storage
                        .from("maps_products_images")
                        .remove(paths: [path])
                    
                    try await supabase
                        .from("maps_products_images")
                        .delete()
                        .eq("image_url", value: imageUrl)
                        .execute()
                }
                
                DispatchQueue.main.async {
                    isSaving = false
                    onProductUpdated()
                    dismiss()
                }
                
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = "Failed to save product: \(error.localizedDescription)"
                    showError = true
                    print("Save error: \(error)")
                }
            }
        }
    }
    
    private func deleteProduct() {
        guard let productId = product.id else { return }
        guard let supabase = supabaseClient else { return }
        
        Task {
            do {
                let imagesResponse = try await supabase
                    .from("maps_products_images")
                    .select("image_url")
                    .eq("product_id", value: productId)
                    .execute()
                
                let decoder = JSONDecoder()
                let images = try decoder.decode([ProductImage].self, from: imagesResponse.data)
                
                for image in images {
                    let path = image.imageUrl.replacingOccurrences(of: "\(Config.supabaseURL)/storage/v1/object/public/maps_products_images/", with: "")
                    try await supabase
                        .storage
                        .from("maps_products_images")
                        .remove(paths: [path])
                }
                
                try await supabase
                    .from("maps_products_images")
                    .delete()
                    .eq("product_id", value: productId)
                    .execute()
                
                try await supabase
                    .from("maps_products")
                    .delete()
                    .eq("id", value: productId)
                    .execute()
                
                DispatchQueue.main.async {
                    onProductUpdated()
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to delete product: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
