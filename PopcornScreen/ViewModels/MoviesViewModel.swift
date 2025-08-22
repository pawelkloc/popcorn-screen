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
    @Published var filteredMovies: [Movie] = []
    @Published var searchText: String = "" {
        didSet { filterMovies() }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let tmdbService = TMDbService()

    func loadPopularMovies(page: Int = 1, sort: TMDbService.Endpoint.SortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMovies = try await tmdbService.fetchPopularMovies(page: page, sort: sort)
                self.movies = fetchedMovies
                self.filteredMovies = fetchedMovies
            } catch {
                print("Error fetching movies: \(error)")
                self.errorMessage = "Failed to load movies"
            }
            isLoading = false
        }
    }

    func searchMovies(query: String, page: Int = 1) {
        isLoading = false
        errorMessage = nil
        self.searchText = query
    }

    private func filterMovies() {
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newQuery.isEmpty else {
            filteredMovies = movies
            return
        }

        filteredMovies = movies.filter { $0.title.localizedCaseInsensitiveContains(newQuery) }
    }
}
