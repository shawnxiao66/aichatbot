//
//  DiscoverView.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI
import UIKit

struct DiscoverView: View {
    @State private var selectedTab: TabType = .featured
    @State private var searchText: String = ""
    @State private var characters: [Character] = []
    @State private var allCharacters: [Character] = []
    @State private var privateCharacters: [PrivateCharacter] = []
    @State private var allPrivateCharacters: [PrivateCharacter] = []
    @State private var stories: [Story] = []
    @State private var allStories: [Story] = []
    @State private var isLoading: Bool = false
    @State private var showCreateCharacter: Bool = false
    @State private var selectedConversation: Conversation? = nil
    @State private var selectedProfile: CharacterProfileView.ProfileType? = nil
    @State private var preferredGender: String = "female"
    private let preferredGenderKey = "preferred_character_gender"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // 搜索栏
                    searchBarView
                    
                    // 标签切换栏
                    tabBarView
                    
                    // 内容区域
                    contentView
                }
                .background(AppColors.background.ignoresSafeArea())
                .onAppear {
                    configureSegmentedControlAppearance()
                    loadPreferredGender()
                    loadData()
                }
                .onChange(of: preferredGender) { _ in
                    savePreferredGender()
                    applySearch(searchText)
                }
                
                // 浮动创建按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreateCharacter = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 56, height: 56)
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
                                .clipShape(Circle())
                                .shadow(color: AppColors.background.opacity(0.6), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 90) // 动态计算底部间距
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateCharacter) {
            CreateCharacterView(onCharacterCreated: { createdCharacter in
                // 创建成功后清除缓存并刷新 private 角色数据
                // 无论当前在哪个标签，都需要刷新，以便用户切换到 private 标签时能看到新角色
                if let userId = AuthService.shared.currentUser?.id {
                    // 清除缓存，确保获取最新数据
                    CacheService.shared.clearPrivateCharactersCache(for: userId)
                    // 强制刷新数据
                    SupabaseService.shared.fetchPrivateCharacters(userId: userId) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let fetchedCharacters):
                                self.privateCharacters = fetchedCharacters
                                self.allPrivateCharacters = fetchedCharacters
                                // 如果当前在 private 标签，应用搜索过滤
                                if self.selectedTab == .privateTab {
                                    self.applySearch(self.searchText)
                                }
                            case .failure(let error):
                                print("加载私人角色失败: \(error)")
                            }
                        }
                    }
                }
                // 创建成功后直接进入聊天，并切到 Private 标签
                selectedTab = .privateTab
                let conversation = Conversation.from(character: createdCharacter)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedConversation = conversation
                }
            })
        }
        .fullScreenCover(item: $selectedConversation) { conversation in
            let _ = print("📱 fullScreenCover 显示，对话: \(conversation.name)")
            ChatDetailView(conversation: conversation)
        }
        .sheet(item: $selectedProfile) { profileType in
            NavigationView {
                CharacterProfileView(
                    profileType: profileType,
                    onStartChat: {
                        startChat(from: profileType)
                    },
                    onEdit: {
                        loadData(forceRefresh: true)
                    },
                    onDelete: {
                        loadData(forceRefresh: true)
                    }
                )
            }
            .presentationBackground(.clear)
        }
    }
    
    // MARK: - 搜索栏
    private var searchBarView: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textMuted)
                
                TextField(
                    "Search",
                    text: $searchText
                )
                .foregroundColor(AppColors.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchText) { newValue in
                    applySearch(newValue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppColors.cardBackground)
            .cornerRadius(20)
            
            Picker("", selection: $preferredGender) {
                Text("Female").tag("female")
                Text("Male").tag("male")
            }
            .pickerStyle(.segmented)
            .font(.system(size: 13, weight: .semibold))
            .tint(AppColors.accentSecondary)
            .frame(width: 120)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.background)
    }
    
    // MARK: - 标签栏
    private var tabBarView: some View {
        HStack(spacing: 0) {
            ForEach(TabType.allCases, id: \.self) { tab in
                Button(action: {
                    let previousTab = selectedTab
                    selectedTab = tab
                    // 只有切换标签时才重新加载，相同标签不重新加载
                    if previousTab != tab {
                        loadData()
                    } else {
                        applySearch(searchText)
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == tab ? AppColors.accentPrimary : AppColors.textMuted)
                        
                        if selectedTab == tab {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            AppColors.accentPrimary.opacity(0.9),
                                            AppColors.accentSecondary.opacity(0.9)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 2)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background(AppColors.background)
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        TabView(selection: $selectedTab) {
            featuredTabView
                .tag(TabType.featured)
            storyTabView
                .tag(TabType.story)
            privateTabView
                .tag(TabType.privateTab)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(AppColors.background)
        .onChange(of: selectedTab) { _ in
            loadData()
        }
    }
    
    private var featuredTabView: some View {
        Group {
            if isLoading && selectedTab == .featured {
                ScrollView {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                        .padding(.top, 50)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        characterListView
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .background(AppColors.background)
    }
    
    private var privateTabView: some View {
        Group {
            if isLoading && selectedTab == .privateTab {
                ScrollView {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                        .padding(.top, 50)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        characterListView
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .background(AppColors.background)
    }
    
    private var storyTabView: some View {
        Group {
            if isLoading && selectedTab == .story {
                ScrollView {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                        .padding(.top, 50)
                }
            } else if stories.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.textMuted)
                        Text("No stories available")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textMuted)
                    }
                    .padding(.top, 100)
                }
            } else {
                ScrollView {
                    storyGridView
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
            }
        }
        .background(AppColors.background)
    }
    
    // MARK: - 角色列表视图
    private var characterListView: some View {
        Group {
            if selectedTab == .featured {
                // 精选角色：横图列表，只控制文字信息的左右交替
                ForEach(Array(characters.enumerated()), id: \.element.id) { index, character in
                    let isRightAligned = index % 2 == 0 // 偶数索引（0,2,4...）信息靠右
                    CharacterCard(
                        character: character,
                        contentAlignment: isRightAligned ? .trailing : .leading,
                        onStartChat: { character in
                            print("🔄 准备打开聊天界面，角色: \(character.name)")
                            let conversation = Conversation.from(character: character)
                            print("📝 创建的对话: \(conversation.name), 背景图: \(conversation.backgroundImage ?? "无")")
                            // 直接设置 selectedConversation，fullScreenCover 会自动显示
                            selectedConversation = conversation
                            print("✅ selectedConversation 已设置: \(conversation.name)")
                        },
                        onViewProfile: { character in
                            selectedProfile = .character(character)
                        }
                    )
                }
            } else {
                // 私人角色：竖图网格（2列），简化显示
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(privateCharacters) { character in
                        PrivateCharacterCard(
                            character: character,
                            onStartChat: { character in
                                selectedConversation = Conversation.from(character: character)
                            },
                            onViewProfile: { character in
                                selectedProfile = .privateCharacter(character)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - 故事网格视图
    private var storyGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            ForEach(stories) { story in
                StoryCard(
                    story: story,
                    onStartChat: { story in
                        selectedConversation = Conversation.from(story: story)
                    },
                    onViewProfile: { story in
                        selectedProfile = .story(story)
                    }
                )
            }
        }
    }
    
    // MARK: - 方法
    private func loadData(forceRefresh: Bool = false) {
        // 如果不是强制刷新，先显示缓存数据
        if !forceRefresh {
            switch selectedTab {
            case .featured:
                if let cached = CacheService.shared.getCachedCharacters(category: "featured") {
                    self.characters = cached
                    self.isLoading = false
                    // 后台刷新
                    refreshDataInBackground()
                    return
                }
            case .story:
                if let cached = CacheService.shared.getCachedStories() {
                    self.stories = cached
                    self.isLoading = false
                    // 后台刷新
                    refreshDataInBackground()
                    return
                }
            case .privateTab:
                if let userId = AuthService.shared.currentUser?.id,
                   let cached = CacheService.shared.getCachedPrivateCharacters(userId: userId) {
                    self.privateCharacters = cached
                    self.allPrivateCharacters = cached
                    self.isLoading = false
                    // 后台刷新
                    refreshDataInBackground()
                    return
                }
            }
        }
        
        isLoading = true
        
        switch selectedTab {
        case .featured:
            SupabaseService.shared.fetchCharacters(category: "featured") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedCharacters):
                        self.characters = fetchedCharacters
                        self.allCharacters = fetchedCharacters
                    case .failure(let error):
                        print("加载角色失败: \(error)")
                        // 失败时使用示例数据
                        self.characters = SampleData.featuredCharacters
                        self.allCharacters = SampleData.featuredCharacters
                    }
                    self.applySearch(self.searchText)
                    self.isLoading = false
                }
            }
        case .story:
            SupabaseService.shared.fetchStories { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedStories):
                        print("成功加载 \(fetchedStories.count) 个故事")
                        for story in fetchedStories {
                            print("故事: \(story.title), 封面URL: \(story.cover)")
                        }
                        self.stories = fetchedStories
                        self.allStories = fetchedStories
                    case .failure(let error):
                        print("加载故事失败: \(error)")
                        // 失败时使用示例数据
                        print("使用示例数据，共 \(SampleData.stories.count) 个故事")
                        for story in SampleData.stories {
                            print("示例故事: \(story.title), 封面URL: \(story.cover)")
                        }
                        self.stories = SampleData.stories
                        self.allStories = SampleData.stories
                    }
                    self.applySearch(self.searchText)
                    self.isLoading = false
                }
            }
        case .privateTab:
            // 获取当前登录用户ID
            if let userId = AuthService.shared.currentUser?.id {
                SupabaseService.shared.fetchPrivateCharacters(userId: userId) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedCharacters):
                        self.privateCharacters = fetchedCharacters
                        self.allPrivateCharacters = fetchedCharacters
                        case .failure(let error):
                            print("加载私人角色失败: \(error)")
                        self.privateCharacters = []
                        self.allPrivateCharacters = []
                        }
                        self.applySearch(self.searchText)
                        self.isLoading = false
                    }
                }
            } else {
                // 未登录时显示空列表
                DispatchQueue.main.async {
                    self.privateCharacters = []
                    self.allPrivateCharacters = []
                    self.applySearch(self.searchText)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func startChat(from profileType: CharacterProfileView.ProfileType) {
        // 关闭资料页后再进入聊天，避免返回时回到资料页
        selectedProfile = nil
        
        let conversation: Conversation
        switch profileType {
        case .character(let char):
            selectedTab = .featured
            conversation = Conversation.from(character: char)
        case .story(let story):
            selectedTab = .story
            conversation = Conversation.from(story: story)
        case .privateCharacter(let char):
            selectedTab = .privateTab
            conversation = Conversation.from(character: char)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedConversation = conversation
        }
    }
    
    // 后台刷新数据（不显示loading）
    private func refreshDataInBackground() {
        switch selectedTab {
        case .featured:
            SupabaseService.shared.fetchCharacters(category: "featured") { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedCharacters) = result {
                        self.characters = fetchedCharacters
                        self.allCharacters = fetchedCharacters
                        self.applySearch(self.searchText)
                    }
                }
            }
        case .story:
            SupabaseService.shared.fetchStories { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedStories) = result {
                        self.stories = fetchedStories
                        self.allStories = fetchedStories
                        self.applySearch(self.searchText)
                    }
                }
            }
        case .privateTab:
            if let userId = AuthService.shared.currentUser?.id {
                SupabaseService.shared.fetchPrivateCharacters(userId: userId) { result in
                    DispatchQueue.main.async {
                        if case .success(let fetchedCharacters) = result {
                        self.privateCharacters = fetchedCharacters
                        self.allPrivateCharacters = fetchedCharacters
                        self.applySearch(self.searchText)
                        }
                    }
                }
            }
        }
    }
    
    private func applySearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let gender = preferredGender.lowercased()
        let filterCharacterGender: (String) -> Bool = { $0.lowercased() == gender }

        switch selectedTab {
        case .featured:
            let filtered = allCharacters.filter { filterCharacterGender($0.gender) }
            guard !trimmed.isEmpty else {
                characters = filtered
                return
            }
            let lowercased = trimmed.lowercased()
            characters = filtered.filter { character in
                let tags = character.tags.joined(separator: " ")
                let popularity = String(character.popularity)
                return [
                    character.name,
                    character.description,
                    tags,
                    popularity
                ].joined(separator: " ").lowercased().contains(lowercased)
            }
        case .story:
            let filtered = allStories.filter { filterCharacterGender($0.gender) }
            guard !trimmed.isEmpty else {
                stories = filtered
                return
            }
            let lowercased = trimmed.lowercased()
            stories = filtered.filter { story in
                let popularity = String(story.popularity)
                return [
                    story.title,
                    story.description,
                    story.characterName,
                    popularity
                ].joined(separator: " ").lowercased().contains(lowercased)
            }
        case .privateTab:
            let filtered = allPrivateCharacters.filter { filterCharacterGender($0.gender) }
            guard !trimmed.isEmpty else {
                privateCharacters = filtered
                return
            }
            let lowercased = trimmed.lowercased()
            privateCharacters = filtered.filter { character in
                [
                    character.name,
                    character.description
                ].joined(separator: " ").lowercased().contains(lowercased)
            }
        }
    }

    private func loadPreferredGender() {
        if let stored = UserDefaults.standard.string(forKey: preferredGenderKey),
           stored == "male" || stored == "female" {
            preferredGender = stored
        } else {
            preferredGender = "female"
        }
    }

    private func savePreferredGender() {
        UserDefaults.standard.set(preferredGender, forKey: preferredGenderKey)
    }

    private func configureSegmentedControlAppearance() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor(
            red: 0x5B / 255.0,
            green: 0x8D / 255.0,
            blue: 0xEF / 255.0,
            alpha: 1.0
        )
        appearance.backgroundColor = UIColor(
            red: 0x1A / 255.0,
            green: 0x1D / 255.0,
            blue: 0x24 / 255.0,
            alpha: 1.0
        )
        appearance.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(
                    red: 0x7D / 255.0,
                    green: 0x86 / 255.0,
                    blue: 0x96 / 255.0,
                    alpha: 1.0
                ),
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ],
            for: .normal
        )
        appearance.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(
                    red: 0xF2 / 255.0,
                    green: 0xF4 / 255.0,
                    blue: 0xF8 / 255.0,
                    alpha: 1.0
                ),
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ],
            for: .selected
        )
    }
}

#Preview {
    DiscoverView()
        .preferredColorScheme(.dark)
}

