//
//  MoviesViewModel.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 20/08/2025.
//

import Foundation

@MainActor
class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let tmdbService = TMDbService()

    func loadPopularMovies(page: Int = 1) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMovies = try await tmdbService.fetchPopularMovies(page: page)
                self.movies = fetchedMovies
            } catch {
                print("Error fetching movies: \(error)")
                self.errorMessage = "Failed to load movies"
            }
            isLoading = false
        }
    }
}
