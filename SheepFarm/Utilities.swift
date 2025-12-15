import SwiftUI

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Colors
struct GameColors {
    static let skyBlue = Color(hex: "87CEEB")
    static let lightSky = Color(hex: "E0F6FF")
    static let grass = Color(hex: "98FB98")
    static let darkGreen = Color(hex: "2F4F4F")
    static let forestGreen = Color(hex: "2c5f2d")
    static let gold = Color(hex: "FFD700")
    static let darkGold = Color(hex: "DAA520")
    static let beige = Color(hex: "F5F5DC")
    static let wheat = Color(hex: "FFF8DC")
    static let brown = Color(hex: "8B4513")
    static let steelBlue = Color(hex: "4682B4")
    static let springGreen = Color(hex: "228B22")
    static let limeGreen = Color(hex: "32CD32")
    static let lightBlue = Color(hex: "E6F3FF")
    static let tan = Color(hex: "DEB887")
    static let darkText = Color(hex: "1a1a1a")
    static let mediumText = Color(hex: "333333")
}

// MARK: - Number Formatting Extension
extension Double {
    func formatNumber() -> String {
        if self >= 1_000_000_000_000 {
            return String(format: "%.2fT", self / 1_000_000_000_000)
        } else if self >= 1_000_000_000 {
            return String(format: "%.2fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.2fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.2fK", self / 1_000)
        } else if self >= 1 {
            return String(format: "%.2f", self)
        } else {
            return String(format: "%.4f", self)
        }
    }
    
    func formatCurrency() -> String {
        return self.formatNumber() + " kr"
    }
    
    func formatCompact() -> String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        } else {
            return String(format: "%.0f", self)
        }
    }
}

// MARK: - Custom Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
