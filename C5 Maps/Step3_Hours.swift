//
//  Step3_Hours.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-08.
//

import SwiftUI

struct Step3_Hours: View {
    var backAction: () -> Void
    var nextAction: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var selectedDays: Set<String> = []
    @State private var opensAt = Date()
    @State private var closesAt = Date()
    
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    // UserDefaults keys
    private let defaults = UserDefaults.standard
    private let selectedDaysKey = "hours_selectedDays"
    private let opensAtKey = "hours_opensAt"
    private let closesAtKey = "hours_closesAt"
    
    init(backAction: @escaping () -> Void, nextAction: @escaping () -> Void) {
        self.backAction = backAction
        self.nextAction = nextAction
        
        // Load saved data
        let defaults = UserDefaults.standard
        
        // Load selected days
        if let savedDays = defaults.array(forKey: selectedDaysKey) as? [String] {
            _selectedDays = State(initialValue: Set(savedDays))
        } else {
            // Default: Weekdays
            _selectedDays = State(initialValue: ["M", "T", "W", "T", "F"])
        }
        
        // Load opens time
        if let opensData = defaults.data(forKey: opensAtKey),
           let savedOpens = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDate.self, from: opensData) as Date? {
            _opensAt = State(initialValue: savedOpens)
        } else {
            // Default: 9:00 AM
            let defaultOpens = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            _opensAt = State(initialValue: defaultOpens)
        }
        
        // Load closes time
        if let closesData = defaults.data(forKey: closesAtKey),
           let savedCloses = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDate.self, from: closesData) as Date? {
            _closesAt = State(initialValue: savedCloses)
        } else {
            // Default: 5:00 PM
            let defaultCloses = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
            _closesAt = State(initialValue: defaultCloses)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Icon
            VStack(spacing: 12) {
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Add your hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Provide your hours for a typical week. You can add holiday or other special hours later.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Day Selection
            HStack(spacing: 8) {
                ForEach(days, id: \.self) { day in
                    Button(action: {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                        saveSelectedDays()
                    }) {
                        Text(day)
                            .font(.headline)
                            .fontWeight(.medium)
                            .frame(width: 36, height: 36)
                            .background(selectedDays.contains(day) ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Time Selection
            VStack(spacing: 16) {
                HStack {
                    Text("Opens")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .leading)
                    
                    DatePicker("", selection: $opensAt, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                        .onChange(of: opensAt) { _, newValue in
                            saveOpensAt(newValue)
                        }
                    
                    Spacer()
                }
                
                HStack {
                    Text("Closes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .leading)
                    
                    DatePicker("", selection: $closesAt, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                        .onChange(of: closesAt) { _, newValue in
                            saveClosesAt(newValue)
                        }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Navigation Buttons
            HStack {
                Button(action: backAction) {
                    Text("Back")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }
                
                Button(action: nextAction) {
                    Text("Next")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Step Indicator
            Text("Step 3 of 4")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 12)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
    
    // MARK: - Save Functions
    private func saveSelectedDays() {
        defaults.set(Array(selectedDays), forKey: selectedDaysKey)
    }
    
    private func saveOpensAt(_ date: Date) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: date as NSDate, requiringSecureCoding: false) {
            defaults.set(data, forKey: opensAtKey)
        }
    }
    
    private func saveClosesAt(_ date: Date) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: date as NSDate, requiringSecureCoding: false) {
            defaults.set(data, forKey: closesAtKey)
        }
    }
}

// MARK: - Preview
#Preview {
    Step3_Hours(
        backAction: {},
        nextAction: {}
    )
}
