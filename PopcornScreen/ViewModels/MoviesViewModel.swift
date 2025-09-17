//
//  MoviesViewModel.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 20/08/2025.
//

import Foundation

@MainActor
final class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var filteredMovies: [Movie] = []
    @Published var searchText: String = "" {
        didSet { filterMovies() }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentSort: TMDbService.SortOption?
    @Published var selectedGenreIDs: Set<Int> = []

    private let service: TMDbService

    init(service: TMDbService = .shared) {
        self.service = service
    }

    func setSelectedGenres(_ ids: Set<Int>) {
        selectedGenreIDs = ids
        filterMovies()
    }

    func toggleGenre(_ id: Int) {
        if selectedGenreIDs.contains(id) {
            selectedGenreIDs.remove(id)
        } else {
            selectedGenreIDs.insert(id)
        }
        filterMovies()
    }

    func clearGenres() {
        selectedGenreIDs.removeAll()
        filterMovies()
    }

    func loadPopularMovies(page: Int = 100, sort: TMDbService.SortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMovies = try await service.fetchPopularMovies(page: page, sort: sort)
                self.movies = fetchedMovies
                self.filteredMovies = fetchedMovies
                self.applySort(sort)
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

        // Start from the current base list (already sorted if applySort was used)
        var base = movies

        // Apply genre filter if any genres are selected
        if !selectedGenreIDs.isEmpty {
            base = base.filter { movie in
                guard let ids = movie.genreIDs else { return false }
                return !selectedGenreIDs.isDisjoint(with: Set(ids))
            }
        }

        // Apply text filter
        guard !newQuery.isEmpty else {
            filteredMovies = base
            return
        }

        filteredMovies = base.filter { $0.title.localizedCaseInsensitiveContains(newQuery) }
    }

    func loadMoviesByGenres(_ genreIDs: [Int]) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await service.fetchMoviesByGenres(genreIDs: genreIDs)
                self.movies = response.results
                self.filterMovies()
            } catch {
                print("Error: \(error)")
                self.errorMessage = "Couldn't load movies"
            }
            isLoading = false
        }
    }

    func applySort(_ option: TMDbService.SortOption?) {
        currentSort = option
        sortMovies(using: option)
        filterMovies()
    }

    private func sortMovies(using option: TMDbService.SortOption?) {
        guard let option = option else { return }

        let sorted: [Movie]
        switch option {
        case .releaseDateAscending:
            sorted = movies.sorted { ($0.releaseDate ?? "") < ($1.releaseDate ?? "") }
        case .releaseDateDescending:
            sorted = movies.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        case .ratingAscending:
            sorted = movies.sorted { ($0.voteAverage ?? 0) < ($1.voteAverage ?? 0) }
        case .ratingDescending:
            sorted = movies.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        case .alphabeticalAscending:
            sorted = movies.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .alphabeticalDescending:
            sorted = movies.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }

        self.movies = sorted
        self.filteredMovies = sortFilteredKeepingQuery(current: filteredMovies, base: sorted)
    }

    private func sortFilteredKeepingQuery(current: [Movie], base: [Movie]) -> [Movie] {
        // Re-derive filtered list from the newly sorted base using the current search text
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if newQuery.isEmpty { return base }
        return base.filter { $0.title.localizedCaseInsensitiveContains(newQuery) }
    }
}
