//
//  GenresView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 06/10/2025.
//

import SwiftUI

protocol GenresViewModeling: ObservableObject {
    var genres: [Genre] { get }
    var selectedGenreIDs: Set<Int> { get }
    func clearGenres()
    func toggleGenre(_ id: Int)
    func loadGenres() async
}

struct GenresView<VM: GenresViewModeling>: View {
    @ObservedObject var viewModel: VM

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .spacing(.xs)) {
                let isAllSelected = viewModel.selectedGenreIDs.isEmpty

                Button {
                    viewModel.clearGenres()
                } label: {
                    HStack(spacing: .spacing(.xs)) {
                        Text("All")
                            .font(.callout)
                            .fontWeight(.regular)
                    }
                    .padding(.horizontal, .spacing(.s))
                    .padding(.vertical, .spacing(.xs))
                    .foregroundStyle(.black)
                    .background(
                        Capsule().fill(isAllSelected ? .yellow : .clear)
                    )
                    .overlay(
                        Capsule().stroke(isAllSelected ? .yellow : .primary, lineWidth: 1)
                    )
                }

                ForEach(viewModel.genres) { genre in
                    chip(for: genre)
                }

                if !viewModel.selectedGenreIDs.isEmpty {
                    Button {
                        viewModel.clearGenres()
                    } label: {
                        HStack(spacing: .spacing(.xs)) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear")
                        }
                        .padding(.horizontal, .spacing(.s))
                        .padding(.vertical, .spacing(.xs))
                    }
                }
            }
            .padding(.vertical, .spacing(.xs))
        }
        .task { await viewModel.loadGenres() }
    }

    private func chip(for genre: Genre) -> some View {
        let isSelected = viewModel.selectedGenreIDs.contains(genre.id)
        return Button {
            viewModel.toggleGenre(genre.id)
        } label: {
            HStack(spacing: .spacing(.xs)) {
                Text(genre.name)
                    .font(.callout)
                    .fontWeight(.regular)
                if isSelected {
                    Image("cancel-small")
                        .imageScale(.small)
                }
            }
            .padding(.horizontal, .spacing(.s))
            .padding(.vertical, .spacing(.xs))
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

extension MoviesViewModel: GenresViewModeling {}

#Preview {
    NavigationStack {
        GenresView(viewModel: MoviesViewModel())
    }
}
