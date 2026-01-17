//
//  Models.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

// MARK: - Character Model
struct Character: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let avatar: String // Image URL
    let popularity: Int // Number of chats
    let tags: [String] // Tags array
    let description: String
    let gender: String // "male" or "female"
    let category: String // "featured", "story", "private"
    let backgroundImage: String? // Chat background image URL
    let chatDescription: String? // Character introduction in chat interface
    let greetingMessage: String? // Greeting message
    let gallery: [String]? // Gallery (array of image and video URLs)
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatar
        case popularity
        case tags
        case description
        case gender
        case category
        case backgroundImage = "background_image"
        case chatDescription = "chat_description"
        case greetingMessage = "greeting_message"
        case gallery
    }
    
    init(id: UUID = UUID(), name: String, avatar: String, popularity: Int, tags: [String], description: String, gender: String, category: String = "featured", backgroundImage: String? = nil, chatDescription: String? = nil, greetingMessage: String? = nil, gallery: [String]? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.popularity = popularity
        self.tags = tags
        self.description = description
        self.gender = gender
        self.category = category
        self.backgroundImage = backgroundImage
        self.chatDescription = chatDescription
        self.greetingMessage = greetingMessage
        self.gallery = gallery
    }
}

// MARK: - Story Model
struct Story: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let cover: String // Cover image URL
    let popularity: Int
    let description: String
    let category: String // "featured", "story", "private"
    let characterName: String // Character name (displayed in top left corner)
    let gender: String // "male" or "female"
    let backgroundImage: String? // Chat background image URL
    let chatDescription: String? // Character introduction in chat interface
    let greetingMessage: String? // Greeting message
    let gallery: [String]? // Gallery (array of image and video URLs)
    
    // Add CodingKeys to map database field names
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case cover
        case popularity
        case description
        case category
        case characterName = "character_name" // Map to database snake_case field name
        case gender
        case backgroundImage = "background_image"
        case chatDescription = "chat_description"
        case greetingMessage = "greeting_message"
        case gallery
    }
    
    // Custom decoding to handle potentially missing fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        cover = try container.decode(String.self, forKey: .cover)
        popularity = try container.decode(Int.self, forKey: .popularity)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "story"
        // Handle potentially missing character_name field
        characterName = try container.decodeIfPresent(String.self, forKey: .characterName) ?? ""
        // Handle potentially missing gender field
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "female"
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage)
        chatDescription = try container.decodeIfPresent(String.self, forKey: .chatDescription)
        greetingMessage = try container.decodeIfPresent(String.self, forKey: .greetingMessage)
        gallery = try container.decodeIfPresent([String].self, forKey: .gallery)
    }
    
    // Encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(cover, forKey: .cover)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(characterName, forKey: .characterName)
        try container.encode(gender, forKey: .gender)
        try container.encodeIfPresent(backgroundImage, forKey: .backgroundImage)
        try container.encodeIfPresent(chatDescription, forKey: .chatDescription)
        try container.encodeIfPresent(greetingMessage, forKey: .greetingMessage)
        try container.encodeIfPresent(gallery, forKey: .gallery)
    }
    
    init(id: UUID = UUID(), title: String, cover: String, popularity: Int, description: String, category: String = "story", characterName: String = "", gender: String = "female", backgroundImage: String? = nil, chatDescription: String? = nil, greetingMessage: String? = nil, gallery: [String]? = nil) {
        self.id = id
        self.title = title
        self.cover = cover
        self.popularity = popularity
        self.description = description
        self.category = category
        self.characterName = characterName
        self.gender = gender
        self.backgroundImage = backgroundImage
        self.chatDescription = chatDescription
        self.greetingMessage = greetingMessage
        self.gallery = gallery
    }
}

// MARK: - Tab Type
enum TabType: String, CaseIterable {
    case featured = "Featured"
    case story = "Story"
    case privateTab = "Private"
}

// MARK: - Private Character Model (Simplified)
struct PrivateCharacter: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID? // Associated user ID
    let name: String
    let avatar: String? // Optional
    let description: String
    let gender: String // "male" or "female"
    let backgroundImage: String? // Chat background image URL
    let chatDescription: String? // Character introduction in chat interface
    let greetingMessage: String? // Greeting message
    let gallery: [String]? // Gallery (array of image and video URLs)
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case avatar
        case description
        case gender
        case backgroundImage = "background_image"
        case chatDescription = "chat_description"
        case greetingMessage = "greeting_message"
        case gallery
    }
    
    init(id: UUID = UUID(), userId: UUID? = nil, name: String, avatar: String? = nil, description: String, gender: String = "female", backgroundImage: String? = nil, chatDescription: String? = nil, greetingMessage: String? = nil, gallery: [String]? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.avatar = avatar
        self.description = description
        self.gender = gender
        self.backgroundImage = backgroundImage
        self.chatDescription = chatDescription
        self.greetingMessage = greetingMessage
        self.gallery = gallery
    }
}

// MARK: - Chat Character Protocol (Unified Interface)
protocol ChatCharacter {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var gender: String { get }
    var backgroundImage: String? { get }
    var chatDescription: String? { get }
    var greetingMessage: String? { get }
}

// Make Character conform to protocol
extension Character: ChatCharacter {
    // All required properties already implemented
}

// Make Story conform to protocol (use characterName as name)
extension Story: ChatCharacter {
    var name: String { characterName }
}

// Make PrivateCharacter conform to protocol
extension PrivateCharacter: ChatCharacter {
    // All required properties already implemented
}

// MARK: - Bottom Navigation Type
enum BottomNavType: String, CaseIterable {
    case discover = "Discover"
    case chat = "Chat"
    case mine = "Mine"
}

