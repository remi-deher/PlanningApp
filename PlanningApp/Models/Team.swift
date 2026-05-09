import SwiftUI

struct Team: Identifiable, Codable {
    var id = UUID()
    var name: String
    var colorHex: String
    var icon: String
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// Helper to use Hex colors in SwiftUI
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// Mock Data
extension Team {
    static let mockTeams = [
        Team(name: "Équipe Jour", colorHex: "#FF9500", icon: "sun.max.fill"),
        Team(name: "Équipe Nuit", colorHex: "#5856D6", icon: "moon.fill"),
        Team(name: "Équipe Support", colorHex: "#34C759", icon: "lifepreserver.fill")
    ]
}
