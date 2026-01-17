//
//  SupabaseService.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation
import Supabase
import UIKit

class SupabaseService {
    static let shared = SupabaseService()
    
    // Supabase project URL and API Key
    private let supabaseURL = "https://wkukheewayxstqbwmuvn.supabase.co"
    private let supabaseKey = "sb_publishable_6XpSC3KEK3FcYB9HdhMISg_MUXF4Ikz"
    
    private let supabase: SupabaseClient
    
    private init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - Fetch Characters List (with caching)
    func fetchCharacters(category: String, completion: @escaping (Result<[Character], Error>) -> Void) {
        // Check cache first
        if let cachedCharacters = CacheService.shared.getCachedCharacters(category: category) {
            print("📦 Using cached characters for category: \(category)")
            completion(.success(cachedCharacters))
            return
        }
        
        Task {
            do {
                let response: [Character] = try await supabase
                    .from("characters")
                    .select()
                    .eq("category", value: category)
                    .order("popularity", ascending: false)
                    .execute()
                    .value
                
                print("✅ Successfully fetched \(response.count) characters (category: \(category))")
                for character in response.prefix(3) {
                    print("👤 Character: \(character.name)")
                    print("   - Background: \(character.backgroundImage ?? "None")")
                    print("   - Chat Description: \(character.chatDescription ?? "None")")
                    print("   - Greeting: \(character.greetingMessage ?? "None")")
                }
                
                // Cache the results
                CacheService.shared.cacheCharacters(response, category: category)
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ Failed to fetch character data: \(error)")
                if let decodingError = error as? DecodingError {
                    print("   Decoding error details: \(decodingError)")
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   Missing field: \(key.stringValue), path: \(context.codingPath)")
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch: \(type), path: \(context.codingPath)")
                    case .valueNotFound(let type, let context):
                        print("   Value not found: \(type), path: \(context.codingPath)")
                    case .dataCorrupted(let context):
                        print("   Data corrupted: \(context)")
                    @unknown default:
                        print("   Unknown decoding error")
                    }
                }
                await MainActor.run {
                    // Return sample data on failure
                    switch category {
                    case "featured":
                        completion(.success(SampleData.featuredCharacters))
                    case "private":
                        completion(.success(SampleData.privateCharacters))
                    default:
                        completion(.success([]))
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch Stories List (with caching)
    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
        // Check cache first
        if let cachedStories = CacheService.shared.getCachedStories() {
            print("📦 Using cached stories")
            completion(.success(cachedStories))
            return
        }
        
        Task {
            do {
                // Directly fetch and decode data
                let response: [Story] = try await supabase
                    .from("stories")
                    .select()
                    .order("popularity", ascending: false)
                    .execute()
                    .value
                
                print("✅ Successfully fetched \(response.count) stories")
                for story in response {
                    print("📖 Story: \(story.title)")
                    print("   - Cover URL: \(story.cover)")
                    print("   - URL valid: \(URL(string: story.cover) != nil)")
                    print("   - Character name: \(story.characterName)")
                    print("   - Gender: \(story.gender)")
                    if story.cover.isEmpty {
                        print("   ⚠️ Warning: cover field is empty!")
                    }
                }
                
                // Cache the results
                CacheService.shared.cacheStories(response)
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ Failed to fetch story data: \(error)")
                if let decodingError = error as? DecodingError {
                    print("   Decoding error details: \(decodingError)")
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   ❌ Missing field: \(key.stringValue)")
                        print("   📍 Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   📝 Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("   ❌ Type mismatch: expected \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   📝 Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("   ❌ Value not found: type \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   📝 Context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("   ❌ Data corrupted")
                        print("   📝 Context: \(context.debugDescription)")
                        if let underlyingError = context.underlyingError {
                            print("   🔍 Underlying error: \(underlyingError)")
                        }
                    @unknown default:
                        print("   ❌ Unknown decoding error")
                    }
                } else {
                    print("   🔍 Error type: \(type(of: error))")
                    print("   📝 Error description: \(error.localizedDescription)")
                }
                await MainActor.run {
                    // Return sample data on failure
                    completion(.success(SampleData.stories))
                }
            }
        }
    }
    
    // MARK: - Search Characters
    func searchCharacters(query: String, completion: @escaping (Result<[Character], Error>) -> Void) {
        Task {
            do {
                let response: [Character] = try await supabase
                    .from("characters")
                    .select()
                    .or("name.ilike.*\(query)*,description.ilike.*\(query)*")
                    .execute()
                    .value
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("Failed to search characters: \(error)")
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Search Stories
    func searchStories(query: String, completion: @escaping (Result<[Story], Error>) -> Void) {
        Task {
            do {
                let response: [Story] = try await supabase
                    .from("stories")
                    .select()
                    .or("title.ilike.*\(query)*,description.ilike.*\(query)*")
                    .execute()
                    .value
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("Failed to search stories: \(error)")
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Create Character
    func createCharacter(character: Character, completion: @escaping (Result<Character, Error>) -> Void) {
        Task {
            do {
                // Directly insert Character object, Supabase SDK will handle encoding automatically
                let response: Character = try await supabase
                    .from("characters")
                    .insert(character)
                    .select()
                    .single()
                    .execute()
                    .value
                
                print("✅ Successfully created character: \(response.name)")
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ Failed to create character: \(error)")
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Fetch Private Characters List (Filtered by User ID, with caching)
    func fetchPrivateCharacters(userId: UUID, completion: @escaping (Result<[PrivateCharacter], Error>) -> Void) {
        // Check cache first
        if let cachedCharacters = CacheService.shared.getCachedPrivateCharacters(userId: userId) {
            print("📦 Using cached private characters for userId: \(userId)")
            completion(.success(cachedCharacters))
            return
        }
        
        Task {
            do {
                let response: [PrivateCharacter] = try await supabase
                    .from("private_characters")
                    .select()
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                print("✅ Successfully fetched \(response.count) private characters (userId: \(userId))")
                
                // Cache the results
                CacheService.shared.cachePrivateCharacters(response, userId: userId)
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ Failed to fetch private characters: \(error)")
                await MainActor.run {
                    completion(.success([])) // Return empty array on failure
                }
            }
        }
    }
    
    // MARK: - Create Private Character (Associate with User ID)
    func createPrivateCharacter(character: PrivateCharacter, userId: UUID, completion: @escaping (Result<PrivateCharacter, Error>) -> Void) {
        Task {
            do {
                // Create character object with user_id
                var characterWithUserId = character
                // Note: Since PrivateCharacter is a struct, we need to create a new instance
                let characterToInsert = PrivateCharacter(
                    id: character.id,
                    userId: userId,
                    name: character.name,
                    avatar: character.avatar,
                    description: character.description,
                    gender: character.gender,
                    backgroundImage: character.backgroundImage,
                    chatDescription: character.chatDescription,
                    greetingMessage: character.greetingMessage,
                    gallery: character.gallery
                )
                
                // Directly insert PrivateCharacter object
                let response: PrivateCharacter = try await supabase
                    .from("private_characters")
                    .insert(characterToInsert)
                    .select()
                    .single()
                    .execute()
                    .value
                
                print("✅ Successfully created private character: \(response.name) (userId: \(userId))")
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ Failed to create private character: \(error)")
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Create User
    func createUser(user: User, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                // Directly insert User object, Supabase SDK will handle encoding automatically
                let response: User = try await supabase
                    .from("users")
                    .insert(user)
                    .select()
                    .single()
                    .execute()
                    .value
                
                print("✅ Successfully created user: \(response.username) (id: \(response.id))")
                
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ Failed to create user: \(error)")
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Delete User
    func deleteUser(userId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await supabase
                    .from("users")
                    .delete()
                    .eq("id", value: userId)
                    .execute()
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Upload Image to Supabase Storage
    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                // Convert image to Data
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image"])
                }
                
                // Generate unique file name
                let fileName = "\(UUID().uuidString).jpg"
                
                // Upload to Supabase Storage
                // Note: Need to create a storage bucket named "characters" in Supabase Dashboard first and set it to public
                try await supabase.storage
                    .from("characters")
                    .upload(path: fileName, file: imageData, options: FileOptions(upsert: false))
                
                // Get public URL
                let publicURL = try await supabase.storage
                    .from("characters")
                    .getPublicURL(path: fileName)
                
                print("✅ Image uploaded successfully: \(publicURL)")
                
                await MainActor.run {
                    completion(.success(publicURL.absoluteString))
                }
            } catch {
                print("❌ Failed to upload image: \(error)")
                // If upload fails, return placeholder URL
                await MainActor.run {
                    let placeholderURL = "https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=Character"
                    completion(.success(placeholderURL))
                }
            }
        }
    }
}
