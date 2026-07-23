//
//  Config.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-10.
//

import Foundation

enum Config {
    static let supabaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not found in Info.plist")
        }
        return url
    }()
    
    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist")
        }
        return key
    }()
    
    static let stripeOnboardFunction: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "STRIPE_ONBOARD_FUNCTION") as? String,
              let url = URL(string: urlString) else {
            fatalError("STRIPE_ONBOARD_FUNCTION not found in Info.plist")
        }
        return url
    }()
    
    static let stripePublishableKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "STRIPE_PUBLISHABLE_KEY") as? String else {
            fatalError("STRIPE_PUBLISHABLE_KEY not found in Info.plist")
        }
        return key
    }()
}
