import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Background colours
    static let dmtBackground = Color(hex: "#0A0A0A")
    static let dmtSurface = Color(hex: "#141414")
    static let dmtCard = Color(hex: "#1A1A1A")
    static let dmtBorder = Color(hex: "#333333")

    // Text colours
    static let dmtPrimaryText = Color(hex: "#F5F5F3")
    static let dmtMutedText = Color(hex: "#888888")

    // Accent colours
    static let dmtGold = Color(hex: "#C9A84C")
    static let dmtGoldLight = Color(hex: "#E8C97A")
    static let dmtCrimson = Color(hex: "#8B3A3A")
    static let dmtSage = Color(hex: "#3A6B4A")

    // Initialiser from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Font Extensions
extension Font {
    static func dmtDisplay(_ size: CGFloat) -> Font {
        return Font.custom("Georgia", size: size).weight(.light)
    }

    static func dmtHeading(_ size: CGFloat) -> Font {
        return Font.custom("Georgia", size: size).weight(.regular)
    }

    static func dmtLabel(_ size: CGFloat) -> Font {
        return Font.system(size: size, weight: .medium, design: .default)
    }

    static func dmtBody(_ size: CGFloat) -> Font {
        return Font.system(size: size, weight: .regular, design: .default)
    }
}

// MARK: - Spacing Constants
enum AppTheme {
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXL: CGFloat = 32

    static let cornerRadius: CGFloat = 4
    static let borderWidth: CGFloat = 1

    static let avatarSize: CGFloat = 44
    static let statusDotSize: CGFloat = 6
    static let progressBarHeight: CGFloat = 2

    static let goldGradient = LinearGradient(
        colors: [.dmtGold, .dmtGoldLight],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - View Modifiers
struct DMTCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.dmtCard)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
            )
    }
}

struct DMTGoldTopBorderCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.dmtCard)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                VStack {
                    Rectangle()
                        .fill(Color.dmtGold)
                        .frame(height: AppTheme.borderWidth)
                    Spacer()
                },
                alignment: .top
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
            )
    }
}

struct DMTLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.dmtLabel(9))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundColor(.dmtMutedText)
    }
}

extension View {
    func dmtCard() -> some View {
        modifier(DMTCardStyle())
    }

    func dmtGoldTopCard() -> some View {
        modifier(DMTGoldTopBorderCard())
    }

    func dmtLabel() -> some View {
        modifier(DMTLabelStyle())
    }
}
