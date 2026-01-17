//
//  ChatView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

// MARK: - 聊天消息模型（已在 DeepSeekService.swift 中定义，这里不再重复）

// MARK: - 聊天视图（列表页）
struct ChatView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var conversations: [Conversation] = []
    @State private var isLoading: Bool = false
    @State private var selectedConversation: Conversation? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("Chat")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.background)
            
            // 对话列表
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                    .padding(.top, 50)
            } else if conversations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.textMuted)
                    Text("No conversations yet")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textMuted)
                    Text("Go to Discover page to select a character and start chatting")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textMuted.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(conversations) { conversation in
                        ConversationRow(conversation: conversation)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedConversation = conversation
                            }
                            .listRowBackground(AppColors.background)
                    }
                }
                .listStyle(PlainListStyle())
                .background(AppColors.background)
            }
        }
        .background(AppColors.background)
        .onAppear {
            loadConversations()
        }
        .refreshable {
            // 下拉刷新
            loadConversations()
        }
        .fullScreenCover(item: $selectedConversation) { conversation in
            ChatDetailView(conversation: conversation) {
                // 当对话详情关闭时，刷新列表
                loadConversations()
            }
        }
    }
    
    private func loadConversations() {
        isLoading = true
        // 立即加载，不需要延迟
        if let userId = authService.currentUser?.id {
            conversations = ConversationStorageService.shared.loadConversations(userId: userId)
        } else {
            conversations = []
        }
        isLoading = false
    }
}

// MARK: - 对话行视图
struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像（使用缓存，优先使用 background image）
            CachedAsyncImage(urlString: conversation.backgroundImage ?? conversation.avatar) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(AppColors.cardBackground.opacity(0.8))
                    .frame(width: 50, height: 50)
            }
            
            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(conversation.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textMuted)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 时间
            Text(formatTime(conversation.lastMessageTime))
                .font(.system(size: 12))
                .foregroundColor(AppColors.textMuted)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 对话详情视图
