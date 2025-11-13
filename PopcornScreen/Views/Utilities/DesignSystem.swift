//
//  Spacing.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 23/10/2025.
//

import SwiftUI

// MARK: - Spacing scale
// swiftlint:disable identifier_name
// Short enum case names are intentional to match common spacing tokens (xs, s, m, l, etc.)
enum Spacing: CGFloat, CaseIterable {
    case xxs = 4
    case xs  = 8
    case s   = 16
    case sm  = 24
    case m   = 32
    case ml  = 40
    case l   = 48
    case xl  = 56
    case xxl = 64
    case xxxl = 72
    case huge = 80
    case giant = 88
    case colossal = 96
    case massive = 104
    case ultra = 112
    case titan = 120
    case omega = 128
}
// swiftlint:enable identifier_name

extension CGFloat {
    static func spacing(_ space: Spacing) -> CGFloat {
        return space.rawValue
    }
}

// MARK: - Poster size
enum PosterSize {
    case small
    case large

    var size: CGSize {
        switch self {
        case .small:
            return CGSize(width: 94, height: 144)
        case .large:
            return CGSize(width: 266, height: 366)
        }
    }
}

extension CGSize {
    static var poster: CGSize { PosterSize.small.size }
}

extension View {
    func posterFrame(_ size: PosterSize) -> some View {
        self.frame(width: size.size.width, height: size.size.height)
    }
}

// MARK: - Corner radius scale
enum CornerRadius: CGFloat {
    case small  = 8
    case large  = 24
}

extension View {
    func cornerRadius(_ radius: CornerRadius) -> some View {
        self.cornerRadius(radius.rawValue)
    }
}
