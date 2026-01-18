//
//  CharacterProfileView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

// MARK: - 角色资料卡视图
struct CharacterProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var authService = AuthService.shared
    @State private var unlockedGallery: Set<String> = []
    @State private var showUnlockAlert: Bool = false
    @State private var unlockAlertMessage: String = ""
    @State private var showManageActions: Bool = false
    @State private var showEditCharacter: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var actionErrorMessage: String = ""
    @State private var showActionError: Bool = false
    private let perImageCost = 50
    
    // 支持三种类型的角色
    enum ProfileType: Identifiable {
        case character(Character)
        case story(Story)
        case privateCharacter(PrivateCharacter)
        
        var id: UUID {
            switch self {
            case .character(let char): return char.id
            case .story(let story): return story.id
            case .privateCharacter(let char): return char.id
            }
        }
    }
    
    let profileType: ProfileType
    var onStartChat: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    // 计算属性：获取统一的角色信息
    private var name: String {
        switch profileType {
        case .character(let char): return char.name
        case .story(let story): return story.characterName
        case .privateCharacter(let char): return char.name
        }
    }
    
    private var avatar: String {
        switch profileType {
        case .character(let char): return char.avatar
        case .story(let story): return story.cover
        case .privateCharacter(let char): return char.avatar ?? ""
        }
    }
    
    private var backgroundImage: String? {
        switch profileType {
        case .character(let char): return char.backgroundImage
        case .story(let story): return story.backgroundImage
        case .privateCharacter(let char): return char.backgroundImage
        }
    }
    
    private var description: String {
        switch profileType {
        case .character(let char): return char.description
        case .story(let story): return story.description
        case .privateCharacter(let char): return char.description
        }
    }
    
    private var gender: String {
        switch profileType {
        case .character(let char): return char.gender
        case .story(let story): return story.gender
        case .privateCharacter(let char): return char.gender
        }
    }
    
    private var gallery: [String] {
        switch profileType {
        case .character(let char): return char.gallery ?? []
        case .story(let story): return story.gallery ?? []
        case .privateCharacter(let char): return char.gallery ?? []
        }
    }

    private var canManageProfile: Bool {
        if case .privateCharacter = profileType {
            return true
        }
        return false
    }

    private var galleryUnlockKey: String {
        let profileId = profileType.id.uuidString
        let userId = authService.currentUser?.id.uuidString ?? "guest"
        return "unlocked_gallery_\(profileId)_\(userId)"
    }
    
    // 年龄（暂时使用固定值，后续可以从数据库获取）
    private var age: Int {
        // TODO: 从数据库获取年龄，暂时返回默认值
        return 20
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background
                .ignoresSafeArea()
            // 内容区域 - ScrollView
            ScrollView {
                VStack(spacing: 0) {
                    // 上方：聊天背景图（优先使用背景图，如果没有则使用头像）
                    GeometryReader { geometry in
                        AsyncImage(url: URL(string: backgroundImage ?? avatar)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(AppColors.textMuted)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.width * 16 / 9) // 9:16 竖图
                    
                    // 中部：名字、介绍、年龄和性别
                    VStack(alignment: .leading, spacing: 10) {
                        // 名字
                        Text(name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        // 介绍
                        Text(description)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(4)
                        
                        // 年龄和性别
                        HStack(spacing: 8) {
                            Text("\(age)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("·")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textMuted)
                            
                            Text(gender == "female" ? "Female" : "Male")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.background)
                    
                    // 下方：相册
                    if !gallery.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Gallery")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8)
                            ], spacing: 8) {
                                ForEach(Array(gallery.enumerated()), id: \.offset) { index, itemURL in
                                    let isLocked = !unlockedGallery.contains(itemURL)
                                    GalleryItemView(
                                        url: itemURL,
                                        isLocked: isLocked,
                                        onUnlock: {
                                            unlockGalleryItem(url: itemURL)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 24)
                        .padding(.bottom, 100) // 为底部悬浮按钮留出空间
                        .background(AppColors.background)
                    } else {
                        // 如果没有相册，也需要为按钮留出空间
                        AppColors.background
                            .frame(height: 100)
                    }
                }
            }
            .background(AppColors.background)
            
            // 悬浮的Chat按钮 - 固定在底部
            VStack {
                Spacer()
                
                // 底部渐变遮罩，让按钮更突出
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            AppColors.background.opacity(0.9)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .ignoresSafeArea(edges: .bottom)
                    
                    Button(action: {
                        onStartChat?()
                    }) {
                        Text("Chat")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .onAppear {
            loadUnlockedGallery()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppColors.background.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            if canManageProfile {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showManageActions = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(AppColors.background.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .sheet(isPresented: $showManageActions) {
            ManageActionsSheet(
                onEdit: {
                    showManageActions = false
                    showEditCharacter = true
                },
                onDelete: {
                    showManageActions = false
                    showDeleteConfirm = true
                }
            )
            .presentationDetents([.height(220)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
        }
        .sheet(isPresented: $showEditCharacter) {
            if case .privateCharacter(let character) = profileType {
                CreateCharacterView(editingCharacter: character, onCharacterUpdated: {
                    onEdit?()
                    dismiss()
                })
            }
        }
        .sheet(isPresented: $showDeleteConfirm) {
            DeleteConfirmSheet(
                onDelete: {
                    performDelete()
                },
                onCancel: {
                    showDeleteConfirm = false
                }
            )
            .presentationDetents([.height(230)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
        }
        .alert("Error", isPresented: $showActionError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(actionErrorMessage)
        }
        .alert("Unable to unlock", isPresented: $showUnlockAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(unlockAlertMessage)
        }
    }

    private func loadUnlockedGallery() {
        if let stored = UserDefaults.standard.array(forKey: galleryUnlockKey) as? [String] {
            unlockedGallery = Set(stored)
        }
    }

    private func saveUnlockedGallery() {
        let stored = Array(unlockedGallery)
        UserDefaults.standard.set(stored, forKey: galleryUnlockKey)
    }

    private func unlockGalleryItem(url: String) {
        guard !unlockedGallery.contains(url) else { return }
        guard authService.currentUser != nil else {
            unlockAlertMessage = "Please login to unlock this image."
            showUnlockAlert = true
            return
        }

        if authService.spendDiamonds(perImageCost) {
            unlockedGallery.insert(url)
            saveUnlockedGallery()
        } else {
            unlockAlertMessage = "Unlocking this image costs \(perImageCost) diamonds."
            showUnlockAlert = true
        }
    }
    
    private func performDelete() {
        guard case .privateCharacter(let character) = profileType else {
            showDeleteConfirm = false
            return
        }
        guard let userId = authService.currentUser?.id else {
            showDeleteConfirm = false
            actionErrorMessage = "Please log in first."
            showActionError = true
            return
        }
        
        SupabaseService.shared.deletePrivateCharacter(id: character.id, userId: userId) { result in
            DispatchQueue.main.async {
                showDeleteConfirm = false
                switch result {
                case .success:
                    CacheService.shared.clearPrivateCharactersCache(for: userId)
                    onDelete?()
                    dismiss()
                case .failure(let error):
                    actionErrorMessage = "Delete failed: \(error.localizedDescription)"
                    showActionError = true
                }
            }
        }
    }
}

// MARK: - 角色管理操作弹窗
struct ManageActionsSheet: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                VStack(spacing: 0) {
                    Button(action: onEdit) {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Edit")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    
                    Divider()
                        .background(AppColors.textMuted.opacity(0.3))
                        .padding(.horizontal, 16)
                    
                    Button(action: onDelete) {
                        HStack(spacing: 10) {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Delete")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(Color.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.cardBackground.opacity(0.95),
                            AppColors.cardBackground.opacity(0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.textMuted.opacity(0.08), lineWidth: 1)
                )
                
                Button(role: .cancel, action: {}) {
                Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.accentPrimary.opacity(0.35),
                                    AppColors.accentSecondary.opacity(0.35)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(18)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 删除确认弹窗
struct DeleteConfirmSheet: View {
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text("Delete character?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("This action can't be undone.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 8)
                
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                }
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.accentPrimary.opacity(0.35),
                                    AppColors.accentSecondary.opacity(0.35)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 相册项视图（支持图片和视频）
struct GalleryItemView: View {
    let url: String
    let isLocked: Bool
    let onUnlock: () -> Void
    @State private var isVideo: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if isVideo {
                        // 视频预览
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .overlay(
                            // 播放按钮
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.textPrimary.opacity(0.9))
                        )
                    } else {
                        // 图片
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(AppColors.textMuted)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .blur(radius: isLocked ? 8 : 0)

                if isLocked {
                    Rectangle()
                        .fill(AppColors.background.opacity(0.55))
                    VStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Unlock 50 💎")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(8)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(8)
        .onTapGesture {
            if isLocked {
                onUnlock()
            }
        }
        .onAppear {
            // 简单判断：如果URL包含video相关关键词，认为是视频
            // 实际应用中可以从数据库获取类型信息
            isVideo = url.lowercased().contains("video") || 
                     url.lowercased().contains(".mp4") || 
                     url.lowercased().contains(".mov")
        }
    }
}

#Preview {
    CharacterProfileView(profileType: .character(SampleData.featuredCharacters[0]))
        .preferredColorScheme(.dark)
}

