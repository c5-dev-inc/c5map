//
//  MessagesView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-14.
//

import SwiftUI

// MARK: - Messages Sheet
struct MessagesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Messages")
                    .font(.largeTitle)
                    .padding()
                
                Text("Messages inbox coming soon")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
