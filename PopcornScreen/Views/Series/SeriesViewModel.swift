//
//  TVShowsViewModel.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 21/08/2025.
//

import Foundation

@MainActor
final class SeriesViewModel: ObservableObject {
    @Published var series: [TVShow] = []
    @Published var filteredSeries: [TVShow] = []
    @Published var searchText: String = "" { didSet { filterSeries() } }
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentSort: TMDBSortOption?
    @Published var currentSortOrder: [TMDBSortOption] = []
    @Published var selectedGenreIDs: Set<Int> = []
    @Published var genres: [Genre] = []
    private var genresCacheByID: [Int: Genre] = [:]

    private let service: TVService

    // Designated initializer for dependency injection
    init(service: TVService) {
        self.service = service
    }

    convenience init() {
        self.init(service: TMDbService())
    }

    // MARK: - Genres
    func loadGenres() async {
        do {
            let fetched = try await service.tvGenres(language: "en-US")
            self.genres = fetched
            self.genresCacheByID = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
        } catch {
            print("[SeriesViewModel] loadGenres error: \(error)")
        }
    }

    func genres(for show: TVShow) -> [Genre] {
        let ids = show.genreIds ?? []
        return ids.compactMap { genresCacheByID[$0] }
    }

    func genreNames(for show: TVShow) -> String {
        genres(for: show).map(\.name).joined(separator: ", ")
    }

    func setSelectedGenres(_ ids: Set<Int>) {
        selectedGenreIDs = ids
        filterSeries()
    }

    func toggleGenre(_ id: Int) {
        if selectedGenreIDs.contains(id) {
            selectedGenreIDs.remove(id)
        } else {
            selectedGenreIDs.insert(id)
        }
        filterSeries()
    }

    func clearGenres() {
        selectedGenreIDs.removeAll()
        filterSeries()
    }

    // MARK: - Data loading
    func loadPopularSeries(page: Int = 1, sort: TMDBSortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetched = try await service.popularShows(page: page, sort: sort)
                await MainActor.run {
                    self.series = fetched
                    self.applySort(sort)
                    self.filterSeries()
                    self.isLoading = false
                }
            } catch {
                print("\(#function) Error fetching series: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to load series"
                    self.isLoading = false
                }
            }
        }
    }

    func searchSeries(query: String, page: Int = 1) {
        isLoading = true
        errorMessage = nil
        self.searchText = query
        Task {
            do {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let fetched = try await service.popularShows(page: 1, sort: currentSort)
                    await MainActor.run { self.series = fetched }
                } else {
                    let results = try await service.searchShows(query, page: page)
                    await MainActor.run { self.series = results }
                }
                await MainActor.run {
                    self.applySort(self.currentSort)
                    self.filterSeries()
                    self.isLoading = false
                }
            } catch {
                print("\(#function) Error searching series: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to search series"
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Filtering & sorting
    private func filterSeries() {
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var base = series

        if !selectedGenreIDs.isEmpty {
            base = base.filter { show in
                guard let ids = show.genreIds else { return false }
                let showSet = Set(ids)
                return !showSet.isDisjoint(with: selectedGenreIDs)
            }
        }

        print("[filterSeries] series:", series.count,
              "selectedGenres:", selectedGenreIDs,
              "query:", "\"\(searchText)\"")

        guard !newQuery.isEmpty else {
            filteredSeries = base
            print("[filterSeries] filteredSeries:", filteredSeries.count)
            return
        }

        filteredSeries = base.filter { $0.name.localizedCaseInsensitiveContains(newQuery) }
    }

    func applySort(_ option: TMDBSortOption?) {
        currentSort = option
        currentSortOrder = option.map { [$0] } ?? []
        sortSeries(using: option)
    }

    func applySortOrder(_ options: [TMDBSortOption]) {
        currentSortOrder = options
        currentSort = options.first
        sortSeries(using: options)
    }

    private func comparisonResult(for option: TMDBSortOption, lhs: TVShow, rhs: TVShow) -> ComparisonResult {
        switch option {
        case .alphabeticalAscending, .alphabeticalDescending:
            let res = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
            return option == .alphabeticalAscending ? res : res.inverted

        case .releaseDateAscending, .releaseDateDescending:
            let left = lhs.firstAirDate ?? ""
            let right = rhs.firstAirDate ?? ""
            let res: ComparisonResult = (left == right) ? .orderedSame : (left < right ? .orderedAscending : .orderedDescending)
            return option == .releaseDateAscending ? res : res.inverted

        case .ratingAscending, .ratingDescending:
            let left = lhs.voteAverage ?? -Double.infinity
            let right = rhs.voteAverage ?? -Double.infinity
            let res: ComparisonResult = (left == right) ? .orderedSame : (left < right ? .orderedAscending : .orderedDescending)
            return option == .ratingAscending ? res : res.inverted
        }
    }

    private func sortSeries(using option: TMDBSortOption?) {
        guard let option = option else { return }
        sortSeries(using: [option])
    }

    private func sortSeries(using options: [TMDBSortOption]) {
        guard !options.isEmpty else { return }
        series.sort { left, right in
            for opt in options {
                let cmp = comparisonResult(for: opt, lhs: left, rhs: right)
                if cmp != .orderedSame { return cmp == .orderedAscending }
            }
            return false
        }
        filterSeries()
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

// Conform SeriesViewModel to the GenresViewModeling protocol used by GenresView
@MainActor
extension SeriesViewModel: @MainActor GenresViewModeling {}
