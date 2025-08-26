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

    private let service: TMDbService

    init(service: TMDbService = .shared) {
        self.service = service
    }

    func loadPopularMovies(page: Int = 1, sort: TMDbService.Endpoint.SortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMovies = try await service.fetchPopularMovies(page: page, sort: sort)
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

    func loadMoviesByGenres(_ genreIDs: [Int]) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await service.fetchMoviesByGenres(genreIDs: genreIDs)
                self.movies = response.results
            } catch {
                print("Error: \(error)")
                self.errorMessage = "Couldn't load movies"
            }
            isLoading = false
        }
    }
}
