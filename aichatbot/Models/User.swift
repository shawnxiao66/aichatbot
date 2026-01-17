//
//  User.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: UUID
    let username: String
    let email: String
    let age: Int
    let gender: String // "male" or "female"
    let avatar: String? // Avatar URL
    let level: Int // Level
    let diamonds: Int // Diamonds balance
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case age
        case gender
        case avatar
        case level
        case diamonds
    }
    
    init(
        id: UUID = UUID(),
        username: String,
        email: String,
        age: Int,
        gender: String,
        avatar: String? = nil,
        level: Int = 1,
        diamonds: Int = 30
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.age = age
        self.gender = gender
        self.avatar = avatar
        self.level = level
        self.diamonds = diamonds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        self.age = try container.decode(Int.self, forKey: .age)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        self.diamonds = try container.decodeIfPresent(Int.self, forKey: .diamonds) ?? 30
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encodeIfPresent(avatar, forKey: .avatar)
        try container.encode(level, forKey: .level)
        try container.encode(diamonds, forKey: .diamonds)
    }
}


