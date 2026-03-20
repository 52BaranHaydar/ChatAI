//
//  LoginView.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(
                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                    
                    Text("ChatAI")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("AI destekli gerçek zamanlı sohbet")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Sign in with Apple
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = authService.prepareSignInWithApple()
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = nonce
                    } onCompletion: { result in
                        Task {
                            switch result {
                            case .success(let authorization):
                                do {
                                    try await authService.handleSignInWithApple(authorization)
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    LoginView()
        .onAppear {
            
        }
}
