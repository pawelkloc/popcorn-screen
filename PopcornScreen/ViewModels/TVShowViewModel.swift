//
//  TVShowViewModel.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 21/08/2025.
//

import Foundation

@MainActor
class TVShowViewModel: ObservableObject {
    @Published var shows: [TVShow] = []
    @Published var filteredTVShows: [TVShow] = []
    @Published var searchText: String = "" {
        didSet { filterTVShows() }
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
        filterTVShows()
    }

    func toggleGenre(_ id: Int) {
        if selectedGenreIDs.contains(id) {
            selectedGenreIDs.remove(id)
        } else {
            selectedGenreIDs.insert(id)
        }
        filterTVShows()
    }

    func clearGenres() {
        selectedGenreIDs.removeAll()
        filterTVShows()
    }

    func applySort(_ option: TMDbService.SortOption?) {
        currentSort = option
        sortTVShows(using: option)
        filterTVShows()
    }

    func loadPopularTV(page: Int = 1, sort: TMDbService.SortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedTVSeries = try await service.fetchPopularTV(page: page, sort: sort)
                self.shows = fetchedTVSeries
                self.filteredTVShows = fetchedTVSeries
                self.applySort(sort)
            } catch {
                print("Error fetching TV shows: \(error)")
                self.errorMessage = "Failed to load TV shows"
            }
            isLoading = false
        }
    }

    func searchTV(query: String, page: Int = 1) {
        isLoading = false
        errorMessage = nil
        self.searchText = query
    }

    private func filterTVShows() {
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        var base = shows

        // Apply genre filter if any genres are selected
        if !selectedGenreIDs.isEmpty {
            base = base.filter { show in
                guard let ids = show.genreIDs else { return false }
                return !selectedGenreIDs.isDisjoint(with: Set(ids))
            }
        }

        // Apply text filter
        guard !newQuery.isEmpty else {
            filteredTVShows = base
            return
        }

        filteredTVShows = base.filter { $0.name.localizedCaseInsensitiveContains(newQuery) }
    }

    func loadTVShowsByGenres(_ genreIDs: [Int]) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await service.fetchTVShowsByGenre(genreIDs: genreIDs)
                self.shows = response.results
                self.filterTVShows()
            } catch {
                print("Error: \(error)")
                self.errorMessage = "Couldn't load TV shows"
            }
            isLoading = false
        }
    }

    private func sortTVShows(using option: TMDbService.SortOption?) {
        guard let option = option else { return }

        let sorted: [TVShow]
        switch option {
        case .releaseDateAscending:
            // For TV shows, use first air date if available
            sorted = shows.sorted { ($0.firstAirDate ?? "") < ($1.firstAirDate ?? "") }
        case .releaseDateDescending:
            sorted = shows.sorted { ($0.firstAirDate ?? "") > ($1.firstAirDate ?? "") }
        case .ratingAscending:
            sorted = shows.sorted { ($0.voteAverage ?? 0) < ($1.voteAverage ?? 0) }
        case .ratingDescending:
            sorted = shows.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        case .alphabeticalAscending:
            sorted = shows.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .alphabeticalDescending:
            sorted = shows.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }

        self.shows = sorted
        self.filteredTVShows = sortFilteredKeepingQuery(base: sorted)
    }

    private func sortFilteredKeepingQuery(base: [TVShow]) -> [TVShow] {
        let newQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if newQuery.isEmpty { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(newQuery) }
    }
}
