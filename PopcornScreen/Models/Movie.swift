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
    let genreIds: [Int]?
}

extension Movie {
    // Returns the 4-digit year extracted from TMDB's releaseDate ("yyyy-MM-dd"), or an empty string if unavailable.
    var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "" }
        return String(releaseDate.prefix(4))
    }

    // Builds a full image URL from TMDB's poster path, using a common size.
    var posterURL: URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        // You can adjust the size segment (e.g., w185, w342, w500, original) as needed.
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
