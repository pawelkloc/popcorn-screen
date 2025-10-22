//
//  MovieService.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import Foundation

protocol MovieService {
    func popularMovies(page: Int, sort: TMDBSortOption?) async throws -> [Movie]
    func searchMovies(_ query: String, page: Int) async throws -> [Movie]
    func movieGenres(language: String) async throws -> [Genre]
    func moviesByGenres(_ genreIDs: [Int], page: Int, language: String) async throws -> [Movie]
}
