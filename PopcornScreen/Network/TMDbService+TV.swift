//
//  TMDbService+TV.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import Foundation

extension TMDbService {
    func fetchPopularTV(page: Int, sort: TMDBSortOption? = nil) async throws -> [TVShow] {
        let req = try request(for: .discoverTV, page: page, sort: sort)
        let response: TVResponse = try await fetchDecodable(TVResponse.self, request: req)
        return response.results
    }

    func searchTV(query: String, page: Int = 1) async throws -> [TVShow] {
        let req = try request(for: .searchTV, page: page, query: query)
        let response: TVResponse = try await fetchDecodable(TVResponse.self, request: req)
        return response.results
    }

    func fetchTVGenres(language: String = "en-US") async throws -> [Genre] {
        let req = try request(for: .tvGenres)
        let response: GenreResponse = try await fetchDecodable(GenreResponse.self, request: req)
        return response.genres
    }

    func fetchTVShowsByGenre(genreIDs: [Int], page: Int = 1, language: String = "en-US") async throws -> TVResponse {
        let genreString = genreIDs.map(String.init).joined(separator: ",")
        var items = [
            URLQueryItem(name: "with_genres", value: genreString),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: String(page))
        ]
        var comp = Endpoint.discoverTV.components(baseURL: baseURL, page: nil, query: nil, sort: nil)
        comp.queryItems = (comp.queryItems ?? []) + items
        guard let url = comp.url else { throw FetchError.badResponse }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await fetchDecodable(TVResponse.self, request: req)
    }
}

// Protocol conformance
extension TMDbService: TVService {
    func popularShows(page: Int, sort: TMDBSortOption?) async throws -> [TVShow] {
        try await fetchPopularTV(page: page, sort: sort)
    }
    func searchShows(_ query: String, page: Int) async throws -> [TVShow] {
        try await searchTV(query: query, page: page)
    }
    func tvGenres(language: String) async throws -> [Genre] {
        try await fetchTVGenres(language: language)
    }
    func showsByGenres(_ genreIDs: [Int], page: Int, language: String) async throws -> [TVShow] {
        let resp = try await fetchTVShowsByGenre(genreIDs: genreIDs, page: page, language: language)
        return resp.results
    }
}
