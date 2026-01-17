//
//  AuthService.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

// MARK: - Authentication Service
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User? = nil
    @Published var isLoggedIn: Bool = false
    
    private let userKey = "current_user"
    private let isLoggedInKey = "is_logged_in"
    private let defaultDiamonds = 30
    private let chatCost = 2
    private let galleryCost = 50
    
    private init() {
        loadUser()
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // TODO: In production, should call backend API for verification
        // Currently using simulated login
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Simulate successful login
            let user = User(
                username: "Shawn",
                email: email,
                age: 26,
                gender: "male",
                level: 1,
                diamonds: self.defaultDiamonds
            )
            self.currentUser = user
            self.isLoggedIn = true
            self.saveUser(user)
            completion(.success(user))
        }
    }
    
    // MARK: - Sign Up
    func signUp(username: String, email: String, password: String, age: Int, gender: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Create user object
        let user = User(
            username: username,
            email: email,
            age: age,
            gender: gender,
            level: 1,
            diamonds: defaultDiamonds
        )
        
        // Call Supabase to create user record
        SupabaseService.shared.createUser(user: user) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdUser):
                    // After successful creation, update local state
                    self?.currentUser = createdUser
                    self?.isLoggedIn = true
                    self?.saveUser(createdUser)
                    completion(.success(createdUser))
                case .failure(let error):
                    // If Supabase creation fails, still allow local login (for development/testing)
                    print("⚠️ Supabase user creation failed, using local user: \(error)")
                    self?.currentUser = user
                    self?.isLoggedIn = true
                    self?.saveUser(user)
                    completion(.success(user))
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
    }

    // MARK: - Update Profile
    func updateProfile(username: String, age: Int, gender: String) {
        guard let user = currentUser else { return }
        let updatedUser = User(
            id: user.id,
            username: username,
            email: user.email,
            age: age,
            gender: gender,
            avatar: user.avatar,
            level: user.level,
            diamonds: user.diamonds
        )
        currentUser = updatedUser
        saveUser(updatedUser)
    }

    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else {
            completion(.failure(NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        SupabaseService.shared.deleteUser(userId: user.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.logout()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Diamonds
    func spendDiamonds(_ amount: Int) -> Bool {
        guard amount > 0, let user = currentUser else { return false }
        guard user.diamonds >= amount else { return false }
        updateDiamonds(user.diamonds - amount)
        return true
    }

    func addDiamonds(_ amount: Int) {
        guard amount > 0, let user = currentUser else { return }
        updateDiamonds(user.diamonds + amount)
    }

    func chatCostAmount() -> Int {
        chatCost
    }

    func galleryCostAmount() -> Int {
        galleryCost
    }
    
    // MARK: - Save User
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
        }
    }

    private func updateDiamonds(_ diamonds: Int) {
        guard let user = currentUser else { return }
        let updatedUser = User(
            id: user.id,
            username: user.username,
            email: user.email,
            age: user.age,
            gender: user.gender,
            avatar: user.avatar,
            level: user.level,
            diamonds: max(diamonds, 0)
        )
        currentUser = updatedUser
        saveUser(updatedUser)
    }
    
    // MARK: - Load User
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        }
    }
}


