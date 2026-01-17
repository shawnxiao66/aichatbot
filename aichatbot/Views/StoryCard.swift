//
//  StoryCard.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

struct StoryCard: View {
    let story: Story
    var onStartChat: ((Story) -> Void)? = nil // 开始对话回调
    var onViewProfile: ((Story) -> Void)? = nil // 查看资料卡回调
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 封面图片 - 占满整个卡片（使用缓存）
            CachedAsyncImage(urlString: story.cover) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(AppColors.cardBackground.opacity(0.8))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                            .scaleEffect(0.8)
                    )
            }
            .aspectRatio(9/16, contentMode: .fit)
            .clipped()
            
            // 渐变遮罩层，让文字更清晰
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    AppColors.background.opacity(0.3),
                    AppColors.background.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .aspectRatio(9/16, contentMode: .fit)
            
            // 角色名称（左上角）
            if !story.characterName.isEmpty {
                VStack {
                    HStack {
                        Text(story.characterName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.background.opacity(0.7))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            // 文字信息 - 叠加在图片底部
            VStack(alignment: .leading, spacing: 6) {
                // 标题
                Text(story.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                
                // 人气（带图标）
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                    Text("\(formatPopularity(story.popularity))")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // 描述
                Text(story.description)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .aspectRatio(9/16, contentMode: .fit) // 竖图长方形比例
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            // 打开资料卡
            onViewProfile?(story)
        }
    }
    
    private func formatPopularity(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000.0)
        }
        return "\(count)"
    }
}

#Preview {
    StoryCard(story: SampleData.stories[0])
        .preferredColorScheme(.dark)
        .padding()
        .background(AppColors.background)
}

