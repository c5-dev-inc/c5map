import SwiftUI
import StoreKit

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var iapManager: IAPManager
    @State private var selectedTab = 0
    @State private var isMenuOpen = false
    @State private var showingAIAssistant = false
    @State private var showingUpgradePlan = false
    @State private var showingCreateCampaign = false
    @State private var showingRegisterBusiness = false
    @State private var showingConnectExisting = false
    @State private var showingTapToPay = false
    @State private var showingWebView = false
    @State private var webViewURL: URL?
    @State private var showingStoreCreation = false
    @State private var showingMyStore = false  // ✅ NEW
    @State private var showingShareSheet = false
    @State private var shareText = ""
    @State private var isInChildView = false
    
    // Navigation state for menu items - Separate for each tab
    @State private var homeNavigationPath = NavigationPath()
    @State private var marketplaceNavigationPath = NavigationPath()
    @State private var settingsNavigationPath = NavigationPath()
    
    init() {
        // Make tab bar icons smaller
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set smaller icon size
        let stackedItemAppearance = UITabBarItemAppearance()
        stackedItemAppearance.normal.iconColor = UIColor.gray
        stackedItemAppearance.selected.iconColor = UIColor.systemBlue
        
        // Adjust image position and size
        stackedItemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        stackedItemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        appearance.stackedLayoutAppearance = stackedItemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        // ✅ REMOVED SUBSCRIPTION CHECK — GO STRAIGHT TO MAIN APP
        ZStack {
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationStack(path: $homeNavigationPath) {
                    HomeView()
                        .navigationDestination(for: String.self) { destination in
                            handleNavigationDestination(destination, forTab: 0)
                        }
                        .onAppear {
                            isInChildView = false
                        }
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                
                // Marketplace Tab
                NavigationStack(path: $marketplaceNavigationPath) {
                    MarketplaceView()
                        .navigationDestination(for: String.self) { destination in
                            handleNavigationDestination(destination, forTab: 1)
                        }
                        .onAppear {
                            isInChildView = false
                        }
                        .onChange(of: marketplaceNavigationPath) { oldValue, newValue in
                            // Detect when we navigate to a child view
                            isInChildView = !newValue.isEmpty
                        }
                }
                .tabItem {
                    Label("Marketplace", systemImage: "storefront")
                }
                .tag(1)
                
                // Tap to Pay Tab
                Color.clear
                    .tabItem {
                        Label("Tap to Pay", systemImage: "wave.3.right.circle.fill")
                    }
                    .tag(2)
                
                // Settings Tab
                NavigationStack(path: $settingsNavigationPath) {
                    SettingsView()
                        .navigationDestination(for: String.self) { destination in
                            handleNavigationDestination(destination, forTab: 3)
                        }
                        .sheet(isPresented: $showingUpgradePlan) {
                            UpgradePlanView(onComplete: {
                                showingUpgradePlan = false
                                authManager.setSubscriptionActive(true)
                                print("✅ Upgrade from settings completed")
                            })
                        }
                        .onAppear {
                            isInChildView = false
                        }
                        .onChange(of: settingsNavigationPath) { oldValue, newValue in
                            isInChildView = !newValue.isEmpty
                        }
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == 2 {
                    // When Tap to Pay tab is selected, show the Tap to Pay view
                    showingTapToPay = true
                    // Immediately switch back to previous tab
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selectedTab = oldValue
                    }
                }
                // Reset child view state when switching tabs
                isInChildView = false
            }
            
            // MARK: - OVERLAY ICONS
            
            // 1. MENU ICON (Top Left)
            .overlay(alignment: .topLeading) {
                if !isInChildView && (selectedTab == 0 || selectedTab == 1 || selectedTab == 3) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.25)) {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                }
            }
            
            // 2. BELL ICON (Top Right)
            .overlay(alignment: .topTrailing) {
                if !isInChildView && (selectedTab == 0 || selectedTab == 3) {
                    Button(action: {
                        if selectedTab == 0 {
                            homeNavigationPath.append("notifications")
                        } else if selectedTab == 3 {
                            settingsNavigationPath.append("notifications")
                        }
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                            
                            // Notification Badge
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .offset(x: -4, y: 4)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
            }
            
            // 3. ADD STORE ICON (Top Right) - Marketplace tab only
            .overlay(alignment: .topTrailing) {
                if !isInChildView && selectedTab == 1 {
                    Button(action: {
                        showingMyStore = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Store")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(.systemBackground))
                                .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
            }
            
            // Business Registration Sheet
            EmptyView()
                .sheet(isPresented: $showingRegisterBusiness) {
                    ConnectBusinessView()
                }
                .sheet(isPresented: $showingConnectExisting) {
                    ConnectExistingView()
                }
                .sheet(isPresented: $showingStoreCreation) {
                    CreateStoreView { newStore in
                        print("✅ Store created: \(newStore.name)")
                        showingStoreCreation = false
                    }
                }
            
            // Menu View
            MenuView(isMenuOpen: $isMenuOpen) { action in
                switch action {
                case .locations:
                    if selectedTab == 0 {
                        homeNavigationPath.append("locations")
                    } else if selectedTab == 1 {
                        marketplaceNavigationPath.append("locations")
                    } else if selectedTab == 3 {
                        settingsNavigationPath.append("locations")
                    }
                case .branding:
                    if selectedTab == 0 {
                        homeNavigationPath.append("branding")
                    } else if selectedTab == 1 {
                        marketplaceNavigationPath.append("branding")
                    } else if selectedTab == 3 {
                        settingsNavigationPath.append("branding")
                    }
                case .tapToPay:
                    if selectedTab == 0 {
                        homeNavigationPath.append("tapToPay")
                    } else if selectedTab == 1 {
                        marketplaceNavigationPath.append("tapToPay")
                    } else if selectedTab == 3 {
                        settingsNavigationPath.append("tapToPay")
                    }
                case .upgrade:
                    showingUpgradePlan = true
                case .help:
                    if let url = URL(string: "https://c5-dev.com/maps/support") {
                        showingWebView = true
                        webViewURL = url
                    }
                case .contact:
                    showingAIAssistant = true
                case .privacy:
                    if let url = URL(string: "https://c5-dev.com/maps/privacy") {
                        showingWebView = true
                        webViewURL = url
                    }
                case .terms:
                    if let url = URL(string: "https://c5-dev.com/maps/terms") {
                        showingWebView = true
                        webViewURL = url
                    }
                case .rate:
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                case .signOut:
                    authManager.signOut()
                    homeNavigationPath = NavigationPath()
                    marketplaceNavigationPath = NavigationPath()
                    settingsNavigationPath = NavigationPath()
                    selectedTab = 0
                }
            }
        }
        .sheet(isPresented: $showingTapToPay) {
            TapToPayReaderView()
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView()
        }
        .sheet(isPresented: $showingWebView) {
            if let url = webViewURL {
                WebView(url: url)
            }
        }
        .sheet(isPresented: $showingMyStore) {
            MyStoreView()
                .environmentObject(authManager)
        }
    }
    
    @ViewBuilder
    private func handleNavigationDestination(_ destination: String, forTab tab: Int) -> some View {
        switch destination {
        case "locations":
            BusinessView()
                .navigationTitle("Locations")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 1 {
                                marketplaceNavigationPath.removeLast()
                            } else if tab == 3 {
                                settingsNavigationPath.removeLast()
                            }
                            isInChildView = false
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
        case "branding":
            BrandingListView()
                .navigationTitle("Branding")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 1 {
                                marketplaceNavigationPath.removeLast()
                            } else if tab == 3 {
                                settingsNavigationPath.removeLast()
                            }
                            isInChildView = false
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
        case "tapToPay":
            TapToPayView()
                .navigationTitle("Tap to Pay")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 1 {
                                marketplaceNavigationPath.removeLast()
                            } else if tab == 3 {
                                settingsNavigationPath.removeLast()
                            }
                            isInChildView = false
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
        case "notifications":
            NotificationView()
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 1 {
                                marketplaceNavigationPath.removeLast()
                            } else if tab == 3 {
                                settingsNavigationPath.removeLast()
                            }
                            isInChildView = false
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
        case "storeDetail":
            StoreDetailView(store: Store(
                name: "Sample Store",
                description: "Sample Description",
                category: .food,
                address: "123 Main St",
                website: nil,
                imageURL: nil,
                products: [],
                ratings: [],
                isVerified: true,
                distance: 0.5,
                ownerID: "owner1"
            ))
            .navigationTitle("Store Detail")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isInChildView = true
            }
            .onDisappear {
                isInChildView = false
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        if tab == 0 {
                            homeNavigationPath.removeLast()
                        } else if tab == 1 {
                            marketplaceNavigationPath.removeLast()
                        } else if tab == 3 {
                            settingsNavigationPath.removeLast()
                        }
                        isInChildView = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(IAPManager.shared)
}
