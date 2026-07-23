import SwiftUI

struct BusinessView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAddLocation = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    
                    // Header with Building Icon
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                        
                        Text("Your Locations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Add your business to Apple Maps today and start getting discovered by nearby customers.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 40)
                    
                    // Add Location Button
                    Button(action: {
                        showingAddLocation = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Add Your Location")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    
                    // Why Add Section with Icons
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Why add your location?")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            WhyRow(
                                icon: "iphone.and.arrow.forward",
                                title: "Get Found",
                                description: "Customers search 'near me' on Apple Maps every day."
                            )
                            WhyRow(
                                icon: "megaphone.fill",
                                title: "Run Ads",
                                description: "Promote your business to nearby customers."
                            )
                            WhyRow(
                                icon: "chart.bar.xaxis",
                                title: "Track Performance",
                                description: "See how customers find and interact with you."
                            )
                            WhyRow(
                                icon: "photo.fill",
                                title: "Add Photos",
                                description: "Showcase your business with high-quality images."
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddLocation) {
            NavigationStack {
                AddLocationFlowView()
                    .environmentObject(authManager)
            }
        }
    }
}

// MARK: - Why Row Component
struct WhyRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Location Flow View
struct AddLocationFlowView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var currentStep = 0
    @State private var showSuccess = false
    
    @State private var displayName = ""
    @State private var locationName = ""
    @State private var primaryCategory = ""
    @State private var status = "Open"
    @State private var country = "United States"
    @State private var phoneNumber = ""
    @State private var website = ""
    @State private var email = ""  // ✅ NEW
    @State private var street = ""
    @State private var unit = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var hours: [(String, String)] = []
    @State private var brandWebsite = ""
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    ForEach(0..<4) { step in
                        Circle()
                            .fill(step <= currentStep ? Color.blue : Color(.systemGray4))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                Text("Step \(currentStep + 1) of 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 12)
                
                Group {
                    switch currentStep {
                    case 0:
                        Step1_LocationDetails(
                            displayName: $displayName,
                            primaryCategory: $primaryCategory,
                            status: $status,
                            phoneNumber: $phoneNumber,
                            website: $website,
                            country: $country,
                            email: $email,  // ✅ NEW
                            nextAction: {
                                withAnimation { currentStep += 1 }
                            }
                        )
                    case 1:
                        Step2_Address(
                            country: $country,
                            street: $street,
                            unit: $unit,
                            city: $city,
                            state: $state,
                            zipCode: $zipCode,
                            displayName: $displayName,
                            backAction: {
                                withAnimation { currentStep -= 1 }
                            },
                            nextAction: {
                                withAnimation { currentStep += 1 }
                            }
                        )
                    case 2:
                        Step3_Hours(
                            backAction: {
                                withAnimation { currentStep -= 1 }
                            },
                            nextAction: {
                                withAnimation { currentStep += 1 }
                            }
                        )
                    case 3:
                        Step4_Brand(
                            backAction: {
                                withAnimation { currentStep -= 1 }
                            },
                            submitAction: { submitLocation() },
                            displayName: displayName,
                            primaryCategory: primaryCategory,
                            country: country,
                            phoneNumber: phoneNumber,
                            street: street,
                            city: city,
                            state: state,
                            hours: hours,
                            website: website
                        )
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .animation(.easeInOut, value: currentStep)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSuccess) {
            Step5_Done(
                locationName: locationName.isEmpty ? displayName : locationName,
                address: "\(street), \(city), \(state) \(zipCode), \(country)",
                displayName: displayName,
                primaryCategory: primaryCategory,
                city: city,
                state: state,
                country: country,
                phoneNumber: phoneNumber,
                email: email,  // ✅ NEW
                street: street,
                unit: unit,
                zipCode: zipCode,
                website: website,
                brandWebsite: brandWebsite,
                hours: hours,
                onDismiss: {
                    showSuccess = false
                    dismiss()
                }
            )
            .environmentObject(authManager)
        }
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func submitLocation() {
        showSuccess = true
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BusinessView()
            .environmentObject(AuthManager())
    }
}
