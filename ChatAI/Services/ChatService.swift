//
//  ChatService.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import Foundation
import FirebaseFirestore
import Combine

class ChatService : ObservableObject {
    
    static let shared = ChatService()
    private let db = Firestore.firestore()
    
    @Published var messages : [Message] = []
    private var listener : ListenerRegistration?
    
    func listenMessages(roomID: String) {
        listener = db.collection("rooms")
            .document(roomID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else{ return }
                
                self.messages = documents.compactMap{ doc in
                    let data = doc.data()
                    guard let id = data["id"] as? String,
                          let text = data["text"] as? String,
                          let senderID = data["senderID"] as? String,
                          let senderName = data["senderNmae"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let sentimentString = data["sentiment"] as? String,
                          let sentiment = Message.Sentiment(rawValue: sentimentString) else {return nil}
                    
                    return Message(
                        id: id, text: text, senderID: senderID, senderName: senderName, timestamp: timestamp.dateValue(), sentiment: sentiment
                    )
                    
                }
                
                
            }
    }
    
    func sendMessage(_ message: Message, roomID: String) async throws{
        let data : [String: Any] = [
            "id": message.id,
            "text" : message.text,
            "senderID" : message.senderID,
            "senderName" : message.senderName,
            "timestamp"  : Timestamp(date: message.timestamp),
            "sentiment" : message.sentiment.rawValue
        ]
        
        try await db.collection("rooms")
            .document(roomID)
            .collection("messages")
            .document()
            .setData(data)
    }
    
    func stopListening(){
        listener?.remove()
    }
    
    
    
}
