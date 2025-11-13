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

    private let movieService: MovieService
    private let tvService: TVService
    private var cancellables = Set<AnyCancellable>()

    // Designated initializer without default arguments
    init(movieService: MovieService, tvService: TVService) {
        self.movieService = movieService
        self.tvService = tvService

        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] newQuery in
                self?.handleQueryChange(newQuery)
            }
            .store(in: &cancellables)
    }

    // Convenience initializer that constructs one shared TMDbService for both protocols
    convenience init() {
        let service = TMDbService()
        self.init(movieService: TMDbService(), tvService: TMDbService())
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
                async let mov: [Movie] = movieService.searchMovies(query, page: page)
                async let sho: [TVShow] = tvService.searchShows(query, page: page)
                let (movie, show) = try await (mov, sho)
                await MainActor.run {
                    self.movies = movie
                    self.shows = show
                    self.isSearching = false
                }
            } catch {
                print("Error searching: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to search"
                    self.isSearching = false
                }
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
