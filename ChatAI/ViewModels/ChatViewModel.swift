//
//  ChatViewModel.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    
    @Published var messageText = ""
    @Published var isLoading = false
    
    let chatService = ChatService.shared
    let authService = AuthService.shared
    let roomID = "general"
    
    var messages: [Message] {
        chatService.messages
    }
    
    init() {
        chatService.listenMessages(roomID: roomID)
    }
    
    deinit {
        chatService.stopListening()
    }
    
    // Mesaj gönder
    func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let text = messageText
        await MainActor.run { messageText = "" }
        
        let sentiment = analyzeSentiment(text)
        
        // Test için geçici kullanıcı
        let userID = authService.currentUser?.id ?? "test-user"
        let userName = authService.currentUser?.name ?? "Test Kullanıcı"
        
        let message = Message(
            text: text,
            senderID: userID,
            senderName: userName,
            sentiment: sentiment
        )
        
        do {
            try await chatService.sendMessage(message, roomID: roomID)
        } catch {
            print("Mesaj gönderme hatası: \(error)")
        }
    }
    
    // Basit duygu analizi
    func analyzeSentiment(_ text: String) -> Message.Sentiment {
        let positiveWords = ["güzel", "harika", "mükemmel", "süper", "iyi", "seviyorum",
                            "great", "awesome", "love", "good", "nice", "happy"]
        let negativeWords = ["kötü", "berbat", "sinir", "nefret", "üzgün", "kızgın",
                            "bad", "hate", "angry", "sad", "terrible", "awful"]
        
        let lowercased = text.lowercased()
        
        let positiveCount = positiveWords.filter { lowercased.contains($0) }.count
        let negativeCount = negativeWords.filter { lowercased.contains($0) }.count
        
        if positiveCount > negativeCount { return .positive }
        if negativeCount > positiveCount { return .negative }
        return .neutral
    }
    
    // Mesajın bana ait olup olmadığı
    func isMyMessage(_ message: Message) -> Bool {
        message.senderID == authService.currentUser?.id
    }
}
