//
//  GenresView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 06/10/2025.
//

import SwiftUI

struct GenresView: View {
    @ObservedObject var viewModel: MoviesViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let isAllSelected = viewModel.selectedGenreIDs.isEmpty
                Button {
                    viewModel.clearGenres()
                } label: {
                    HStack(spacing: 6) {
                        Text("All")
                            .font(.callout)
                            .fontWeight(.regular)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundStyle(.black)
                    .background(
                        Capsule().fill(isAllSelected ? .yellow : .clear)
                    )
                    .overlay(
                        Capsule().stroke(isAllSelected ? .yellow : .primary, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                ForEach(viewModel.genres) { genre in
                    chip(for: genre)
                }
                if !viewModel.selectedGenreIDs.isEmpty {
                    Button {
                        viewModel.clearGenres()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .task { await viewModel.loadGenres() }

    }

    private func chip(for genre: Genre) -> some View {
        let isSelected = viewModel.selectedGenreIDs.contains(genre.id)
        return Button {
            viewModel.toggleGenre(genre.id)
        } label: {
            HStack(spacing: 6) {
                Text(genre.name)
                    .font(.callout)
                    .fontWeight(.regular)
                if isSelected {
                    Image("cancel-small")
                        .imageScale(.small)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(.black)
            .background(
                Capsule().fill(isSelected ? .yellow : .clear)
            )
            .overlay(
                Capsule().stroke(isSelected ? .yellow : .primary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        GenresView(viewModel: MoviesViewModel())
    }
}
