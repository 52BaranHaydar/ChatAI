//
//  ChatView.swift
//  ChatAI
//
//  Created by Baran on 20.03.2026.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @ObservedObject var authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Mesaj listesi
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isMyMessage: viewModel.isMyMessage(message)
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Mesaj giriş alanı
                HStack(spacing: 12) {
                    TextField("Mesaj yaz...", text: $viewModel.messageText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task { await viewModel.sendMessage() }
                        }
                    
                    Button {
                        Task { await viewModel.sendMessage() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(viewModel.messageText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.messageText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("ChatAI 💬")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Çıkış") {
                        authService.signOut()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}

// Mesaj balonu
struct MessageBubble: View {
    let message: Message
    let isMyMessage: Bool
    
    var body: some View {
        HStack {
            if isMyMessage { Spacer() }
            
            VStack(alignment: isMyMessage ? .trailing : .leading, spacing: 4) {
                if !isMyMessage {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    if isMyMessage {
                        Text(message.sentiment.rawValue)
                    }
                    
                    Text(message.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isMyMessage ? Color.blue : Color(.systemGray5))
                        .foregroundStyle(isMyMessage ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if !isMyMessage {
                        Text(message.sentiment.rawValue)
                    }
                }
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !isMyMessage { Spacer() }
        }
    }
}

#Preview {
    ChatView()
}
