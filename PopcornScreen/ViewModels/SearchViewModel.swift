//
//  SearchViewModel.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 21/08/2025.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var movies: [Movie] = []
    @Published var shows: [TVShow] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?

    private let tmdbService = TMDbService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] newQuery in
                self?.handleQueryChange(newQuery)
            }
            .store(in: &cancellables)
    }

    private func handleQueryChange(_ newQuery: String) {
        let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            movies.removeAll()
            shows.removeAll()
            errorMessage = nil
            isSearching = false
            return
        }
        searchAll(query: trimmed)
    }

    func searchAll(query: String, page: Int = 1) {
        isSearching = true
        errorMessage = nil
        Task {
            do {
                async let mov: [Movie] = tmdbService.searchMovies(query: query, page: page)
                async let sho: [TVShow] = tmdbService.searchTV(query: query, page: page)
                let (mv, sh) = try await (mov, sho)
                self.movies = mv
                self.shows = sh
                self.isSearching = false
            } catch {
                print("Error searching: \(error)")
                self.errorMessage = "Failed to search"
                self.isSearching = false
            }
        }
    }

    func clearResults() {
        query = ""
        movies.removeAll()
        shows.removeAll()
        errorMessage = nil
        isSearching = false
    }
}
