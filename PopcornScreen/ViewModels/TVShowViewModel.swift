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
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let tmdbService = TMDbService()

    func loadPopularTV(page: Int = 1) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetched = try await tmdbService.fetchPopularTV(page: page)
                self.shows = fetched
            } catch {
                print("Error fetching TV shows: \(error)")
                self.errorMessage = "Failed to load TV shows"
            }
            isLoading = false
        }
    }
}