struct ChatDetailView: View {
    let conversation: Conversation
    var onDismiss: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService = AuthService.shared
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
    @State private var showNarrative: Bool = true // 是否显示角色介绍
    @State private var showProfile: Bool = false // 是否显示资料卡
    @State private var showInsufficientDiamonds: Bool = false
    @State private var insufficientDiamondsMessage: String = ""
    @State private var showPaywall: Bool = false
    @State private var showReportMenu: Bool = false
    @State private var showReportForm: Bool = false
    @State private var reportText: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景图片 - ZStack 最底层，完全独立于布局系统
                let _ = print("🎨 ChatDetailView 渲染，角色: \(conversation.name), 背景图: \(conversation.backgroundImage ?? "无")")
                Group {
                    if let backgroundImage = conversation.backgroundImage, !backgroundImage.isEmpty {
                        CachedAsyncImage(urlString: backgroundImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                        } placeholder: {
                            AppColors.background
                        }
                        .allowsHitTesting(false) // 不拦截触摸事件，确保不影响其他元素
                    } else {
                        AppColors.background
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea(.all) // 忽略所有安全区域
                
                // 聊天内容区域 - 独立的 VStack，受 SafeArea 约束
                VStack(spacing: 0) {
                    // 顶部导航栏
                    chatHeaderView
                        .zIndex(2)
                    
                    // 消息列表
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                // 角色介绍作为第一条消息显示
                                if showNarrative, let chatDescription = conversation.chatDescription, !chatDescription.isEmpty {
                                    NarrativeMessageBubble(
                                        text: chatDescription,
                                        characterName: conversation.name,
                                        characterAvatar: conversation.avatar
                                    )
                                    .id("narrative")
                                }
                                
                                // 显示消息
                                if messages.isEmpty && (!showNarrative || conversation.chatDescription?.isEmpty ?? true) {
                                    // 空状态提示
                                    VStack(spacing: 16) {
                                        Spacer()
                                            .frame(height: 100)
                Text("Start chatting with \(conversation.name)")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    ForEach(messages) { message in
                                        MessageBubble(
                                            message: message,
                                            characterName: conversation.name,
                                            characterAvatar: conversation.avatar
                                        )
                                        .id(message.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 0)
                            .padding(.bottom, 12)
                        }
                        .onChange(of: messages.count) { _ in
                            if let lastMessage = messages.last {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                    
                    // 输入栏
                    inputBarView
                }

            }
        }
        .onAppear {
            print("👀 ChatDetailView onAppear，角色: \(conversation.name)")
            print("   - 消息数量: \(messages.count)")
            print("   - 背景图: \(conversation.backgroundImage ?? "无")")
            print("   - 招呼语: \(conversation.greetingMessage ?? "无")")
            loadMessages()
            // 在对话详情页出现时保存对话
            if let userId = authService.currentUser?.id {
                ConversationStorageService.shared.addOrUpdateConversation(conversation, userId: userId)
            }
        }
        .onDisappear {
            // 保存消息历史
            if let userId = authService.currentUser?.id {
                MessageStorageService.shared.saveMessages(messages, conversationId: conversation.id, userId: userId)
            }
            // 调用关闭回调
            onDismiss?()
        }
        .sheet(isPresented: $showProfile) {
            NavigationView {
                CharacterProfileView(profileType: profileTypeFromConversation) {
                    // 开始聊天回调（已经在聊天界面，所以关闭资料卡即可）
                    showProfile = false
                }

                if showReportMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showReportMenu = false
                        }
                        .zIndex(9)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showReportForm) {
            ReportSheet(
                characterName: conversation.name,
                reportText: $reportText,
                onSubmit: {
                    reportText = ""
                    showReportForm = false
                },
                onCancel: {
                    reportText = ""
                    showReportForm = false
                }
            )
        }
        .alert("Not enough diamonds", isPresented: $showInsufficientDiamonds) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(insufficientDiamondsMessage)
        }
    }
    
    // 从 Conversation 创建 ProfileType
    private var profileTypeFromConversation: CharacterProfileView.ProfileType {
        switch conversation.type {
        case .character(let char):
            return .character(char)
        case .story(let story):
            return .story(story)
        case .privateCharacter(let char):
            return .privateCharacter(char)
        }
    }
    
    // MARK: - 顶部导航栏
    private var chatHeaderView: some View {
        HStack(spacing: 12) {
            // 返回按钮
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            // 角色头像（优先使用 background image）
            CachedAsyncImage(urlString: conversation.backgroundImage ?? conversation.avatar) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(AppColors.cardBackground.opacity(0.8))
                    .frame(width: 44, height: 44)
            }
            
            // 角色名称（可点击进入资料卡）
            Button(action: {
                showProfile = true
            }) {
                Text(conversation.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 16) {
                Button(action: {
                    showPaywall = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.accentPrimary)
                        Text("\(authService.currentUser?.diamonds ?? 0)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.cardBackground.opacity(0.8))
                    .clipShape(Capsule())
                }
                
                Button(action: {
                    showReportMenu.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if showReportMenu {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        showReportMenu = false
                        showProfile = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textPrimary)
                            Text("View profile")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }

                    Divider()
                        .background(AppColors.border.opacity(0.6))

                    Button(action: {
                        showReportMenu = false
                        showReportForm = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Report")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                }
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border.opacity(0.6), lineWidth: 1)
                )
                .frame(width: 145)
                .shadow(color: AppColors.background.opacity(0.7), radius: 12, x: 0, y: 6)
                .offset(x: 0, y: 42)
                .zIndex(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    
    // MARK: - 输入栏
    private var inputBarView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // 快捷输入按钮
                Button(action: {
                    // 快捷输入
                }) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20))
                    .foregroundColor(AppColors.accentSecondary)
                }
                
                // 输入框
                TextField("Type a message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.cardBackground)
                    .cornerRadius(20)
                    .lineLimit(1...4)
                
                // 发送按钮
                Button(action: {
                    sendMessage()
                }) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textPrimary))
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(inputText.isEmpty ? AppColors.textMuted : AppColors.accentPrimary)
                    }
                }
                .disabled(inputText.isEmpty || isSending)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(AppColors.background.opacity(0.85))
        }
    }
    
