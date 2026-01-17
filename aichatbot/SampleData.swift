//
//  SampleData.swift
//  aichatbot
//
//  Created for AI Chatbot App
//

import Foundation

struct SampleData {
    // Featured characters data (based on UI examples)
    static let featuredCharacters: [Character] = [
        Character(
            name: "萧晗晗",
            avatar: "https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=萧晗晗",
            popularity: 482000,
            tags: ["风流", "潇洒", "任性", "狮子座"],
            description: "京圈里绯闻甚多,经常出没于娱乐场所,直到有一次去酒吧,遇到了酒吧打工的你,彼此的羁绊开始了",
            gender: "female"
        ),
        Character(
            name: "初空",
            avatar: "https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=初空",
            popularity: 478000,
            tags: ["痞坏", "不羁", "暗黑", "双子座"],
            description: "大三在读生,是你现任男友的亲弟弟,常年戴着黑色耳钉和银色吊坠。在你面前毫不掩饰本性,笑里总带着一丝邪气。",
            gender: "male"
        ),
        Character(
            name: "多多",
            avatar: "https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=多多",
            popularity: 465000,
            tags: ["可爱", "娇小", "萝莉", "处女座"],
            description: "多多,长相可爱,很爱撒娇。你是她暗恋的人,多多经常会约你一起散步回家。",
            gender: "female"
        )
    ]
    
    // Stories data (based on UI examples)
    static let stories: [Story] = [
        Story(
            title: "与总裁分手后",
            cover: "https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事1",
            popularity: 78000,
            description: "你追他又甩了他,他说不会放过你。",
            characterName: "卓文尧",
            gender: "male"
        ),
        Story(
            title: "我成了当红明星的经纪",
            cover: "https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事2",
            popularity: 61000,
            description: "绯闻不断,通告不停,这个毒舌又傲娇的大明星,",
            characterName: "裴一",
            gender: "male"
        ),
        Story(
            title: "网恋对象竟是我老板",
            cover: "https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事3",
            popularity: 53000,
            description: "好消息:网恋了。坏消息:网恋对象是老板。",
            characterName: "道明寺",
            gender: "male"
        ),
        Story(
            title: "前任又作妖",
            cover: "https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事4",
            popularity: 47000,
            description: "失业卖炸串,却被前仕盯上了。",
            characterName: "林嘉豪",
            gender: "male"
        )
    ]
    
    // Private characters data (examples)
    static let privateCharacters: [Character] = [
        Character(
            name: "Private Character 1",
            avatar: "https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=Private1",
            popularity: 10000,
            tags: ["Private", "Exclusive"],
            description: "This is your private character",
            gender: "female",
            category: "private"
        )
    ]
}

