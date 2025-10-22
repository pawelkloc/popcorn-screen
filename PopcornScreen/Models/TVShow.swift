//
//  TVShow.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 21/08/2025.
//

import Foundation

struct TVResponse: Decodable {
    let results: [TVShow]
}

struct TVShow: Identifiable, Decodable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let firstAirDate: String?
    let genreIds: [Int]?
    let firstAirDateFormatted: Date?
    let voteAverage: Double?

    // Zbudowany pełny URL do plakatu na podstawie posterPath (tak jak w Movie)
    var posterURL: URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    // Rok pierwszej emisji używany przez SeriesView jako "subtitle"
    var firstAirYear: String? {
        if let date = firstAirDateFormatted {
            let year = Calendar.current.component(.year, from: date)
            return String(year)
        }
        if let str = firstAirDate, str.count >= 4 {
            return String(str.prefix(4))
        }
        return nil
    }
}
