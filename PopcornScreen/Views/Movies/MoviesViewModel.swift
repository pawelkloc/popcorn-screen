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
    @Published var searchText: String = "" { didSet { filterMovies() } }
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentSort: TMDbService.SortOption?
    @Published var currentSortOrder: [TMDbService.SortOption] = []
    @Published var selectedGenreIDs: Set<Int> = []
    @Published var genres: [Genre] = []
    private var genresCacheByID: [Int: Genre] = [:]

    private let service: TMDbService

    init(service: TMDbService = .shared) {
        self.service = service
    }

    func loadGenres() async {
        do {
            let fetched = try await service.fetchMovieGenres()
            self.genres = fetched
            self.genresCacheByID = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
        } catch {
            print("[MoviesViewModel] loadGenres error: \(error)")
        }
    }

    func genres(for movie: Movie) -> [Genre] {
        let ids = movie.genreIDs ?? []
        return ids.compactMap { genresCacheByID[$0] }
    }

    func genreNames(for movie: Movie) -> String {
        genres(for: movie).map(\.name).joined(separator: ", ")
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

    func loadPopularMovies(page: Int = 1, sort: TMDbService.SortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMovies = try await service.fetchPopularMovies(page: page, sort: sort)
                self.movies = fetchedMovies
                self.filterMovies()
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
                let movieSet = Set(ids)
                return !movieSet.isDisjoint(with: selectedGenreIDs)
            }
        }

        print("[filterMovies] movies:", movies.count,
              "selectedGenres:", selectedGenreIDs,
              "query:", "\"\(searchText)\"")

        // Apply text filter
        guard !newQuery.isEmpty else {
            filteredMovies = base
            print("[filterMovies] filteredMovies:", filteredMovies.count)
            return
        }

        filteredMovies = base.filter { $0.title.localizedCaseInsensitiveContains(newQuery) }
    }

    func applySort(_ option: TMDbService.SortOption?) {
        currentSort = option
        currentSortOrder = option.map { [$0] } ?? []
        sortMovies(using: option)
    }

    func applySortOrder(_ options: [TMDbService.SortOption]) {
        currentSortOrder = options
        currentSort = options.first
        sortMovies(using: options)
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
        filterMovies()
        self.filteredMovies = sortFilteredKeepingQuery(current: filteredMovies, base: sorted)
    }

    private func sortMovies(using options: [TMDbService.SortOption]) {
        guard !options.isEmpty else { return }
        self.movies = movies.sorted { leftMovie, rightMovie in
            for opt in options {
                let cmp: ComparisonResult
                switch opt {
                case .alphabeticalAscending, .alphabeticalDescending:
                    cmp = leftMovie.title.localizedCaseInsensitiveCompare(rightMovie.title)
                case .releaseDateAscending, .releaseDateDescending:
                    cmp = (leftMovie.releaseDate ?? "").localizedStandardCompare(rightMovie.releaseDate ?? "")
                case .ratingAscending, .ratingDescending:
                    let lhs = leftMovie.voteAverage ?? 0
                    let rhs = rightMovie.voteAverage ?? 0
                    if lhs != rhs {
                        return opt == .ratingAscending ? lhs < rhs : lhs > rhs
                    } else {
                        continue
                    }
                }
                if cmp != .orderedSame {
                    return (opt == .alphabeticalAscending || opt == .releaseDateAscending) ? (cmp == .orderedAscending) : (cmp == .orderedDescending)
                }
            }
            return false
        }
        filterMovies()
    }

    private func sortFilteredKeepingQuery(current: [Movie], base: [Movie]) -> [Movie] {
        // Re-derive filtered list from the newly sorted base using the current search text
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if newQuery.isEmpty { return base }
        return base.filter { $0.title.localizedCaseInsensitiveContains(newQuery) }
    }

    // MARK: - Toggle helpers (for convenience)
    enum Category { case alphabetical, releaseDate, rating }

    func toggle(for category: Category) {
        switch category {
        case .alphabetical:
            let next: TMDbService.SortOption = (currentSort == .alphabeticalAscending) ? .alphabeticalDescending : .alphabeticalAscending
            applySort(next)
        case .releaseDate:
            let next: TMDbService.SortOption = (currentSort == .releaseDateAscending) ? .releaseDateDescending : .releaseDateAscending
            applySort(next)
        case .rating:
            let next: TMDbService.SortOption = (currentSort == .ratingAscending) ? .ratingDescending : .ratingAscending
            applySort(next)
        }
    }

    func toggleAlphabetical() { toggle(for: .alphabetical) }
    func toggleReleaseDate() { toggle(for: .releaseDate) }
    func toggleRating() { toggle(for: .rating) }
}

