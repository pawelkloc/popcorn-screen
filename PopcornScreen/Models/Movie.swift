//
//  Movie.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//
import Foundation

struct MoviesResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int?
    let totalResults: Int?
}

struct ProductionCompany: Decodable, Identifiable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?
}

struct Movie: Decodable, Identifiable {
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
    let originalLanguage: String?
    let productionCompanies: [ProductionCompany]?
}

extension Movie {
    var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "" }
        return String(releaseDate.prefix(4))
    }

    var posterURL: URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        // You can adjust the size segment (e.g., w185, w342, w500, original) as needed.
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var languageCode: String {
        originalLanguage ?? ""
    }

    var languageDisplayName: String {
        guard let code = originalLanguage, !code.isEmpty else { return "" }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code
    }

    var productionCompanyNames: String {
        (productionCompanies ?? []).map { $0.name }.joined(separator: ", ")
    }
}
