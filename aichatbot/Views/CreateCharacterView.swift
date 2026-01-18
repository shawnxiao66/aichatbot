//
//  CreateCharacterView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI
import PhotosUI

struct CreateCharacterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var description: String
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var gender: String // "male" 或 "female"
    @State private var isCreating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var existingAvatarURL: String? = nil
    
    var editingCharacter: PrivateCharacter? = nil
    var onCharacterCreated: ((PrivateCharacter) -> Void)?
    var onCharacterUpdated: (() -> Void)?
    
    private var isEditing: Bool {
        editingCharacter != nil
    }
    
    init(editingCharacter: PrivateCharacter? = nil, onCharacterCreated: ((PrivateCharacter) -> Void)? = nil, onCharacterUpdated: (() -> Void)? = nil) {
        self.editingCharacter = editingCharacter
        self.onCharacterCreated = onCharacterCreated
        self.onCharacterUpdated = onCharacterUpdated
        _name = State(initialValue: editingCharacter?.name ?? "")
        _description = State(initialValue: editingCharacter?.description ?? "")
        _gender = State(initialValue: editingCharacter?.gender ?? "female")
        _existingAvatarURL = State(initialValue: editingCharacter?.avatar)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 头像/背景图片选择
                        VStack(spacing: 12) {
                            Text("Background Image (Optional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else if let avatarURL = existingAvatarURL, !avatarURL.isEmpty {
                                    CachedAsyncImage(urlString: avatarURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 300)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(AppColors.cardBackground)
                                            .frame(width: 200, height: 300)
                                            .overlay(
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                                            )
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.cardBackground)
                                        .frame(width: 200, height: 300)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(AppColors.textMuted)
                                                Text("Select Image")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.textMuted)
                                            }
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 名字输入
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Character Name")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextField("Enter character name", text: $name)
                                .foregroundColor(AppColors.textPrimary)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // 性别选择
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    gender = "female"
                                }) {
                                    HStack {
                                        Image(systemName: gender == "female" ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(gender == "female" ? AppColors.accentPrimary : AppColors.textMuted)
                                        Text("Female")
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
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
                                
                                Button(action: {
                                    gender = "male"
                                }) {
                                    HStack {
                                        Image(systemName: gender == "male" ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(gender == "male" ? AppColors.textPrimary : AppColors.textMuted)
                                        Text("Male")
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
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
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 介绍输入
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Character Description")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextEditor(text: $description)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(minHeight: 120)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(.horizontal, 20)
                        
                        // 创建按钮
                        Button(action: {
                            if !isEditing {
                                createCharacter()
                            } else {
                                updateCharacter()
                            }
                        }) {
                            HStack {
                                if isCreating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textPrimary))
                                } else {
                                    Text(isEditing ? "Save Changes" : "Create Character")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                name.isEmpty || description.isEmpty ?
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.textMuted.opacity(0.7),
                                        AppColors.textMuted.opacity(0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
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
                        .disabled(name.isEmpty || description.isEmpty || isCreating)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(isEditing ? "Edit Character" : "Create Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let newItem = newItem {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createCharacter() {
        guard !name.isEmpty, !description.isEmpty else {
            return
        }
        
        isCreating = true
        
        // 如果有图片，先上传图片；否则不传 avatar
        if let image = selectedImage {
            // 上传图片到 Supabase Storage
            SupabaseService.shared.uploadImage(image: image) { result in
                switch result {
                case .success(let imageURL):
                    createCharacterWithAvatar(avatarURL: imageURL)
                case .failure(let error):
                    DispatchQueue.main.async {
                        isCreating = false
                        errorMessage = "图片上传失败: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
        } else {
            // 没有图片，不传 avatar
            createCharacterWithAvatar(avatarURL: "")
        }
    }
    
    private func createCharacterWithAvatar(avatarURL: String) {
        // 获取当前登录用户ID
        guard let userId = AuthService.shared.currentUser?.id else {
            DispatchQueue.main.async {
                isCreating = false
                errorMessage = "请先登录"
                showError = true
            }
            return
        }
        
        let newCharacter = PrivateCharacter(
            name: name,
            avatar: avatarURL.isEmpty ? nil : avatarURL,
            description: description,
            gender: gender
        )
        
        SupabaseService.shared.createPrivateCharacter(character: newCharacter, userId: userId) { result in
            DispatchQueue.main.async {
                isCreating = false
                
                switch result {
                case .success(let createdCharacter):
                    onCharacterCreated?(createdCharacter)
                    dismiss()
                case .failure(let error):
                    errorMessage = "创建角色失败: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func updateCharacter() {
        guard let editingCharacter = editingCharacter else { return }
        guard !name.isEmpty, !description.isEmpty else {
            return
        }
        
        isCreating = true
        
        if let image = selectedImage {
            SupabaseService.shared.uploadImage(image: image) { result in
                switch result {
                case .success(let imageURL):
                    updateCharacterWithAvatar(avatarURL: imageURL, editingCharacter: editingCharacter)
                case .failure(let error):
                    DispatchQueue.main.async {
                        isCreating = false
                        errorMessage = "Image upload failed: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
        } else {
            updateCharacterWithAvatar(avatarURL: existingAvatarURL ?? "", editingCharacter: editingCharacter)
        }
    }
    
    private func updateCharacterWithAvatar(avatarURL: String, editingCharacter: PrivateCharacter) {
        guard let userId = AuthService.shared.currentUser?.id else {
            DispatchQueue.main.async {
                isCreating = false
                errorMessage = "Please log in first"
                showError = true
            }
            return
        }
        
        let updatedCharacter = PrivateCharacter(
            id: editingCharacter.id,
            userId: userId,
            name: name,
            avatar: avatarURL.isEmpty ? nil : avatarURL,
            description: description,
            gender: gender,
            backgroundImage: editingCharacter.backgroundImage,
            chatDescription: editingCharacter.chatDescription,
            greetingMessage: editingCharacter.greetingMessage,
            gallery: editingCharacter.gallery
        )
        
        SupabaseService.shared.updatePrivateCharacter(character: updatedCharacter, userId: userId) { result in
            DispatchQueue.main.async {
                isCreating = false
                
                switch result {
                case .success:
                    onCharacterUpdated?()
                    dismiss()
                case .failure(let error):
                    errorMessage = "Update failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

#Preview {
    CreateCharacterView()
        .preferredColorScheme(.dark)
}

