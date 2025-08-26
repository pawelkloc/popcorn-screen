//
//  GenreViewModel.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 26/08/2025.
//

import Foundation
import Combine

@MainActor
final class GenreViewModel: ObservableObject {
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: TMDbService
    private var cancellables = Set<AnyCancellable>()

    init(service: TMDbService = .shared) {
        self.service = service
    }

    func fetchGenres(language: String = "en-US") {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedGenres = try await service.fetchMovieGenres(language: language)
                self.genres = fetchedGenres
            } catch {
                print("Error fetching genres: \(error)")
                self.errorMessage = "Failed to load genres"
            }
            isLoading = false
        }
        
        func names(for ids: [Int]) -> [String] {
            genres.filter { ids.contains($0.id) }.map { $0.name }
        }
    }
}
