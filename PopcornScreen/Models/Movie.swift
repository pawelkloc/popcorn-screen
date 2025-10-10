//
//  Movie.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//
import Foundation

struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double
    let genreIDs: [Int]?
}
