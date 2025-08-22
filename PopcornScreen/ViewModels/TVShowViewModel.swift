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

    private let tmdbService = TMDbService()

    func loadPopularTV(page: Int = 1, sort: TMDbService.Endpoint.SortOption? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedTVSeries = try await tmdbService.fetchPopularTV(page: page, sort: sort)
                self.shows = fetchedTVSeries
                self.filteredTVShows = fetchedTVSeries
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
        guard !newQuery.isEmpty else {
            filteredTVShows = shows
            return
        }

        filteredTVShows = shows.filter { $0.name.localizedCaseInsensitiveContains(newQuery) }
    }
}
