//
//  TMDbService.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//
import Foundation

struct TMDbService {
    enum FetchError: Error {
        case badResponse
        case missingToken
        case decodingError(Error)
    }
    
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let bearerToken: String
    
    init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_TOKEN") as? String else {
            fatalError("TMDB_TOKEN not found in Info.plist")
        }
        
        self.bearerToken = token
    }
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        var components = URLComponents(url: baseURL.appendingPathComponent("discover/movie"), resolvingAgainstBaseURL: false)!
        
        components.queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en_US"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        
        guard let url = components.url else {
            throw FetchError.badResponse
        }
    }
}
