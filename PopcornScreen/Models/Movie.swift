//
//  Movie.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import Foundation

struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let posterURL: URL?
    let releaseDate: Date?
    let genres: [String]
    let averageRating: Double?

    // Convenience initializer for previews/tests/manual construction
    init(
        id: Int,
        title: String,
        posterURL: URL?,
        releaseDate: Date?,
        genres: [String],
        averageRating: Double?
    ) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.releaseDate = releaseDate
        self.genres = genres
        self.averageRating = averageRating
    }

    private static let genreMap: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterURL = "poster_path"
        case releaseDate = "release_date"
        case genres = "genre_ids"
        case averageRating = "vote_average"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)

        if let posterPath = try container.decodeIfPresent(String.self, forKey: .posterURL) {
            self.posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        } else {
            self.posterURL = nil
        }

        if let releaseDateString = try container.decodeIfPresent(String.self, forKey: .releaseDate) {
            releaseDate = Movie.tmdbDateFormatter.date(from: releaseDateString)
        } else {
            releaseDate = nil
        }

        let genreIds = try container.decodeIfPresent([Int].self, forKey: .genres) ?? []
        self.genres = genreIds.map { Movie.genreMap[$0] ?? "Unknown" }

        averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating)
    }

    private static let tmdbDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct MovieResponse: Decodable {
    let results: [Movie]
}
