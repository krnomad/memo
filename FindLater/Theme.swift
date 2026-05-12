import SwiftUI

enum MullTheme {
    static let paper = Color(hex: 0xF6F2EA)
    static let paperLight = Color(hex: 0xFBF8F2)
    static let paperGrouped = Color(hex: 0xEFE9DD)
    static let paperLine = Color(hex: 0xE5DDCC)
    static let ink = Color(hex: 0x1B1A17)
    static let inkSecondary = Color(hex: 0x3A3833)
    static let inkTertiary = Color(hex: 0x6E695E)
    static let inkDisabled = Color(hex: 0xA29C8E)
    static let terracotta = Color(hex: 0xC46A3D)
    static let terracottaSoft = Color(hex: 0xFBEFE6)
    static let sage = Color(hex: 0x6E8B5A)
    static let sageSoft = Color(hex: 0xDDE5D6)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension MemoCategory {
    var tint: Color {
        switch self {
        case .work:
            Color.blue
        case .troubleshooting:
            MullTheme.terracotta.opacity(0.88)
        case .idea:
            MullTheme.terracotta
        case .personal:
            MullTheme.inkTertiary
        }
    }
}

extension Date {
    var memoDateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return self.formatted(date: .omitted, time: .shortened)
        }
        if calendar.isDateInYesterday(self) {
            return "어제"
        }
        return self.formatted(.dateTime.month().day())
    }
}
