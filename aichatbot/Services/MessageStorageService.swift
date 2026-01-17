//
//  MessageStorageService.swift
//  aichatbot
//
//  Created for AI Chatbot App - Message Persistence
//

import Foundation

// MARK: - Message Storage Service
class MessageStorageService {
    static let shared = MessageStorageService()
    
    private func messagesKey(for conversationId: UUID, userId: UUID) -> String {
        return "messages_\(userId.uuidString)_\(conversationId.uuidString)"
    }
    
    private init() {}
    
    // MARK: - Save Messages
    func saveMessages(_ messages: [ChatMessage], conversationId: UUID, userId: UUID) {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: messagesKey(for: conversationId, userId: userId))
            print("✅ Saved \(messages.count) messages for conversation \(conversationId)")
        }
    }
    
    // MARK: - Load Messages
    func loadMessages(conversationId: UUID, userId: UUID) -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: messagesKey(for: conversationId, userId: userId)),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            print("📭 No saved messages for conversation \(conversationId)")
            return []
        }
        
        print("✅ Loaded \(messages.count) messages for conversation \(conversationId)")
        return messages
    }
    
    // MARK: - Add Message
    func addMessage(_ message: ChatMessage, conversationId: UUID, userId: UUID) {
        var messages = loadMessages(conversationId: conversationId, userId: userId)
        messages.append(message)
        saveMessages(messages, conversationId: conversationId, userId: userId)
    }
    
    // MARK: - Clear Messages
    func clearMessages(conversationId: UUID, userId: UUID) {
        UserDefaults.standard.removeObject(forKey: messagesKey(for: conversationId, userId: userId))
    }
    
    // MARK: - Get Recent Messages (for AI context, limit to last N messages)
    func getRecentMessages(conversationId: UUID, userId: UUID, limit: Int = 10) -> [ChatMessage] {
        let allMessages = loadMessages(conversationId: conversationId, userId: userId)
        return Array(allMessages.suffix(limit))
    }
}