    // MARK: - 方法
    private func loadMessages() {
        // 从持久化存储加载消息
        if let userId = authService.currentUser?.id {
            let savedMessages = MessageStorageService.shared.loadMessages(conversationId: conversation.id, userId: userId)
            if !savedMessages.isEmpty {
                messages = savedMessages
                return
            }
        }
        
        // 如果是新对话，发送招呼语
        if messages.isEmpty, let greeting = conversation.greetingMessage, !greeting.isEmpty {
            let greetingMessage = ChatMessage(role: "assistant", content: greeting)
            messages.append(greetingMessage)
            // 保存招呼语
            if let userId = authService.currentUser?.id {
                MessageStorageService.shared.addMessage(greetingMessage, conversationId: conversation.id, userId: userId)
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let cost = authService.chatCostAmount()
        guard authService.spendDiamonds(cost) else {
            insufficientDiamondsMessage = "Each chat message costs \(cost) diamonds. Please top up to continue."
            showInsufficientDiamonds = true
            return
        }
        
        let userMessage = ChatMessage(role: "user", content: inputText)
        messages.append(userMessage)
        
        let messageText = inputText
        guard let userId = authService.currentUser?.id else {
            print("❌ 用户未登录，无法发送消息")
            return
        }
        
        // 保存用户消息
        MessageStorageService.shared.addMessage(userMessage, conversationId: conversation.id, userId: userId)
        
        // 先更新用户消息为最后一条消息（如果AI回复失败，至少显示用户的消息）
        ConversationStorageService.shared.updateLastMessage(conversationId: conversation.id, message: messageText, userId: userId)
        inputText = ""
        isSending = true
        
        // 获取最近的消息历史（限制长度以提高性能）
        let recentHistory = MessageStorageService.shared.getRecentMessages(conversationId: conversation.id, userId: userId, limit: 10)
        
        // 根据对话类型发送消息
        switch conversation.type {
        case .character(let character):
            DeepSeekService.shared.sendMessage(to: character, message: messageText, conversationHistory: recentHistory) { result in
                DispatchQueue.main.async {
                    isSending = false
                    switch result {
                    case .success(let response):
                        let assistantMessage = ChatMessage(role: "assistant", content: response)
                        messages.append(assistantMessage)
                        // 保存AI回复
                        MessageStorageService.shared.addMessage(assistantMessage, conversationId: conversation.id, userId: userId)
                        // 更新对话的最后一条消息
                        ConversationStorageService.shared.updateLastMessage(conversationId: conversation.id, message: response, userId: userId)
                    case .failure(let error):
                        print("发送消息失败: \(error)")
                    }
                }
            }
        case .story(let story):
            DeepSeekService.shared.sendMessage(to: story, message: messageText, conversationHistory: recentHistory) { result in
                DispatchQueue.main.async {
                    isSending = false
                    switch result {
                    case .success(let response):
                        let assistantMessage = ChatMessage(role: "assistant", content: response)
                        messages.append(assistantMessage)
                        // 保存AI回复
                        MessageStorageService.shared.addMessage(assistantMessage, conversationId: conversation.id, userId: userId)
                        // 更新对话的最后一条消息
                        ConversationStorageService.shared.updateLastMessage(conversationId: conversation.id, message: response, userId: userId)
                    case .failure(let error):
                        print("发送消息失败: \(error)")
                    }
                }
            }
        case .privateCharacter(let character):
            DeepSeekService.shared.sendMessage(to: character, message: messageText, conversationHistory: recentHistory) { result in
                DispatchQueue.main.async {
                    isSending = false
                    switch result {
                    case .success(let response):
                        let assistantMessage = ChatMessage(role: "assistant", content: response)
                        messages.append(assistantMessage)
                        // 保存AI回复
                        MessageStorageService.shared.addMessage(assistantMessage, conversationId: conversation.id, userId: userId)
                        // 更新对话的最后一条消息
                        ConversationStorageService.shared.updateLastMessage(conversationId: conversation.id, message: response, userId: userId)
                    case .failure(let error):
                        print("发送消息失败: \(error)")
                    }
                }
            }
        }
    }
}

struct ReportSheet: View {
    let characterName: String
    @Binding var reportText: String
    let onSubmit: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Report \(characterName)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Tell us what happened. This report is for moderation review.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)

                    TextEditor(text: $reportText)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(12)
                        .frame(height: 120)
                        .scrollContentBackground(.hidden)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)

                    Button(action: {
                        onSubmit()
                        dismiss()
                    }) {
                        Text("Submit report")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
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
                    .disabled(reportText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(reportText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)

                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - 角色介绍消息气泡
struct NarrativeMessageBubble: View {
    let text: String
    let characterName: String
    let characterAvatar: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                // 介绍文本（左对齐）
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85) // 限制宽度为屏幕的85%
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColors.cardBackground.opacity(0.9))
            )
            
            Spacer()
        }
    }
}

// MARK: - 消息气泡
struct MessageBubble: View {
    let message: ChatMessage
    let characterName: String
    let characterAvatar: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == "assistant" {
                // 角色消息（左侧）- 左下和右上圆角大，左上和右下圆角小
                HStack {
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.cardBackground.opacity(0.95))
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    topLeading: 8,
                                    bottomLeading: 20,
                                    bottomTrailing: 8,
                                    topTrailing: 20
                                )
                            )
                        )
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 2/3)
                
                Spacer()
            } else {
                // 用户消息（右侧）- 左下和右上圆角大，左上和右下圆角小
                Spacer()
                
                HStack {
                    Spacer(minLength: 0)
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.accentPrimary)
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    topLeading: 20,
                                    bottomLeading: 8,
                                    bottomTrailing: 20,
                                    topTrailing: 8
                                )
                            )
                        )
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 2/3)
            }
        }
    }
}

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}

