import SwiftUI

// MARK: - Step Indicator Component
struct StepIndicator: View {
    let step: Int
    let title: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.blue : Color(.systemGray4))
                    .frame(width: 32, height: 32)
                
                Text("\(step)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? .white : .secondary)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(isActive ? .blue : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Create Campaign View
struct CreateCampaignView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isInputFocused: Bool
    
    // Campaign Details
    @State private var campaignName = ""
    @State private var dailyBudget = ""
    @State private var selectedLocationIndex = 0
    
    // Keywords
    @State private var keywordsText = ""
    @State private var keywordList: [String] = []
    
    // Ad Creative
    @State private var headline = ""
    @State private var description = ""
    @State private var selectedCallToAction = "Order Now"
    
    // Targeting
    @State private var radius = 5
    @State private var selectedSchedule = "Always"
    
    // UI State
    @State private var currentStep = 1
    @State private var isCreating = false
    
    let callToActionOptions = ["Order Now", "Call Today", "Book Appointment", "Get Directions", "Learn More"]
    let scheduleOptions = ["Always", "Business Hours", "Custom"]
    
    // Mock locations (replace with actual connected businesses)
    let mockLocations = ["Joe's Pizza - Austin", "Sushi Master - Austin", "Coffee House - Austin"]
    
    var textFieldBackground: Color {
        colorScheme == .dark ? Color.black : Color(.systemBackground)
    }
    
    var isStep1Valid: Bool {
        !campaignName.isEmpty && !dailyBudget.isEmpty && Double(dailyBudget) ?? 0 > 0
    }
    
    var isStep2Valid: Bool {
        !keywordList.isEmpty
    }
    
    var isStep3Valid: Bool {
        !headline.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.blue)
                            
                            Text("Create Campaign")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Set up your Apple Maps ad campaign")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Step Indicator
                        HStack(spacing: 8) {
                            StepIndicator(step: 1, title: "Details", isActive: currentStep == 1)
                            StepIndicator(step: 2, title: "Keywords", isActive: currentStep == 2)
                            StepIndicator(step: 3, title: "Creative", isActive: currentStep == 3)
                        }
                        .padding(.horizontal, 16)
                        
                        // Step 1: Campaign Details
                        if currentStep == 1 {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Campaign Details")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 4)
                                
                                VStack(spacing: 16) {
                                    // Campaign Name
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Campaign Name")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("e.g., Summer Sale 2026", text: $campaignName)
                                            .padding()
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                            .focused($isInputFocused)
                                    }
                                    
                                    // Business Location
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Business Location")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Picker("Select Location", selection: $selectedLocationIndex) {
                                            ForEach(0..<mockLocations.count, id: \.self) { index in
                                                Text(mockLocations[index]).tag(index)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                    
                                    // Daily Budget
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Daily Budget")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            Text("$")
                                                .font(.title3)
                                                .foregroundColor(.secondary)
                                            TextField("10.00", text: $dailyBudget)
                                                .keyboardType(.decimalPad)
                                                .foregroundColor(.primary)
                                                .focused($isInputFocused)
                                        }
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                    
                                    // Targeting Radius
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Targeting Radius")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            Slider(value: Binding(
                                                get: { Double(radius) },
                                                set: { radius = Int($0) }
                                            ), in: 1...25, step: 1)
                                            Text("\(radius) miles")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                                .frame(width: 60)
                                        }
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                    
                                    // Schedule
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Schedule")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Picker("Schedule", selection: $selectedSchedule) {
                                            ForEach(scheduleOptions, id: \.self) { option in
                                                Text(option).tag(option)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Step 2: Keywords
                        if currentStep == 2 {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Keywords")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 4)
                                
                                VStack(spacing: 16) {
                                    // Keyword Input
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Add Keywords")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            TextField("e.g., pizza near me", text: $keywordsText)
                                                .autocapitalization(.none)
                                                .foregroundColor(.primary)
                                                .focused($isInputFocused)
                                            Button(action: addKeyword) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                            }
                                            .disabled(keywordsText.isEmpty)
                                        }
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                    
                                    // Keyword Chips
                                    if !keywordList.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Your Keywords")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            FlowLayout(spacing: 8) {
                                                ForEach(keywordList, id: \.self) { keyword in
                                                    HStack(spacing: 4) {
                                                        Text(keyword)
                                                            .font(.caption)
                                                        Button(action: {
                                                            removeKeyword(keyword)
                                                        }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.caption)
                                                                .foregroundColor(.gray)
                                                        }
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(20)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                    
                                    // AI Suggestion Button
                                    Button(action: {
                                        // Open AI Assistant for suggestions
                                    }) {
                                        HStack {
                                            Image(systemName: "sparkles")
                                            Text("Get AI Keyword Suggestions")
                                                .font(.subheadline)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Step 3: Ad Creative
                        if currentStep == 3 {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Ad Creative")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 4)
                                
                                VStack(spacing: 16) {
                                    // Headline
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Headline")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("e.g., Best Pizza in Town!", text: $headline)
                                            .padding()
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                            .focused($isInputFocused)
                                        Text("\(headline.count)/30 characters")
                                            .font(.caption2)
                                            .foregroundColor(headline.count > 30 ? .red : .secondary)
                                    }
                                    
                                    // Description
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Description (Optional)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("e.g., 20% off first order. Fast delivery.", text: $description)
                                            .padding()
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .foregroundColor(.primary)
                                            .focused($isInputFocused)
                                    }
                                    
                                    // Call to Action
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Call to Action")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Picker("CTA", selection: $selectedCallToAction) {
                                            ForEach(callToActionOptions, id: \.self) { option in
                                                Text(option).tag(option)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .padding()
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                    
                                    // Preview
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Preview")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(headline.isEmpty ? "Your Headline" : headline)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(description.isEmpty ? "Your description here" : description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(selectedCallToAction)
                                                .font(.caption2)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 4)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Navigation Buttons
                        HStack(spacing: 12) {
                            if currentStep > 1 {
                                Button(action: {
                                    withAnimation {
                                        currentStep -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                withAnimation {
                                    if currentStep < 3 {
                                        currentStep += 1
                                    } else {
                                        createCampaign()
                                    }
                                }
                            }) {
                                Text(currentStep == 3 ? "Create Campaign" : "Next")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(currentStep == 3 ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(currentStep == 3 ? .white : .primary)
                                    .cornerRadius(12)
                            }
                            .disabled(!isCurrentStepValid)                        }
                        .padding(.horizontal, 16)
                        
                        .padding(.bottom, 20)
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    isInputFocused = false
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
                if isCreating {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Creating Campaign...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }
            }
        }
    }
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 1:
            return isStep1Valid
        case 2:
            return isStep2Valid
        case 3:
            return isStep3Valid
        default:
            return false
        }
    }
    
    private func addKeyword() {
        let trimmed = keywordsText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !keywordList.contains(trimmed) else { return }
        keywordList.append(trimmed)
        keywordsText = ""
    }
    
    private func removeKeyword(_ keyword: String) {
        keywordList.removeAll { $0 == keyword }
    }
    
    private func createCampaign() {
        isCreating = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCreating = false
            dismiss()
        }
    }
}

// MARK: - Flow Layout for Keyword Chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxWidth = max(maxWidth, currentX - spacing)
            }
            
            size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview
#Preview {
    CreateCampaignView()
}
