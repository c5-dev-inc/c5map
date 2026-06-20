import SwiftUI
import StoreKit

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @State private var selectedTab = 0
    @State private var isMenuOpen = false
    @State private var showingAIAssistant = false
    @State private var showingUpgradePlan = false
    @State private var showingCreateCampaign = false
    @State private var showingRegisterBusiness = false
    @State private var showingConnectExisting = false
    
    // Navigation state for menu items - Separate for each tab
    @State private var homeNavigationPath = NavigationPath()
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
        Group {
            if !authManager.isAuthenticated {
                SignInView(onSignIn: {
                    authManager.setAuthenticated(true)
                })
            } else if !authManager.hasSubscription {
                UpgradePlanView(onComplete: {
                    authManager.setSubscriptionActive(true)
                })
            } else {
                // Main App
                ZStack {
                    TabView(selection: $selectedTab) {
                        // Home Tab
                        NavigationStack(path: $homeNavigationPath) {
                            HomeView()
                                .navigationDestination(for: String.self) { destination in
                                    handleNavigationDestination(destination, forTab: 0)
                                }
                        }
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                        
                        // Ask AI Tab with sparkle icon
                        Color.clear
                            .tabItem {
                                Label("Ask AI", systemImage: "sparkles")
                            }
                            .tag(1)
                        
                        // Settings Tab
                        NavigationStack(path: $settingsNavigationPath) {
                            SettingsView()
                                .navigationDestination(for: String.self) { destination in
                                    handleNavigationDestination(destination, forTab: 2)
                                }
                                .sheet(isPresented: $showingUpgradePlan) {
                                    UpgradePlanView(onComplete: nil)
                                }
                        }
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(2)
                    }
                    .onChange(of: selectedTab) { oldValue, newValue in
                        if newValue == 1 {
                            // When Ask AI tab is selected, show the AI Assistant
                            showingAIAssistant = true
                            // Immediately switch back to previous tab
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedTab = oldValue
                            }
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        // Menu Button with Round Overlay
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
                    .overlay(alignment: .topTrailing) {
                        // Notification Button (Top Right)
                        Button(action: {
                            // Navigate based on current tab
                            if selectedTab == 0 {
                                homeNavigationPath.append("notifications")
                            } else if selectedTab == 2 {
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
                    
                    // Business Registration Sheet
                    EmptyView()
                        .sheet(isPresented: $showingRegisterBusiness) {
                            ConnectBusinessView()
                        }
                        .sheet(isPresented: $showingConnectExisting) {
                            ConnectExistingView()
                        }
                    
                    // Menu View
                    MenuView(isMenuOpen: $isMenuOpen) { action in
                        switch action {
                        case .business:
                            if selectedTab == 0 {
                                homeNavigationPath.append("business")
                            } else if selectedTab == 2 {
                                settingsNavigationPath.append("business")
                            }
                        case .campaigns:
                            if selectedTab == 0 {
                                homeNavigationPath.append("campaigns")
                            } else if selectedTab == 2 {
                                settingsNavigationPath.append("campaigns")
                            }
                        case .dashboard:
                            if selectedTab == 0 {
                                homeNavigationPath.append("dashboard")
                            } else if selectedTab == 2 {
                                settingsNavigationPath.append("dashboard")
                            }
                        case .upgrade:
                            showingUpgradePlan = true
                        case .help:
                            if let url = URL(string: "https://c5-dev.com/maps/support") {
                                UIApplication.shared.open(url)
                            }
                        case .contact:
                            if let url = URL(string: "mailto:support@c5-dev.com") {
                                UIApplication.shared.open(url)
                            }
                        case .privacy:
                            if let url = URL(string: "https://c5-dev.com/maps/privacy") {
                                UIApplication.shared.open(url)
                            }
                        case .terms:
                            if let url = URL(string: "https://c5-dev.com/maps/terms") {
                                UIApplication.shared.open(url)
                            }
                        case .rate:
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        case .signOut:
                            authManager.setAuthenticated(false)
                        }
                    }
                }
                .sheet(isPresented: $showingAIAssistant) {
                    AIAssistantView()
                }
            }
        }
    }
    
    @ViewBuilder
    private func handleNavigationDestination(_ destination: String, forTab tab: Int) -> some View {
        switch destination {
        case "business":
            BusinessView()
                .navigationTitle("Business")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 2 {
                                settingsNavigationPath.removeLast()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
        case "campaigns":
            CampaignListView()
                .navigationTitle("Campaigns")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 2 {
                                settingsNavigationPath.removeLast()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
        case "dashboard":
            DashboardView()
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if tab == 0 {
                                homeNavigationPath.removeLast()
                            } else if tab == 2 {
                                settingsNavigationPath.removeLast()
                            }
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
                            } else if tab == 2 {
                                settingsNavigationPath.removeLast()
                            }
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
}
