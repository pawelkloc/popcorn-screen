//
//  TMDbService+Movies.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import Foundation

extension TMDbService {
    func fetchPopularMovies(page: Int, sort: TMDBSortOption? = nil) async throws -> [Movie] {
        let req = try request(for: .discoverMovies, page: page, sort: sort)
        let response: MoviesResponse = try await fetchDecodable(MoviesResponse.self, request: req)
        return response.results
    }

    func searchMovies(query: String, page: Int = 1) async throws -> [Movie] {
        let req = try request(for: .searchMovies, page: page, query: query)
        let response: MoviesResponse = try await fetchDecodable(MoviesResponse.self, request: req)
        return response.results
    }

    func fetchMovieGenres(language: String = "en-US") async throws -> [Genre] {
        let req = try request(for: .movieGenres)
        let response: GenreResponse = try await fetchDecodable(GenreResponse.self, request: req)
        return response.genres
    }

    func fetchMoviesByGenres(genreIDs: [Int], page: Int = 1, language: String = "en-US") async throws -> MoviesResponse {
        let genreString = genreIDs.map(String.init).joined(separator: ",")
        var items = [
            URLQueryItem(name: "with_genres", value: genreString),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: String(page))
        ]
        var comp = Endpoint.discoverMovies.components(baseURL: baseURL, page: nil, query: nil, sort: nil)
        comp.queryItems = (comp.queryItems ?? []) + items
        guard let url = comp.url else { throw FetchError.badResponse }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await fetchDecodable(MoviesResponse.self, request: req)
    }
}

// Protocol conformance
extension TMDbService: MovieService {
    func popularMovies(page: Int, sort: TMDBSortOption?) async throws -> [Movie] {
        try await fetchPopularMovies(page: page, sort: sort)
    }
    func searchMovies(_ query: String, page: Int) async throws -> [Movie] {
        try await searchMovies(query: query, page: page)
    }
    func movieGenres(language: String) async throws -> [Genre] {
        try await fetchMovieGenres(language: language)
    }
    func moviesByGenres(_ genreIDs: [Int], page: Int, language: String) async throws -> [Movie] {
        let resp = try await fetchMoviesByGenres(genreIDs: genreIDs, page: page, language: language)
        return resp.results
    }
}
