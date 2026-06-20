import SwiftUI
import StoreKit

// MARK: - Menu Item Type for ContentView Callback
enum MenuActionType {
    case business
    case campaigns
    case dashboard
    case upgrade
    case help
    case contact
    case privacy
    case terms
    case rate
    case signOut
}

struct MenuView: View {
    @Binding var isMenuOpen: Bool
    var onMenuAction: ((MenuActionType) -> Void)?
    
    @State private var selectedItem: MenuItemEnum?
    
    enum MenuItemEnum: String, CaseIterable {
        case business = "Business"
        case campaigns = "Campaigns"
        case dashboard = "Dashboard"
        
        var icon: String {
            switch self {
            case .business: return "building.2.fill"
            case .campaigns: return "megaphone.fill"
            case .dashboard: return "square.grid.2x2.fill"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .business: return .green
            case .campaigns: return .purple
            case .dashboard: return .blue
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background overlay when menu is open
            if isMenuOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.25)) {
                            isMenuOpen = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Sliding Menu
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Menu Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MENU")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Navigate through the app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // MARK: - Main Menu Items (Business, Campaigns, Dashboard)
                            ForEach(MenuItemEnum.allCases, id: \.self) { item in
                                MenuRowView(
                                    icon: item.icon,
                                    title: item.rawValue,
                                    color: item.iconColor,
                                    isSelected: selectedItem == item
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedItem = item
                                        isMenuOpen = false
                                        
                                        // Trigger navigation based on selection
                                        switch item {
                                        case .business:
                                            onMenuAction?(.business)
                                        case .campaigns:
                                            onMenuAction?(.campaigns)
                                        case .dashboard:
                                            onMenuAction?(.dashboard)
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            // MARK: - Subscription Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUBSCRIPTION")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                
                                MenuRowView(
                                    icon: "crown.fill",
                                    title: "Upgrade to Pro",
                                    color: .yellow,
                                    isSelected: false
                                ) {
                                    isMenuOpen = false
                                    onMenuAction?(.upgrade)
                                }
                            }
                            .padding(.top, 8)
                            
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            // MARK: - Support Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUPPORT")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                
                                MenuRowView(
                                    icon: "questionmark.circle.fill",
                                    title: "Help Center",
                                    color: .blue,
                                    isSelected: false
                                ) {
                                    isMenuOpen = false
                                    onMenuAction?(.help)
                                }
                                
                                MenuRowView(
                                    icon: "envelope.fill",
                                    title: "Contact Us",
                                    color: .blue,
                                    isSelected: false
                                ) {
                                    isMenuOpen = false
                                    onMenuAction?(.contact)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            // MARK: - Legal Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("LEGAL")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                
                                MenuRowView(
                                    icon: "doc.text.fill",
                                    title: "Privacy Policy",
                                    color: .secondary,
                                    isSelected: false
                                ) {
                                    isMenuOpen = false
                                    onMenuAction?(.privacy)
                                }
                                
                                MenuRowView(
                                    icon: "doc.text.fill",
                                    title: "Terms of Service",
                                    color: .secondary,
                                    isSelected: false
                                ) {
                                    isMenuOpen = false
                                    onMenuAction?(.terms)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            // MARK: - App Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("APP")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                
                                HStack {
                                    Image(systemName: "iphone.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                        .frame(width: 32)
                                    Text("Version")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                
                                MenuRowView(
                                    icon: "star.circle.fill",
                                    title: "Rate C5 Maps",
                                    color: .orange,
                                    isSelected: false
                                ) {
                                    isMenuOpen = false
                                    onMenuAction?(.rate)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            // MARK: - Sign Out Button
                            Button(action: {
                                isMenuOpen = false
                                onMenuAction?(.signOut)
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                        .frame(width: 32)
                                    Text("Sign Out")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
                .frame(width: 280)
                .background(Color(.systemBackground))
                .offset(x: isMenuOpen ? 0 : -280)
                .animation(.easeOut(duration: 0.25), value: isMenuOpen)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Menu Row Component
struct MenuRowView: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var isOpen = true
        var body: some View {
            MenuView(isMenuOpen: $isOpen) { action in
                print("Selected: \(action)")
            }
        }
    }
    return PreviewWrapper()
}
