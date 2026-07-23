import SwiftUI

struct NotificationView: View {
    @State private var notifications: [MockNotification] = [
        MockNotification(
            title: "Branding Profile Status",
            message: "Check branding profile for your submission status.",
            timeAgo: "Just now",
            type: .update,
            isRead: false
        )
    ]
    @State private var selectedFilter: NotificationFilter = .all
    
    enum NotificationFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case alerts = "Alerts"
        case updates = "Updates"
    }
    
    var filteredNotifications: [MockNotification] {
        switch selectedFilter {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        case .alerts:
            return notifications.filter { $0.type == .alert }
        case .updates:
            return notifications.filter { $0.type == .update }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header Section
                    VStack(spacing: 12) {
                        Image(systemName: "bell.circle.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.blue)
                        
                        Text("Notifications")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Stay updated with your business alerts, campaign performance, and important updates.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 20)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NotificationFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        if !filteredNotifications.isEmpty {
                            // Mark all as read button
                            if selectedFilter == .unread && hasUnreadNotifications {
                                Button(action: markAllAsRead) {
                                    HStack {
                                        Spacer()
                                        Text("Mark all as read")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(filteredNotifications) { notification in
                                    NotificationCard(notification: notification) {
                                        markAsRead(notification)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            // Empty State
                            VStack(spacing: 16) {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                
                                Text("No Notifications")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("You're all caught up! Check back later for updates.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 0)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
    }
    
    private var hasUnreadNotifications: Bool {
        notifications.contains { !$0.isRead }
    }
    
    private func markAsRead(_ notification: MockNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notification Card
struct NotificationCard: View {
    let notification: MockNotification
    let onMarkAsRead: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon based on notification type
            ZStack {
                Circle()
                    .fill(notificationColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: notificationIcon)
                    .font(.system(size: 24))
                    .foregroundColor(notificationColor)
            }
            
            // Notification Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(notification.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action button for unread notifications
            if !notification.isRead {
                Button(action: onMarkAsRead) {
                    Text("Mark Read")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
        .opacity(notification.isRead ? 0.7 : 1.0)
    }
    
    private var notificationIcon: String {
        switch notification.type {
        case .alert:
            return "exclamationmark.triangle.fill"
        case .update:
            return "arrow.up.circle.fill"
        case .reminder:
            return "bell.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }
    
    private var notificationColor: Color {
        switch notification.type {
        case .alert:
            return .orange
        case .update:
            return .blue
        case .reminder:
            return .purple
        case .success:
            return .green
        }
    }
}

// MARK: - Models
struct MockNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timeAgo: String
    let type: NotificationType
    var isRead: Bool
}

enum NotificationType {
    case alert
    case update
    case reminder
    case success
}

// MARK: - Preview
#Preview {
    NotificationView()
}
