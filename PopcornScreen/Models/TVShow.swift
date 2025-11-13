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
    let originalLanguage: String?

    var posterURL: URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

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

    var languageCode: String {
        originalLanguage ?? ""
    }

    var languageDisplayName: String {
        guard let code = originalLanguage, !code.isEmpty else { return "" }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code
    }
}
