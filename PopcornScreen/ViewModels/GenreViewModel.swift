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
    @Published var movieGenres: [Genre] = []
    @Published var tvGenres: [Genre] = []
    @Published var isLoadingMovieGenres = false
    @Published var isLoadingTVGenres = false
    @Published var errorMovieGenres: String?
    @Published var errorTVGenres: String?

    private let service: TMDbService
    private var cancellables = Set<AnyCancellable>()

    init(service: TMDbService = .shared) {
        self.service = service
    }

    func fetchMovieGenres(language: String = "en-US") {
        isLoadingMovieGenres = true
        errorMovieGenres = nil
        Task {
            do {
                let fetchedGenres = try await service.fetchMovieGenres(language: language)
                self.movieGenres = fetchedGenres
            } catch {
                print("Error fetching movie genres: \(error)")
                self.errorMovieGenres = "Failed to load movie genres"
            }
            isLoadingMovieGenres = false
        }
    }

    func fetchTVGenres(language: String = "en-US") {
        isLoadingTVGenres = true
        errorTVGenres = nil
        Task {
            do {
                let fetchedGenres = try await service.fetchTVGenres(language: language)
                self.tvGenres = fetchedGenres
            } catch {
                print("Error fetching TV genres: \(error)")
                self.errorTVGenres = "Failed to load TV genres"
            }
            isLoadingTVGenres = false
        }
    }

    func movieGenreNames(for ids: [Int]) -> [String] {
        movieGenres.filter { ids.contains($0.id) }.map { $0.name }
    }

    func tvGenreNames(for ids: [Int]) -> [String] {
        tvGenres.filter { ids.contains($0.id) }.map { $0.name }
    }
}
