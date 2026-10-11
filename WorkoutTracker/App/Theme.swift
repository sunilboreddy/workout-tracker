import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    static let background = Color(hex: 0x0F0F12)
    static let secondary = Color(hex: 0x141420)
    static let card = Color(hex: 0x181820)
    static let accent = Color(hex: 0xC4F600)
    static let warm = Color(hex: 0xFF3B6B)
    static let text = Color.white
    static let textSecondary = Color(hex: 0xB8BCC4)
    static let textMuted = Color(hex: 0x6B6B76)
    static let border = Color(hex: 0x23232E)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
}

struct AccentButtonStyle: ButtonStyle {
    var destructive = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(destructive ? Color.white : Color.black)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(destructive ? Theme.warm : Theme.accent)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    var tint: Color = Theme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .overlay(Capsule().stroke(tint, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
