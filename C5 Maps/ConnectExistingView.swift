import SwiftUI

struct ConnectExistingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var isConnecting = false
    @State private var showSuccess = false
    @State private var selectedLocations: Set<String> = []
    @State private var showLocationPicker = false
    @State private var availableLocations: [ExistingLocation] = [
        ExistingLocation(id: "loc_1", name: "Joe's Pizza", address: "123 Main St, Austin, TX", status: "Verified"),
        ExistingLocation(id: "loc_2", name: "Sushi Master", address: "456 Oak Ave, Austin, TX", status: "Verified"),
        ExistingLocation(id: "loc_3", name: "Coffee House", address: "789 Pine Rd, Austin, TX", status: "Pending"),
        ExistingLocation(id: "loc_4", name: "Gym Fitness", address: "321 Elm St, Austin, TX", status: "Verified")
    ]
    
    var cardBackground: Color {
        colorScheme == .dark ? Color.black : Color(.systemBackground)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Header Icon
                        VStack(spacing: 12) {
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.blue)
                            
                            Text("Connect Existing Business")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Link your verified Apple Business account to start running ads")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Benefits Cards
                        VStack(spacing: 16) {
                            BenefitCard(
                                icon: "checkmark.seal.fill",
                                title: "Verified Already",
                                description: "If your business is already on Apple Maps, connect it instantly",
                                color: .green,
                                backgroundColor: cardBackground
                            )
                            
                            BenefitCard(
                                icon: "clock.fill",
                                title: "No Waiting Period",
                                description: "Skip the verification process — start ads immediately",
                                color: .blue,
                                backgroundColor: cardBackground
                            )
                            
                            BenefitCard(
                                icon: "building.2.fill",
                                title: "Manage Multiple Locations",
                                description: "Connect all your business locations from one dashboard",
                                color: .purple,
                                backgroundColor: cardBackground
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - How It Works
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How it works")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                ConnectHowItWorksRow(number: "1", text: "Tap 'Continue with Apple' below", color: .blue)
                                Divider().padding(.leading, 48)
                                ConnectHowItWorksRow(number: "2", text: "Sign in with your Apple Business account", color: .blue)
                                Divider().padding(.leading, 48)
                                ConnectHowItWorksRow(number: "3", text: "Authorize C5 Maps to access your locations", color: .blue)
                                Divider().padding(.leading, 48)
                                ConnectHowItWorksRow(number: "4", text: "Select which businesses to manage", color: .blue)
                            }
                            .background(cardBackground)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Connect Button
                        Button(action: startOAuth) {
                            HStack {
                                if isConnecting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "applelogo")
                                    Text("Continue with Apple")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isConnecting)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // MARK: - Footer Note
                        VStack(spacing: 8) {
                            Text("We'll only request access to your business locations.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Apple handles all authentication. We never see your password.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
                .scrollIndicators(.hidden)
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
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(
                    locations: availableLocations,
                    selectedLocations: $selectedLocations,
                    onConfirm: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showSuccess = false
                            dismiss()
                        }
                    }
                )
            }
            .overlay {
                if showSuccess {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            Text("Connected Successfully!")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(selectedLocations.count) business(es) linked")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(24)
                        .background(cardBackground)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSuccess = false
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func startOAuth() {
        isConnecting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isConnecting = false
            showLocationPicker = true
        }
    }
}

// MARK: - Location Picker View
struct LocationPickerView: View {
    let locations: [ExistingLocation]
    @Binding var selectedLocations: Set<String>
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var cardBackground: Color {
        colorScheme == .dark ? Color.black : Color(.systemBackground)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                        
                        Text("Select Locations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Choose which businesses you want to manage")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Location List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(locations) { location in
                                LocationSelectionCard(
                                    location: location,
                                    isSelected: selectedLocations.contains(location.id),
                                    onToggle: {
                                        if selectedLocations.contains(location.id) {
                                            selectedLocations.remove(location.id)
                                        } else {
                                            selectedLocations.insert(location.id)
                                        }
                                    },
                                    backgroundColor: cardBackground
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Confirm Button
                    Button(action: {
                        onConfirm()
                        dismiss()
                    }) {
                        HStack {
                            Text("Connect \(selectedLocations.count) Business(es)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedLocations.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(selectedLocations.isEmpty)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Location Selection Card
struct LocationSelectionCard: View {
    let location: ExistingLocation
    let isSelected: Bool
    let onToggle: () -> Void
    let backgroundColor: Color
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(location.status == "Verified" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: location.status == "Verified" ? "checkmark.circle.fill" : "clock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(location.status == "Verified" ? .green : .orange)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(location.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(location.status == "Verified" ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        Text(location.status)
                            .font(.caption2)
                            .foregroundColor(location.status == "Verified" ? .green : .orange)
                    }
                }
                
                Spacer()
                
                // Selection Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Existing Location Model
struct ExistingLocation: Identifiable {
    let id: String
    let name: String
    let address: String
    let status: String
}

// MARK: - Benefit Card Component
struct BenefitCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - How It Works Row Component
struct ConnectHowItWorksRow: View {
    let number: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
#Preview {
    ConnectExistingView()
}
