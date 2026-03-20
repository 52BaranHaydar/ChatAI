//
//  Message.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable{
    let id : String
    let text : String
    let senderID: String
    let senderName: String
    let timestamp: Date
    var sentiment: Sentiment
    
    enum Sentiment: String, Codable{
        case positive = "😊"
        case negative = "😔"
        case neutral = "😐"
    }
    
    
    init(
        id: String = UUID().uuidString,
        text : String,
        senderID : String,
        senderName: String,
        timestamp: Date = Date(),
        sentiment: Sentiment = .neutral
    ) {
        self.id = id
        self.text = text
        self.senderID = senderID
        self.senderName = senderName
        self.timestamp = timestamp
        self.sentiment = sentiment
    }
    
}

struct ChatUser: Identifiable, Codable{
    let id :String
    var name  :String
    var email  :String
    
    init(id:String, name: String, email : String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    
}


