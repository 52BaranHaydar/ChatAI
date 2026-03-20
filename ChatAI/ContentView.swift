//
//  ContentView.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authService = AuthService.shared
    
    var body: some View {
        if authService.isLoggedIn {
            ChatView()
        } else {
            LoginView()
        }
    }
}
