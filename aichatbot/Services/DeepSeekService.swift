//
//  DeepSeekService.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

class DeepSeekService {
    static let shared = DeepSeekService()
    
    // TODO: Replace with your DeepSeek API Key
    private let apiKey = "sk-4fcf9bf6208e4296af392f98a7213dc3"
    private let apiURL = "https://api.deepseek.com/v1/chat/completions"
    
    private init() {}
    
    // MARK: - Send Message to AI Character (Supports Character)
    func sendMessage(
        to character: Character,
        message: String,
        conversationHistory: [ChatMessage] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Build character system prompt
        var systemPrompt = """
        You are \(character.name), \(character.description).
        """
        
        // If there are tags, add personality traits
        if !character.tags.isEmpty {
            systemPrompt += "\nYour personality traits: \(character.tags.joined(separator: ", "))."
        }
        
        systemPrompt += "\nPlease converse with the user as this character, maintaining character consistency."
        
        sendMessageToAI(systemPrompt: systemPrompt, message: message, conversationHistory: conversationHistory, completion: completion)
    }
    
    // MARK: - Send Message to Story Character (Supports Story)
    func sendMessage(
        to story: Story,
        message: String,
        conversationHistory: [ChatMessage] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Build character system prompt (story characters have stronger setting)
        var systemPrompt = """
        You are \(story.characterName) from the story "\(story.title)".
        \(story.description)
        """
        
        // If there is a chat description, add it to the system prompt
        if let chatDesc = story.chatDescription, !chatDesc.isEmpty {
            systemPrompt += "\n\n\(chatDesc)"
        }
        
        systemPrompt += "\nPlease converse with the user as this character, maintaining character setting and story background consistency."
        
        sendMessageToAI(systemPrompt: systemPrompt, message: message, conversationHistory: conversationHistory, completion: completion)
    }
    
    // MARK: - Send Message to Private Character (Supports PrivateCharacter)
    func sendMessage(
        to character: PrivateCharacter,
        message: String,
        conversationHistory: [ChatMessage] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Build character system prompt
        var systemPrompt = """
        You are \(character.name), \(character.description).
        """
        
        // If there is a chat description, add it to the system prompt
        if let chatDesc = character.chatDescription, !chatDesc.isEmpty {
            systemPrompt += "\n\n\(chatDesc)"
        }
        
        systemPrompt += "\nPlease converse with the user as this character, maintaining character consistency."
        
        sendMessageToAI(systemPrompt: systemPrompt, message: message, conversationHistory: conversationHistory, completion: completion)
    }
    
    // MARK: - Generic AI Message Sending Method
    private func sendMessageToAI(
        systemPrompt: String,
        message: String,
        conversationHistory: [ChatMessage],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        // Build messages array
        var messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add conversation history
        for historyMessage in conversationHistory {
            messages.append([
                "role": historyMessage.role,
                "content": historyMessage.content
            ])
        }
        
        // Add current user message
        messages.append([
            "role": "user",
            "content": message
        ])
        
        // Build request body
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2000
        ]
        
        // Create request
        guard let url = URL(string: apiURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: -1)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

