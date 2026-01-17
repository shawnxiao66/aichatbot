//
//  MainTabView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var selectedTab: BottomNavType = .discover
    @State private var chatNotificationCount: Int = 0
    
    var body: some View {
        Group {
            if authService.isLoggedIn {
                // 已登录：显示主界面
                ZStack {
                    // 内容视图
                    Group {
                        switch selectedTab {
                        case .discover:
                            DiscoverView()
                        case .chat:
                            ChatView()
                        case .mine:
                            MineView()
                        }
                    }
                    
                    // 底部导航栏
                    VStack {
                        Spacer()
                        bottomNavigationBar
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            } else {
                // 未登录：显示登录页面
                LoginView()
            }
        }
    }
    
    // MARK: - 底部导航栏
    private var bottomNavigationBar: some View {
        HStack(spacing: 0) {
            ForEach(BottomNavType.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: iconName(for: tab))
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == tab ? AppColors.accentPrimary : AppColors.textMuted)
                            
                            // 对话标签的通知气泡
                            if tab == .chat && chatNotificationCount > 0 {
                                Text("\(chatNotificationCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(4)
                                    .background(AppColors.error)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -12)
                            }
                        }
                        
                        Text(tab.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(selectedTab == tab ? AppColors.accentPrimary : AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(AppColors.background)
        .shadow(color: AppColors.background.opacity(0.6), radius: 10, x: 0, y: -5)
    }
    
    private func iconName(for tab: BottomNavType) -> String {
        switch tab {
        case .discover:
            return "safari"
        case .chat:
            return "message.fill"
        case .mine:
            return "person.fill"
        }
    }
}

// MARK: - Chat view is already implemented in ChatView.swift

// MARK: - Mine Page
struct MineView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var showLogin: Bool = false
    @State private var showSettings: Bool = false
    @State private var showEditProfile: Bool = false
    @State private var showPaywall: Bool = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if authService.isLoggedIn, let user = authService.currentUser {
                // Logged in state
                ScrollView {
                    VStack(spacing: 0) {
                        // User info section
                        userInfoSection(user: user)
                            .padding(.top, 20)
                        
                        // Premium subscription card
                        premiumCard
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        
                        // Diamonds card
                        diamondsCard(diamonds: user.diamonds)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            } else {
                // Not logged in state
                VStack(spacing: 24) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.textMuted.opacity(0.6))
                    
                    Text("Please login first")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Login")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.accentPrimary.opacity(0.9),
                                        AppColors.accentSecondary.opacity(0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                    }
                }
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - User Info Section
    private func userInfoSection(user: User) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar and level badge
            ZStack(alignment: .bottomLeading) {
                // Avatar
                    if let avatarURL = user.avatar, !avatarURL.isEmpty {
                    CachedAsyncImage(urlString: avatarURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppColors.accentPrimary.opacity(0.8), lineWidth: 2)
                                    .blur(radius: 4)
                            )
                    } placeholder: {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.accentPrimary.opacity(0.7), AppColors.accentSecondary.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.accentPrimary.opacity(0.8), lineWidth: 2)
                                    .blur(radius: 4)
                            )
                    }
                } else {
                    // Default avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.accentPrimary.opacity(0.7), AppColors.accentSecondary.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(AppColors.accentPrimary.opacity(0.8), lineWidth: 2)
                                .blur(radius: 4)
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.textPrimary.opacity(0.8))
                        )
                }
                
                // Level badge
                Text("Level \(user.level)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accentSecondary)
                    .cornerRadius(8)
                    .offset(x: -8, y: 8)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(user.age) • \(user.gender == "male" ? "Male" : "Female")")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Edit and settings buttons
            HStack(spacing: 12) {
                Button(action: {
                    showEditProfile = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Premium Subscription Card
    private var premiumCard: some View {
        Button(action: {
            showPaywall = true
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "eye.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Subscribe to Premium")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Unlock all the possibilities of EVA AI")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.accentPrimary.opacity(0.9),
                        AppColors.accentSecondary.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Neurons Card
    private func diamondsCard(diamonds: Int) -> some View {
        Button(action: {
            showPaywall = true
        }) {
            HStack(spacing: 16) {
                // Neurons icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.accentSecondary.opacity(0.7),
                                    AppColors.accentPrimary.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Text("Get diamonds")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // Diamonds count
                HStack(spacing: 4) {
                    Text("\(diamonds)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.accentPrimary.opacity(0.9),
                        AppColors.accentSecondary.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
        }
    }
}

// MARK: - Settings Page
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService = AuthService.shared
    @State private var showDeleteConfirm: Bool = false
    @State private var showDeleteError: Bool = false
    @State private var deleteErrorMessage: String = ""
    @State private var isDeleting: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    Button(action: {
                        authService.logout()
                        dismiss()
                        // After logout, MainTabView will automatically show login page
                    }) {
                        Text("Logout")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.error)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    Button(action: {
                        showDeleteConfirm = true
                    }) {
                        Text(isDeleting ? "Deleting..." : "Delete account")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.error.opacity(0.7))
                            .cornerRadius(12)
                    }
                    .disabled(isDeleting)
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
        .alert("Delete account?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                isDeleting = true
                authService.deleteAccount { result in
                    isDeleting = false
                    switch result {
                    case .success:
                        dismiss()
                    case .failure(let error):
                        deleteErrorMessage = error.localizedDescription
                        showDeleteError = true
                    }
                }
            }
        } message: {
            Text("This will permanently delete your account and cannot be undone.")
        }
        .alert("Delete failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deleteErrorMessage)
        }
    }
}

// MARK: - Edit Profile Page
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService = AuthService.shared
    @State private var username: String = ""
    @State private var age: String = ""
    @State private var gender: String = "male"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("Enter username", text: $username)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("Enter age", text: $age)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .keyboardType(.numberPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    gender = "male"
                                }) {
                                    Text("Male")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            gender == "male" ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.accentPrimary.opacity(0.9),
                                                    AppColors.accentSecondary.opacity(0.9)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.cardBackground,
                                                    AppColors.cardBackground
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(16)
                                }
                                
                                Button(action: {
                                    gender = "female"
                                }) {
                                    Text("Female")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            gender == "female" ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.accentPrimary.opacity(0.9),
                                                    AppColors.accentSecondary.opacity(0.9)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.cardBackground,
                                                    AppColors.cardBackground
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(16)
                                }
                            }
                        }
                        
                        Button(action: {
                            saveProfile()
                        }) {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            AppColors.accentPrimary.opacity(0.9),
                                            AppColors.accentSecondary.opacity(0.9)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
        .onAppear {
            if let user = authService.currentUser {
                username = user.username
                age = "\(user.age)"
                gender = user.gender
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveProfile() {
        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Username cannot be empty."
            showError = true
            return
        }
        guard let ageValue = Int(age), ageValue > 0 else {
            errorMessage = "Please enter a valid age."
            showError = true
            return
        }
        authService.updateProfile(username: trimmedName, age: ageValue, gender: gender)
        dismiss()
    }
}


#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}

