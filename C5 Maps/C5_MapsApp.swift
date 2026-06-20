//
//  C5_MapsApp.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-06-08.
//

import SwiftUI
import SwiftData

@main
struct C5_MapsApp: App {
    @State private var isAuthenticated = false
    @State private var hasSubscription = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if !isAuthenticated {
                SignInView(
                    onSignIn: {
                        isAuthenticated = true
                    }
                )
            } else if !hasSubscription {
                UpgradePlanView(
                    onComplete: {
                        hasSubscription = true
                    }
                )
            } else {
                ContentView()
                    .modelContainer(sharedModelContainer)
            }
        }
    }
}
