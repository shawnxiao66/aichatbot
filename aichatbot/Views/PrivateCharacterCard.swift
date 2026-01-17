//
//  PrivateCharacterCard.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

struct PrivateCharacterCard: View {
    let character: PrivateCharacter
    var onStartChat: ((PrivateCharacter) -> Void)? = nil // 开始对话回调
    var onViewProfile: ((PrivateCharacter) -> Void)? = nil // 查看资料卡回调
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // 角色图片 - 占满整个卡片（使用缓存）
                if let avatarURL = character.avatar, !avatarURL.isEmpty {
                    CachedAsyncImage(urlString: avatarURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } placeholder: {
                        Rectangle()
                            .fill(AppColors.cardBackground.opacity(0.8))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                            )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                } else {
                    // 没有图片时显示占位符
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.accentSecondary.opacity(0.6),
                                    AppColors.accentPrimary.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // 渐变遮罩层（底部），让名字更清晰
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        AppColors.background.opacity(0.6)
                    ]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                // 角色名字 - 左下角
                Text(character.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.background.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
            }
        }
        .aspectRatio(9/16, contentMode: .fit) // 竖图比例
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            // 打开资料卡
            onViewProfile?(character)
        }
    }
}

#Preview {
    PrivateCharacterCard(character: PrivateCharacter(
        name: "测试角色",
        avatar: nil,
        description: "这是一个测试角色",
        gender: "female"
    ))
    .preferredColorScheme(.dark)
    .padding()
    .background(AppColors.background)
}

