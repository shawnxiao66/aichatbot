//
//  Conversation.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

// MARK: - Conversation Model
struct Conversation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let avatar: String
    let backgroundImage: String?
    let chatDescription: String?
    let greetingMessage: String?
    let lastMessage: String
    let lastMessageTime: Date
    let type: ConversationType
    
    enum ConversationType: Equatable {
        case character(Character)
        case story(Story)
        case privateCharacter(PrivateCharacter)
    }
    
    // MARK: - Initialization
    init(id: UUID, name: String, avatar: String, backgroundImage: String?, chatDescription: String?, greetingMessage: String?, lastMessage: String, lastMessageTime: Date, type: ConversationType) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.backgroundImage = backgroundImage
        self.chatDescription = chatDescription
        self.greetingMessage = greetingMessage
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.type = type
    }
    
    // MARK: - Create Conversation from Character
    static func from(character: Character) -> Conversation {
        Conversation(
            id: character.id,
            name: character.name,
            avatar: character.avatar,
            backgroundImage: character.backgroundImage,
            chatDescription: character.chatDescription,
            greetingMessage: character.greetingMessage,
            lastMessage: "Start conversation",
            lastMessageTime: Date(),
            type: .character(character)
        )
    }
    
    // MARK: - Create Conversation from Story
    static func from(story: Story) -> Conversation {
        Conversation(
            id: story.id,
            name: story.characterName,
            avatar: story.cover,
            backgroundImage: story.backgroundImage,
            chatDescription: story.chatDescription,
            greetingMessage: story.greetingMessage,
            lastMessage: "Start conversation",
            lastMessageTime: Date(),
            type: .story(story)
        )
    }
    
    // MARK: - Create Conversation from PrivateCharacter
    static func from(character: PrivateCharacter) -> Conversation {
        Conversation(
            id: character.id,
            name: character.name,
            avatar: character.avatar ?? "",
            backgroundImage: character.backgroundImage,
            chatDescription: character.chatDescription,
            greetingMessage: character.greetingMessage,
            lastMessage: "Start conversation",
            lastMessageTime: Date(),
            type: .privateCharacter(character)
        )
    }
}


