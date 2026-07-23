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
    @StateObject private var authManager = AuthManager()
    @StateObject private var iapManager = IAPManager.shared
    
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
            if !authManager.isAuthenticated {
                SignInView(onSignIn: {
                    // ✅ On sign in, just set authenticated
                    authManager.isAuthenticated = true
                    UserDefaults.standard.set(true, forKey: "isAuthenticated")
                })
                .environmentObject(authManager)
                .environmentObject(iapManager)
            } else {
                // ✅ GO STRAIGHT TO CONTENT VIEW
                ContentView()
                    .modelContainer(sharedModelContainer)
                    .environmentObject(authManager)
                    .environmentObject(iapManager)
            }
        }
    }
}
