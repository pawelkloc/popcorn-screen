//
//  TVShow.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 21/08/2025.
//

import Foundation

struct TVShow: Identifiable, Decodable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let firstAirDate: String?
    let genres: [String]
    let posterURL: URL?
    let firstAirDateFormatted: Date?

    private static let genreMap: [Int: String] = [
        10759: "Action & Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        10762: "Kids",
        9648: "Mystery",
        10763: "News",
        10764: "Reality",
        10765: "Sci-Fi & Fantasy",
        10766: "Soap",
        10767: "Talk",
        10768: "War & Politics",
        37: "Western"
    ]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case firstAirDate = "first_air_date"
        case genres = "genre_ids"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        if let posterPath = posterPath {
            posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        } else {
            posterURL = nil
        }
        self.firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate)
        if let firstAirDate = firstAirDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            firstAirDateFormatted = formatter.date(from: firstAirDate)
        } else {
            firstAirDateFormatted = nil
        }
        let genreIds = try container.decodeIfPresent([Int].self, forKey: .genres) ?? []
        genres = genreIds.compactMap { TVShow.genreMap[$0] ?? "Unknown" }
    }
}

struct TVResponse: Decodable {
    let results: [TVShow]
}
