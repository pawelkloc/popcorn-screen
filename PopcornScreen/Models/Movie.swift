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
        
        _ = try container.decodeIfPresent([Int].self, forKey: .genres)
        genres = []
        
        averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating)
    }
    
    private static let tmdbDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
