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
    @Published var currentSort: TMDBSortOption?
    @Published var currentSortOrder: [TMDBSortOption] = []
    @Published var selectedGenreIDs: Set<Int> = []
    @Published var genres: [Genre] = []
    private var genresCacheByID: [Int: Genre] = [:]

    private let service: MovieService

    // Designated initializer for dependency injection
    init(service: MovieService) {
        self.service = service
    }

    convenience init() {
        self.init(service: TMDbService())
    }

    func loadGenres() async {
        do {
            let fetched = try await service.movieGenres(language: "en-US")
            self.genres = fetched
            self.genresCacheByID = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
        } catch {
            print("[MoviesViewModel] loadGenres error: \(error)")
        }
    }

    func genres(for movie: Movie) -> [Genre] {
        let ids = movie.genreIds ?? []
        return ids.compactMap { genresCacheByID[$0] }
    }

    func genreNames(for movie: Movie) -> String {
        genres(for: movie).map(\.name).joined(separator: ", ")
    }

    func movieLanguage(for movie: Movie, localized: Bool = true, locale: Locale = .current) -> String {
        let code = movie.originalLanguage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else { return "" }
        guard localized else { return code }
        return locale.localizedString(forLanguageCode: code)?.capitalized ?? code
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

    func loadPopularMovies(page: Int = 1, sort: TMDBSortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMovies = try await service.popularMovies(page: page, sort: sort)
                await MainActor.run {
                    self.movies = fetchedMovies
                    self.filterMovies()
                    self.applySort(sort)
                    self.isLoading = false
                }
            } catch {
                print("\(#function) Error fetching movies: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to load movies"
                    self.isLoading = false
                }
            }
        }
    }

    func searchMovies(query: String, page: Int = 1) {
        isLoading = true
        errorMessage = nil
        self.searchText = query
        Task {
            do {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let fetched = try await service.popularMovies(page: 1, sort: currentSort)
                    await MainActor.run { self.movies = fetched }
                } else {
                    let results = try await service.searchMovies(query, page: page)
                    await MainActor.run { self.movies = results }
                }
                await MainActor.run {
                    self.applySort(self.currentSort)
                    self.filterMovies()
                    self.isLoading = false
                }
            } catch {
                print("\(#function) Error searching movies: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to search movies"
                    self.isLoading = false
                }
            }
        }
    }

    private func filterMovies() {
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Start from the current base list (already sorted if applySort was used)
        var base = movies

        // Apply genre filter if any genres are selected
        if !selectedGenreIDs.isEmpty {
            base = base.filter { movie in
                guard let ids = movie.genreIds else { return false }
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

    func applySort(_ option: TMDBSortOption?) {
        currentSort = option
        currentSortOrder = option.map { [$0] } ?? []
        sortMovies(using: option)
    }

    func applySortOrder(_ options: [TMDBSortOption]) {
        currentSortOrder = options
        currentSort = options.first
        sortMovies(using: options)
    }

    // MARK: - Sorting

    private func comparisonResult(for option: TMDBSortOption, lhs: Movie, rhs: Movie) -> ComparisonResult {
        switch option {
        case .alphabeticalAscending, .alphabeticalDescending:
            let res = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
            return option == .alphabeticalAscending ? res : res.inverted

        case .releaseDateAscending, .releaseDateDescending:
            let left = lhs.releaseDate ?? ""
            let right = rhs.releaseDate ?? ""
            let res: ComparisonResult = (left == right) ? .orderedSame : (left < right ? .orderedAscending : .orderedDescending)
            return option == .releaseDateAscending ? res : res.inverted

        case .ratingAscending, .ratingDescending:
            let left = lhs.voteAverage ?? -Double.infinity
            let right = rhs.voteAverage ?? -Double.infinity
            let res: ComparisonResult = (left == right) ? .orderedSame : (left < right ? .orderedAscending : .orderedDescending)
            return option == .ratingAscending ? res : res.inverted
        }
    }

    private func sortMovies(using option: TMDBSortOption?) {
        guard let option = option else { return }
        sortMovies(using: [option])
    }

    private func sortMovies(using options: [TMDBSortOption]) {
        guard !options.isEmpty else { return }
        movies.sort { left, right in
            for opt in options {
                let cmp = comparisonResult(for: opt, lhs: left, rhs: right)
                if cmp != .orderedSame { return cmp == .orderedAscending }
            }
            return false
        }
        filterMovies()
    }

    // MARK: - Toggle helpers (for convenience)
    enum Category { case alphabetical, releaseDate, rating }

    func toggle(for category: Category) {
        switch category {
        case .alphabetical:
            let next: TMDBSortOption = (currentSort == .alphabeticalAscending) ? .alphabeticalDescending : .alphabeticalAscending
            applySort(next)
        case .releaseDate:
            let next: TMDBSortOption = (currentSort == .releaseDateAscending) ? .releaseDateDescending : .releaseDateAscending
            applySort(next)
        case .rating:
            let next: TMDBSortOption = (currentSort == .ratingAscending) ? .ratingDescending : .ratingAscending
            applySort(next)
        }
    }

    func toggleAlphabetical() { toggle(for: .alphabetical) }
    func toggleReleaseDate() { toggle(for: .releaseDate) }
    func toggleRating() { toggle(for: .rating) }
}

private extension ComparisonResult {
    var inverted: ComparisonResult {
        switch self {
        case .orderedAscending: return .orderedDescending
        case .orderedDescending: return .orderedAscending
        case .orderedSame: return .orderedSame
        }
    }
}
