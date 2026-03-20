//
//  AuthService.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import Combine

class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: ChatUser?
    @Published var isLoggedIn = false
    
    private var currentNonce: String?
    
    init() {
        checkAuthState()
    }
    
    // Giriş durumunu kontrol et
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.currentUser = ChatUser(
                id: user.uid,
                name: user.displayName ?? "Kullanıcı",
                email: user.email ?? ""
            )
            self.isLoggedIn = true
        }
    }
    
    // Sign in with Apple - Nonce oluştur
    func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func prepareSignInWithApple() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
    
    // Sign in with Apple - Tamamla
    func handleSignInWithApple(_ authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "AuthError", code: -1)
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        let result = try await Auth.auth().signIn(with: credential)
        let user = result.user
        
        await MainActor.run {
            self.currentUser = ChatUser(
                id: user.uid,
                name: user.displayName ?? appleIDCredential.fullName?.givenName ?? "Kullanıcı",
                email: user.email ?? ""
            )
            self.isLoggedIn = true
        }
    }
    
    // Çıkış yap
    func signOut() {
        try? Auth.auth().signOut()
        currentUser = nil
        isLoggedIn = false
    }
}
