import SwiftUI
import Combine

// MARK: - ThemeManager
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var accentColor: Color {
        didSet { saveColors() }
    }

    @Published var backgroundColor: Color {
        didSet { saveColors() }
    }

    private let accentKey = "themeAccentHex"
    private let backgroundKey = "themeBackgroundHex"

    private init() {
        let savedAccent = UserDefaults.standard.string(forKey: "themeAccentHex") ?? "#C9A84C"
        let savedBackground = UserDefaults.standard.string(forKey: "themeBackgroundHex") ?? "#0A0A0A"
        self.accentColor = Color(hex: savedAccent)
        self.backgroundColor = Color(hex: savedBackground)
    }

    private func saveColors() {
        // Store as hex by converting back via UIColor
        UserDefaults.standard.set(accentColor.hexString, forKey: accentKey)
        UserDefaults.standard.set(backgroundColor.hexString, forKey: backgroundKey)
    }

    func resetToDefaults() {
        accentColor = Color(hex: "#C9A84C")
        backgroundColor = Color(hex: "#0A0A0A")
    }
}

extension Color {
    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Environment Key
private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
