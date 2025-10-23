//
//  MetaChip.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 23/10/2025.
//

import SwiftUI

struct MetaChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.vertical, .spacing(.xs))
            .padding(.horizontal, .spacing(.xs))
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.small.rawValue)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small.rawValue)
                    .stroke(.quaternary, lineWidth: 0.5)
            )
    }
}

struct Section: View {
    let title: String
    var body: some View {
        HStack(spacing: .spacing(.xxs)) {
            Rectangle()
                .fill(Color.yellow)
                .frame(width: 4, height: 36)
            Text(title)
                .font(.title2)
        }
        .accessibilityAddTraits(.isHeader)
    }
}
