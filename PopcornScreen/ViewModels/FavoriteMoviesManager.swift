// FavoriteMoviesManager.swift
// PopcornScreen
//
// Created by Paweł Kloc on 27/08/2025.

import Foundation

@MainActor
class FavoriteMoviesManager: ObservableObject {
    @Published private(set) var favoriteMovies: [Movie] = []

    func add(movie: Movie) {
        guard !favoriteMovies.contains(where: { $0.id == movie.id }) else { return }
        favoriteMovies.append(movie)
    }

    func remove(movie: Movie) {
        favoriteMovies.removeAll { $0.id == movie.id }
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favoriteMovies.contains(where: { $0.id == movie.id })
    }
}
