//
//  TVService.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import Foundation

protocol TVService {
    func popularShows(page: Int, sort: TMDBSortOption?) async throws -> [TVShow]
    func searchShows(_ query: String, page: Int) async throws -> [TVShow]
    func tvGenres(language: String) async throws -> [Genre]
    func showsByGenres(_ genreIDs: [Int], page: Int, language: String) async throws -> [TVShow]
}
