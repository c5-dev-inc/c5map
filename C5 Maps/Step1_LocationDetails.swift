import SwiftUI

struct Step1_LocationDetails: View {
    @Environment(\.dismiss) var dismiss
    @Binding var displayName: String
    @Binding var primaryCategory: String
    @Binding var status: String
    @Binding var phoneNumber: String
    @Binding var website: String
    @Binding var country: String
    @Binding var email: String  // ✅ NEW
    var nextAction: () -> Void
    
    @FocusState private var focusedField: Field?
    @State private var customCategory: String = ""
    @State private var isCustomCategory: Bool = false
    
    enum Field {
        case displayName, phoneNumber, website, customCategory, email  // ✅ ADDED email
    }
    
    // Validation check - includes email
    private var isFormValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !primaryCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email)
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    let countries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria",
        "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan",
        "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon",
        "Canada", "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Costa Rica",
        "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt",
        "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland", "France", "Gabon",
        "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana",
        "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel",
        "Italy", "Ivory Coast", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan",
        "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar",
        "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia",
        "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal",
        "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan",
        "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania",
        "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal",
        "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea",
        "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan",
        "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu",
        "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela",
        "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    ]
    
    let categories = ["Software Development Service", "Coffee Shop", "Restaurant", "Retail", "Health & Beauty", "Professional Services", "Other"]
    let statusOptions = ["Open", "Closed", "Temporarily Closed"]
    
    // UserDefaults keys
    private let defaults = UserDefaults.standard
    private let displayNameKey = "location_displayName"
    private let primaryCategoryKey = "location_primaryCategory"
    private let statusKey = "location_status"
    private let phoneNumberKey = "location_phoneNumber"
    private let websiteKey = "location_website"
    private let countryKey = "location_country"
    private let emailKey = "location_email"  // ✅ NEW
    
    init(displayName: Binding<String>, primaryCategory: Binding<String>, status: Binding<String>, phoneNumber: Binding<String>, website: Binding<String>, country: Binding<String>, email: Binding<String>, nextAction: @escaping () -> Void) {
        self._displayName = displayName
        self._primaryCategory = primaryCategory
        self._status = status
        self._phoneNumber = phoneNumber
        self._website = website
        self._country = country
        self._email = email
        self.nextAction = nextAction
        
        // Load saved data
        let defaults = UserDefaults.standard
        if displayName.wrappedValue.isEmpty {
            displayName.wrappedValue = defaults.string(forKey: displayNameKey) ?? ""
        }
        if primaryCategory.wrappedValue.isEmpty {
            primaryCategory.wrappedValue = defaults.string(forKey: primaryCategoryKey) ?? ""
        }
        if status.wrappedValue.isEmpty {
            status.wrappedValue = defaults.string(forKey: statusKey) ?? "Open"
        }
        if phoneNumber.wrappedValue.isEmpty {
            phoneNumber.wrappedValue = defaults.string(forKey: phoneNumberKey) ?? ""
        }
        if website.wrappedValue.isEmpty {
            website.wrappedValue = defaults.string(forKey: websiteKey) ?? ""
        }
        if country.wrappedValue.isEmpty {
            country.wrappedValue = defaults.string(forKey: countryKey) ?? "United States"
        }
        if email.wrappedValue.isEmpty {
            email.wrappedValue = defaults.string(forKey: emailKey) ?? ""
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Icon
                VStack(spacing: 12) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Add a Location")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Add some details about a location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Country
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Country")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Picker("Country", selection: $country) {
                                ForEach(countries, id: \.self) { c in
                                    Text(c).tag(c)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: country) { _, newValue in
                                defaults.set(newValue, forKey: countryKey)
                            }
                        }
                        
                        Divider()
                        
                        // Display Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Display Name")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("Enter business name", text: $displayName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .focused($focusedField, equals: .displayName)
                                .onChange(of: displayName) { _, newValue in
                                    defaults.set(newValue, forKey: displayNameKey)
                                }
                        }
                        
                        // Primary Category
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Primary Category")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            if !isCustomCategory {
                                Picker("Category", selection: $primaryCategory) {
                                    ForEach(categories, id: \.self) { cat in
                                        Text(cat).tag(cat)
                                    }
                                    Text("Other").tag("Other")
                                }
                                .pickerStyle(.menu)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onChange(of: primaryCategory) { _, newValue in
                                    if newValue == "Other" {
                                        isCustomCategory = true
                                        primaryCategory = ""
                                    } else {
                                        defaults.set(newValue, forKey: primaryCategoryKey)
                                    }
                                }
                            }
                            
                            if isCustomCategory {
                                HStack {
                                    TextField("Enter custom category", text: $customCategory)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .focused($focusedField, equals: .customCategory)
                                        .onChange(of: customCategory) { _, newValue in
                                            primaryCategory = newValue
                                            defaults.set(newValue, forKey: primaryCategoryKey)
                                        }
                                    
                                    Button(action: {
                                        isCustomCategory = false
                                        customCategory = ""
                                        primaryCategory = categories.first ?? ""
                                        defaults.set(primaryCategory, forKey: primaryCategoryKey)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Text("The primary category describes the main business function. It appears on this location's place card and determines its icon on Maps.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Status
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Status")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Picker("Status", selection: $status) {
                                ForEach(statusOptions, id: \.self) { opt in
                                    Text(opt).tag(opt)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: status) { _, newValue in
                                defaults.set(newValue, forKey: statusKey)
                            }
                        }
                        
                        // Phone Number
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone Number")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("Canada (+1)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                TextField("Phone number", text: $phoneNumber)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                                    .focused($focusedField, equals: .phoneNumber)
                                    .onChange(of: phoneNumber) { _, newValue in
                                        defaults.set(newValue, forKey: phoneNumberKey)
                                    }
                            }
                        }
                        
                        // Email - ✅ NEW
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("business@example.com", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .focused($focusedField, equals: .email)
                                .onChange(of: email) { _, newValue in
                                    defaults.set(newValue, forKey: emailKey)
                                }
                            
                            Text("This email will be used for business communications and verification.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Website
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location Website (Optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("https://example.com", text: $website)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                                .focused($focusedField, equals: .website)
                                .onChange(of: website) { _, newValue in
                                    defaults.set(newValue, forKey: websiteKey)
                                }
                            
                            Text("The website will be displayed on the place card for this location.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {}) {
                                Text("Don't have a website?")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
                .onTapGesture {
                    focusedField = nil
                }
                
                // Next Button
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: nextAction) {
                            Text("Next")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(width: 80)
                                .padding(.vertical, 12)
                                .background(isFormValid ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(!isFormValid)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    Text("Step 1 of 4")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
                .background(Color(.systemBackground))
            }
            .background(Color(.systemGray6).ignoresSafeArea())
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
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var displayName = ""
        @State private var primaryCategory = ""
        @State private var status = "Open"
        @State private var phoneNumber = ""
        @State private var website = ""
        @State private var country = "United States"
        @State private var email = ""
        
        var body: some View {
            Step1_LocationDetails(
                displayName: $displayName,
                primaryCategory: $primaryCategory,
                status: $status,
                phoneNumber: $phoneNumber,
                website: $website,
                country: $country,
                email: $email,
                nextAction: {
                    print("Next tapped")
                }
            )
        }
    }
    return PreviewWrapper()
}
