import SwiftUI

enum AppColors {
    static let background = Color(hex: 0x0F1115)
    static let cardBackground = Color(hex: 0x1A1D24)
    static let border = Color(hex: 0x2A2F3A)

    static let textPrimary = Color(hex: 0xF2F4F8)
    static let textSecondary = Color(hex: 0xB3BAC7)
    static let textMuted = Color(hex: 0x7D8696)

    static let accentPrimary = Color(hex: 0x5B8DEF)
    static let accentSecondary = Color(hex: 0x8E72FF)

    static let success = Color(hex: 0x38A169)
    static let warning = Color(hex: 0xD69E2E)
    static let error = Color(hex: 0xE53E3E)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
