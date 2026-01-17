//
//  CacheService.swift
//  aichatbot
//
//  Created for AI Chatbot App - Performance Optimization
//

import Foundation

// MARK: - Data Cache Service
class CacheService {
    static let shared = CacheService()
    
    private var charactersCache: [String: [Character]] = [:] // category -> characters
    private var storiesCache: [Story] = []
    private var privateCharactersCache: [UUID: [PrivateCharacter]] = [:] // userId -> characters
    private var cacheTimestamps: [String: Date] = [:]
    
    private let cacheExpirationTime: TimeInterval = 300 // 5分钟缓存过期时间
    
    private init() {}
    
    // MARK: - Characters Cache
    func getCachedCharacters(category: String) -> [Character]? {
        let key = "characters_\(category)"
        if let timestamp = cacheTimestamps[key],
           Date().timeIntervalSince(timestamp) < cacheExpirationTime {
            return charactersCache[category]
        }
        return nil
    }
    
    func cacheCharacters(_ characters: [Character], category: String) {
        charactersCache[category] = characters
        cacheTimestamps["characters_\(category)"] = Date()
    }
    
    // MARK: - Stories Cache
    func getCachedStories() -> [Story]? {
        let key = "stories"
        if let timestamp = cacheTimestamps[key],
           Date().timeIntervalSince(timestamp) < cacheExpirationTime {
            return storiesCache
        }
        return nil
    }
    
    func cacheStories(_ stories: [Story]) {
        storiesCache = stories
        cacheTimestamps["stories"] = Date()
    }
    
    // MARK: - Private Characters Cache
    func getCachedPrivateCharacters(userId: UUID) -> [PrivateCharacter]? {
        let key = "private_\(userId.uuidString)"
        if let timestamp = cacheTimestamps[key],
           Date().timeIntervalSince(timestamp) < cacheExpirationTime {
            return privateCharactersCache[userId]
        }
        return nil
    }
    
    func cachePrivateCharacters(_ characters: [PrivateCharacter], userId: UUID) {
        privateCharactersCache[userId] = characters
        cacheTimestamps["private_\(userId.uuidString)"] = Date()
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        charactersCache.removeAll()
        storiesCache.removeAll()
        privateCharactersCache.removeAll()
        cacheTimestamps.removeAll()
    }
    
    func clearCache(for category: String) {
        charactersCache.removeValue(forKey: category)
        cacheTimestamps.removeValue(forKey: "characters_\(category)")
    }
}
