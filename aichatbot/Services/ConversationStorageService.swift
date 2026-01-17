//
//  ConversationStorageService.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

// MARK: - Conversation Storage Service
class ConversationStorageService {
    static let shared = ConversationStorageService()
    
    private func conversationsKey(for userId: UUID) -> String {
        return "saved_conversations_\(userId.uuidString)"
    }
    
    private init() {}
    
    // MARK: - Save Conversations List (Associated with User)
    func saveConversations(_ conversations: [Conversation], userId: UUID) {
        // Convert Conversation to storable data
        let conversationsData = conversations.map { conversation in
            StoredConversation(
                id: conversation.id,
                name: conversation.name,
                avatar: conversation.avatar,
                backgroundImage: conversation.backgroundImage,
                chatDescription: conversation.chatDescription,
                greetingMessage: conversation.greetingMessage,
                lastMessage: conversation.lastMessage,
                lastMessageTime: conversation.lastMessageTime,
                typeString: conversation.typeString,
                characterData: conversation.characterData,
                storyData: conversation.storyData,
                privateCharacterData: conversation.privateCharacterData
            )
        }
        
        if let encoded = try? JSONEncoder().encode(conversationsData) {
            UserDefaults.standard.set(encoded, forKey: conversationsKey(for: userId))
            print("✅ Saved \(conversations.count) conversations (userId: \(userId))")
        }
    }
    
    // MARK: - Load Conversations List (Associated with User)
    func loadConversations(userId: UUID) -> [Conversation] {
        guard let data = UserDefaults.standard.data(forKey: conversationsKey(for: userId)),
              let storedConversations = try? JSONDecoder().decode([StoredConversation].self, from: data) else {
            print("📭 No saved conversations (userId: \(userId))")
            return []
        }
        
        // Convert stored data back to Conversation
        let conversations = storedConversations.compactMap { stored -> Conversation? in
            switch stored.typeString {
            case "character":
                guard let characterData = stored.characterData,
                      let character = try? JSONDecoder().decode(Character.self, from: characterData) else {
                    return nil
                }
                return Conversation(
                    id: stored.id,
                    name: stored.name,
                    avatar: stored.avatar,
                    backgroundImage: stored.backgroundImage,
                    chatDescription: stored.chatDescription,
                    greetingMessage: stored.greetingMessage,
                    lastMessage: stored.lastMessage,
                    lastMessageTime: stored.lastMessageTime,
                    type: .character(character)
                )
                
            case "story":
                guard let storyData = stored.storyData,
                      let story = try? JSONDecoder().decode(Story.self, from: storyData) else {
                    return nil
                }
                return Conversation(
                    id: stored.id,
                    name: stored.name,
                    avatar: stored.avatar,
                    backgroundImage: stored.backgroundImage,
                    chatDescription: stored.chatDescription,
                    greetingMessage: stored.greetingMessage,
                    lastMessage: stored.lastMessage,
                    lastMessageTime: stored.lastMessageTime,
                    type: .story(story)
                )
                
            case "privateCharacter":
                guard let privateCharacterData = stored.privateCharacterData,
                      let privateCharacter = try? JSONDecoder().decode(PrivateCharacter.self, from: privateCharacterData) else {
                    return nil
                }
                return Conversation(
                    id: stored.id,
                    name: stored.name,
                    avatar: stored.avatar,
                    backgroundImage: stored.backgroundImage,
                    chatDescription: stored.chatDescription,
                    greetingMessage: stored.greetingMessage,
                    lastMessage: stored.lastMessage,
                    lastMessageTime: stored.lastMessageTime,
                    type: .privateCharacter(privateCharacter)
                )
                
            default:
                return nil
            }
        }
        
        print("✅ Loaded \(conversations.count) conversations")
        return conversations
    }
    
    // MARK: - Add or Update Conversation (Associated with User)
    func addOrUpdateConversation(_ conversation: Conversation, userId: UUID) {
        var conversations = loadConversations(userId: userId)
        
        // Check if conversation with same ID already exists
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            // Update existing conversation
            conversations[index] = conversation
        } else {
            // Add new conversation
            conversations.insert(conversation, at: 0) // Add to the front
        }
        
        // Sort by time (newest first)
        conversations.sort { $0.lastMessageTime > $1.lastMessageTime }
        
        saveConversations(conversations, userId: userId)
    }
    
    // MARK: - Update Conversation Last Message (Associated with User)
    func updateLastMessage(conversationId: UUID, message: String, userId: UUID) {
        var conversations = loadConversations(userId: userId)
        
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            let oldConversation = conversations[index]
            let updatedConversation = Conversation(
                id: oldConversation.id,
                name: oldConversation.name,
                avatar: oldConversation.avatar,
                backgroundImage: oldConversation.backgroundImage,
                chatDescription: oldConversation.chatDescription,
                greetingMessage: oldConversation.greetingMessage,
                lastMessage: message,
                lastMessageTime: Date(),
                type: oldConversation.type
            )
            conversations[index] = updatedConversation
            conversations.sort { $0.lastMessageTime > $1.lastMessageTime }
            saveConversations(conversations, userId: userId)
        }
    }
}

// MARK: - Storable Conversation Data Model
private struct StoredConversation: Codable {
    let id: UUID
    let name: String
    let avatar: String
    let backgroundImage: String?
    let chatDescription: String?
    let greetingMessage: String?
    let lastMessage: String
    let lastMessageTime: Date
    let typeString: String
    let characterData: Data?
    let storyData: Data?
    let privateCharacterData: Data?
}

// MARK: - Conversation Extension
extension Conversation {
    var typeString: String {
        switch type {
        case .character: return "character"
        case .story: return "story"
        case .privateCharacter: return "privateCharacter"
        }
    }
    
    var characterData: Data? {
        if case .character(let character) = type {
            return try? JSONEncoder().encode(character)
        }
        return nil
    }
    
    var storyData: Data? {
        if case .story(let story) = type {
            return try? JSONEncoder().encode(story)
        }
        return nil
    }
    
    var privateCharacterData: Data? {
        if case .privateCharacter(let character) = type {
            return try? JSONEncoder().encode(character)
        }
        return nil
    }
}

