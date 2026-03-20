//
//  ChatAIApp.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import SwiftUI
import FirebaseCore

@main
struct ChatAIApp: App {
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
