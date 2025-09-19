//
//  Typography.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 15/08/2025.
//

import SwiftUI

enum AppTextStyles {
    case h1, h2, h3, h4, body, caption
}

private struct Typography {
    static func font(for style: AppTextStyles) -> Font {
        switch style {
        case .h1:
            return .system(size: 28, weight: .semibold, design: .default)
        case .h2:
            return .system(size: 24, weight: .semibold, design: .default)
        case .h3:
            return .system(size: 18, weight: .medium, design: .default)
        case .h4:
            return .system(size: 16, weight: .medium, design: .default)
        case .body:
            return .system(size: 14, weight: .medium, design: .default)
        case .caption:
            return .system(size: 12, weight: .medium, design: .default)
        }
    }
}

struct TypographyModifier: ViewModifier {
    let style: AppTextStyles
    func body(content: Content) -> some View {
        content
            .font(Typography.font(for: style))
    }
}

extension View {
    func typography(_ style: AppTextStyles) -> some View {
        modifier(TypographyModifier(style: style))
    }
}
