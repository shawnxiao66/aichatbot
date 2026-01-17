//
//  CharacterCard.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import SwiftUI

struct CharacterCard: View {
    let character: Character
    var contentAlignment: HorizontalAlignment = .leading // 内容对齐方式
    var onStartChat: ((Character) -> Void)? = nil // 开始对话回调
    var onViewProfile: ((Character) -> Void)? = nil // 查看资料卡回调
    
    // 根据category判断是横图还是竖图
    private var isLandscape: Bool {
        character.category == "featured"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isTextLeading = contentAlignment == .leading
            let imageWidth = geometry.size.width * 0.48
            let panelColor = AppColors.cardBackground
            let maskStopsFadeToTrailing: [Gradient.Stop] = [
                .init(color: .black, location: 0.0),
                .init(color: .black, location: 0.6),
                .init(color: .clear, location: 0.88),
                .init(color: .clear, location: 1.0)
            ]
            let maskStopsFadeToLeading: [Gradient.Stop] = [
                .init(color: .clear, location: 0.0),
                .init(color: .clear, location: 0.12),
                .init(color: .black, location: 0.4),
                .init(color: .black, location: 1.0)
            ]

            ZStack(alignment: .bottom) {
                if isLandscape {
                    ZStack {
                        panelColor
                        HStack(spacing: 0) {
                            if isTextLeading {
                                Spacer(minLength: 0)
                                characterImageView(width: imageWidth, height: geometry.size.height)
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: maskStopsFadeToLeading),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            } else {
                                characterImageView(width: imageWidth, height: geometry.size.height)
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: maskStopsFadeToTrailing),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Spacer(minLength: 0)
                            }
                        }
                    }
                } else {
                    characterImageView(width: geometry.size.width, height: geometry.size.height)
                }
                
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
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                // 文字和按钮内容 - 叠加在图片上方，文字始终左对齐，但位置左右交替
                HStack(spacing: 0) {
                    if contentAlignment == .leading {
                        // 文字区域在左边：左边占0.65，右边留0.35
                        VStack(alignment: .leading, spacing: 8) {
                            // 角色名称和性别图标，以及人气（同一行，人气靠右）
                            HStack {
                                HStack(spacing: 8) {
                                    Text(character.name)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Image(systemName: character.gender == "female" ? "person.fill" : "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text("\(formatPopularity(character.popularity)) \(String(localized: "chats", comment: "Number of chats"))")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            // 标签（纯文字样式）
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(character.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textMuted)
                                    }
                                }
                            }
                            
                            // 描述 - 固定4行高度
                            Text(character.description)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(4)
                                .frame(height: 80, alignment: .top) // 固定4行高度 (14 * 1.2 * 4 ≈ 67, 加上行间距约80)
                                .multilineTextAlignment(.leading)
                            
                            // 操作按钮
                            HStack(spacing: 8) {
                                Button(action: {
                                    onStartChat?(character)
                                }) {
                                    Text("Chat")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
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
                                
                                Button(action: {
                                    onViewProfile?(character)
                                }) {
                                    Text("Album")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.accentSecondary.opacity(0.6),
                                                    AppColors.accentPrimary.opacity(0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 16)
                        .frame(width: geometry.size.width * 0.65, alignment: .leading)
                        
                        // 右边留0.35空白
                        Spacer()
                    } else {
                        // 文字区域在右边：右边占0.65，左边留0.35，但文字内容仍然左对齐
                        // 左边留0.35空白
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            // 角色名称和性别图标，以及人气（同一行，人气靠右）
                            HStack {
                                HStack(spacing: 8) {
                                    Text(character.name)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Image(systemName: character.gender == "female" ? "person.fill" : "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text("\(formatPopularity(character.popularity)) \(String(localized: "chats", comment: "Number of chats"))")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            // 标签（纯文字样式）
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(character.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textMuted)
                                    }
                                }
                            }
                            
                            // 描述 - 固定4行高度
                            Text(character.description)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(4)
                                .frame(height: 80, alignment: .top) // 固定4行高度 (14 * 1.2 * 4 ≈ 67, 加上行间距约80)
                                .multilineTextAlignment(.leading)
                            
                            // 操作按钮
                            HStack(spacing: 8) {
                                Button(action: {
                                    onStartChat?(character)
                                }) {
                                    Text("Chat")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
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
                                
                                Button(action: {
                                    onViewProfile?(character)
                                }) {
                                    Text("Album")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    AppColors.accentSecondary.opacity(0.6),
                                                    AppColors.accentPrimary.opacity(0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 16)
                        .frame(width: geometry.size.width * 0.65, alignment: .leading)
                    }
                }
            }
        }
        .aspectRatio(isLandscape ? 5/3.2 : 9/16, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: AppColors.background.opacity(0.45), radius: 8, x: 0, y: 4)
    }
    
    private func formatPopularity(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000.0)
        }
        return "\(count)"
    }

    private func characterImageView(width: CGFloat, height: CGFloat) -> some View {
        CachedAsyncImage(urlString: character.avatar) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
        } placeholder: {
            Rectangle()
                .fill(AppColors.cardBackground.opacity(0.8))
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentPrimary))
                        .scaleEffect(0.8)
                )
        }
        .frame(width: width, height: height)
        .clipped()
    }
}

#Preview {
    CharacterCard(character: SampleData.featuredCharacters[0])
        .preferredColorScheme(.dark)
        .padding()
        .background(AppColors.background)
}

