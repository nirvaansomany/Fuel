import SwiftUI

// MARK: - Colors

enum FuelColor {
    static let background = Color("Background")
    static let cardBackground = Color("CardBackground")
    static let cardBorder = Color.white.opacity(0.08)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let accent = Color.accentColor
    static let macroCalories = Color(red: 0.40, green: 0.77, blue: 0.97)
    static let macroProtein = Color(red: 0.41, green: 0.86, blue: 0.69)
    static let macroCarbs = Color(red: 0.74, green: 0.70, blue: 0.99)
    static let macroFat = Color(red: 0.99, green: 0.64, blue: 0.77)
}

// MARK: - Spacing

enum FuelSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Radius

enum FuelRadius {
    static let card: CGFloat = 24
    static let pill: CGFloat = 999
}

// MARK: - Shadows

enum FuelShadow {
    static let card = Color.black.opacity(0.6)
}

// MARK: - Background

struct FuelBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 7 / 255, green: 16 / 255, blue: 35 / 255),
                Color(red: 3 / 255, green: 8 / 255, blue: 20 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}


