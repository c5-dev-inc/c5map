import SwiftUI

struct ConnectBusinessView: View {
    @Environment(\.dismiss) var dismiss
    @State private var businessName = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var phone = ""
    @State private var category = "Restaurant"
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    let categories = ["Restaurant", "Retail", "Plumbing", "Electrician", "Salon", "Fitness", "Healthcare", "Other"]
    
    var isFormValid: Bool {
        !businessName.isEmpty && !address.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty && !phone.isEmpty
    }
    
    // Dynamic background color based on color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var textFieldBackground: Color {
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
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.blue)
                            
                            Text("Register New Business")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Add your business to Apple Maps for the first time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Form Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Business Information")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                // Business Name
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Business Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("e.g., Joe's Pizza", text: $businessName)
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }
                                
                                // Street Address
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Street Address")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("123 Main St", text: $address)
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }
                                
                                // City, State, ZIP
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("City")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("Austin", text: $city)
                                            .padding()
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("State")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("TX", text: $state)
                                            .padding()
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("ZIP")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("78701", text: $zip)
                                            .keyboardType(.numberPad)
                                            .padding()
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                    }
                                }
                                
                                // Phone Number
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Phone Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("(512) 555-0123", text: $phone)
                                        .keyboardType(.phonePad)
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }
                                
                                // Category
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Business Category")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Category", selection: $category) {
                                        ForEach(categories, id: \.self) { cat in
                                            Text(cat).tag(cat)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding()
                                    .background(textFieldBackground)
                                    .cornerRadius(12)
                                    .tint(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - What Happens Next
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What happens next?")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                HowItWorksRow(number: "1", text: "Apple verifies your business", color: .blue)
                                Divider().padding(.leading, 48)
                                HowItWorksRow(number: "2", text: "Verification via phone or postcard", color: .blue)
                                Divider().padding(.leading, 48)
                                HowItWorksRow(number: "3", text: "Usually takes 3-5 business days", color: .blue)
                                Divider().padding(.leading, 48)
                                HowItWorksRow(number: "4", text: "We'll notify you when verified", color: .blue)
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Submit Button
                        Button(action: submitRegistration) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Submit to Apple")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(!isFormValid || isSubmitting)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // MARK: - Footer Note
                        VStack(spacing: 8) {
                            Text("Apple will verify your business information.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("You'll receive a verification call or postcard within 3-5 business days.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
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
            .overlay {
                if showSuccess {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            Text("Submitted Successfully!")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Apple will verify your business")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
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
    
    private func submitRegistration() {
        isSubmitting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccess = true
        }
    }
}

// MARK: - How It Works Row Component
struct HowItWorksRow: View {
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

#Preview {
    ConnectBusinessView()
}


