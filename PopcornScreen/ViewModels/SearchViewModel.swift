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

    private let service: TMDbService
    private var cancellables = Set<AnyCancellable>()

    init(service: TMDbService = .shared) {
        self.service = service

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
                async let mov: [Movie] = service.searchMovies(query: query)
                async let sho: [TVShow] = service.searchTV(query: query)
                let (movie, show) = try await (mov, sho)
                self.movies = movie
                self.shows = show
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
