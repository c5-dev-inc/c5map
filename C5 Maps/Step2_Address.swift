// Step2_Address.swift
import SwiftUI
import MapKit

struct Step2_Address: View {
    @Environment(\.dismiss) var dismiss
    @Binding var country: String
    @Binding var street: String
    @Binding var unit: String
    @Binding var city: String
    @Binding var state: String
    @Binding var zipCode: String
    @Binding var displayName: String
    var backAction: () -> Void
    var nextAction: () -> Void
    
    @State private var customState: String = ""
    @State private var isCustomState: Bool = false
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var annotationTitle: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Validation check - silently enforces requirements
    private var isFormValid: Bool {
        !street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !zipCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // UserDefaults keys
    private let defaults = UserDefaults.standard
    private let streetKey = "address_street"
    private let unitKey = "address_unit"
    private let cityKey = "address_city"
    private let stateKey = "address_state"
    private let zipCodeKey = "address_zipCode"
    private let displayNameKey = "location_displayName"
    
    // State/Province options based on country
    var stateOptions: [String] {
        switch country {
        case "United States":
            return ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
        case "Canada":
            return ["Alberta", "British Columbia", "Manitoba", "New Brunswick", "Newfoundland and Labrador", "Nova Scotia", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Northwest Territories", "Nunavut", "Yukon"]
        default:
            return []
        }
    }
    
    init(country: Binding<String>, street: Binding<String>, unit: Binding<String>, city: Binding<String>, state: Binding<String>, zipCode: Binding<String>, displayName: Binding<String>, backAction: @escaping () -> Void, nextAction: @escaping () -> Void) {
        self._country = country
        self._street = street
        self._unit = unit
        self._city = city
        self._state = state
        self._zipCode = zipCode
        self._displayName = displayName
        self.backAction = backAction
        self.nextAction = nextAction
        
        // Load saved data
        let defaults = UserDefaults.standard
        if street.wrappedValue.isEmpty {
            street.wrappedValue = defaults.string(forKey: streetKey) ?? ""
        }
        if unit.wrappedValue.isEmpty {
            unit.wrappedValue = defaults.string(forKey: unitKey) ?? ""
        }
        if city.wrappedValue.isEmpty {
            city.wrappedValue = defaults.string(forKey: cityKey) ?? ""
        }
        if state.wrappedValue.isEmpty {
            state.wrappedValue = defaults.string(forKey: stateKey) ?? ""
        }
        if zipCode.wrappedValue.isEmpty {
            zipCode.wrappedValue = defaults.string(forKey: zipCodeKey) ?? ""
        }
        if displayName.wrappedValue.isEmpty {
            displayName.wrappedValue = defaults.string(forKey: displayNameKey) ?? ""
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Icon
                VStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Enter this location's address")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Display Name (non-editable, showing from Step 1)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location Name")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(displayName.isEmpty ? "No name set" : displayName)
                                .font(.body)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .foregroundColor(displayName.isEmpty ? .gray : .primary)
                        }
                        
                        // Street
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Street")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("Street address", text: $street)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .focused($isTextFieldFocused)
                                .onChange(of: street) { _, newValue in
                                    defaults.set(newValue, forKey: streetKey)
                                    updateMapAnnotation()
                                }
                        }
                        
                        // Unit/Suite
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Unit, Suite, etc. (Optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("Unit or suite number", text: $unit)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .focused($isTextFieldFocused)
                                .onChange(of: unit) { _, newValue in
                                    defaults.set(newValue, forKey: unitKey)
                                }
                        }
                        
                        // City
                        VStack(alignment: .leading, spacing: 6) {
                            Text("City")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("City", text: $city)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .focused($isTextFieldFocused)
                                .onChange(of: city) { _, newValue in
                                    defaults.set(newValue, forKey: cityKey)
                                    updateMapAnnotation()
                                }
                        }
                        
                        // State/Province and Postal Code
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("State/Province")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                if stateOptions.isEmpty {
                                    TextField("Enter state/province", text: $state)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.words)
                                        .focused($isTextFieldFocused)
                                        .onChange(of: state) { _, newValue in
                                            defaults.set(newValue, forKey: stateKey)
                                            updateMapAnnotation()
                                        }
                                } else {
                                    Picker("State/Province", selection: $state) {
                                        ForEach(stateOptions, id: \.self) { s in
                                            Text(s).tag(s)
                                        }
                                        Text("Other").tag("Other")
                                    }
                                    .pickerStyle(.menu)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .onChange(of: state) { _, newValue in
                                        if newValue == "Other" {
                                            isCustomState = true
                                            state = ""
                                        } else {
                                            isCustomState = false
                                            defaults.set(newValue, forKey: stateKey)
                                            updateMapAnnotation()
                                        }
                                    }
                                    
                                    if isCustomState {
                                        TextField("Enter state/province", text: $state)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.words)
                                            .focused($isTextFieldFocused)
                                            .padding(.top, 4)
                                            .onChange(of: state) { _, newValue in
                                                defaults.set(newValue, forKey: stateKey)
                                                updateMapAnnotation()
                                            }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Postal Code")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField("Postal code", text: $zipCode)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.default)
                                    .autocapitalization(.allCharacters)
                                    .focused($isTextFieldFocused)
                                    .onChange(of: zipCode) { _, newValue in
                                        defaults.set(newValue, forKey: zipCodeKey)
                                        updateMapAnnotation()
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Map with annotation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location Preview")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Map(coordinateRegion: $mapRegion, annotationItems: coordinate != nil ? [LocationAnnotation(coordinate: coordinate!)] : []) { item in
                                MapAnnotation(coordinate: item.coordinate) {
                                    VStack(spacing: 2) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.red)
                                        
                                        if !displayName.isEmpty {
                                            Text(displayName)
                                                .font(.system(size: 11, weight: .semibold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.white)
                                                .cornerRadius(6)
                                                .shadow(radius: 2)
                                        }
                                    }
                                }
                            }
                            .frame(height: 250)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            
                            Text("The location will appear on the map with the display name from Step 1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
                .onTapGesture {
                    isTextFieldFocused = false
                }
                
                // Navigation Buttons
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal)
                    
                    HStack {
                        Button(action: backAction) {
                            Text("Back")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(width: 80)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                        
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
                    
                    Text("Step 2 of 4")
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
            .onAppear {
                updateMapAnnotation()
            }
            .onChange(of: country) { _, _ in
                updateMapAnnotation()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func updateMapAnnotation() {
        // Get the full address string
        let addressComponents = [
            street,
            unit,
            city,
            state,
            zipCode,
            country
        ].filter { !$0.isEmpty }
        
        let fullAddress = addressComponents.joined(separator: ", ")
        
        guard !fullAddress.isEmpty else { return }
        
        // Geocode the address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(fullAddress) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first,
                   let location = placemark.location {
                    coordinate = location.coordinate
                    mapRegion.center = location.coordinate
                    annotationTitle = displayName
                }
            }
        }
    }
}

// MARK: - Location Annotation
struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var country = "Canada"
        @State private var street = ""
        @State private var unit = ""
        @State private var city = ""
        @State private var state = ""
        @State private var zipCode = ""
        @State private var displayName = "My Business Name"
        
        var body: some View {
            Step2_Address(
                country: $country,
                street: $street,
                unit: $unit,
                city: $city,
                state: $state,
                zipCode: $zipCode,
                displayName: $displayName,
                backAction: {},
                nextAction: {}
            )
        }
    }
    return PreviewWrapper()
}
