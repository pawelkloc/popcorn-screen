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
    
    // MARK: - Endpoint
    enum Endpoint {
        case discoverMovies
        case discoverTV
        case searchMovies
        case searchTV
        
        var path: String {
            switch self {
            case .discoverMovies: return "/discover/movie"
            case .discoverTV:     return "/discover/tv"
            case .searchMovies:   return "/search/movie"
            case .searchTV:       return "/search/tv"
            }
        }
        
        /// Default query items for each endpoint (page and query are added separately when provided).
        var defaultQueryItems: [URLQueryItem] {
            switch self {
            case .discoverMovies:
                return [
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "include_video", value: "false"),
                    URLQueryItem(name: "language", value: "en_US"),
                    URLQueryItem(name: "sort_by", value: "popularity.desc")
                ]
            case .discoverTV:
                return [
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "language", value: "en_US"),
                    URLQueryItem(name: "sort_by", value: "popularity.desc")
                ]
            case .searchMovies, .searchTV:
                return [
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "language", value: "en_US")
                ]
            }
        }

        func makeComponents(baseURL: URL, page: Int?, query: String?) -> URLComponents {
            var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
            var items = defaultQueryItems
            if let page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let que = query, !que.isEmpty { items.append(URLQueryItem(name: "query", value: que)) }
            components.queryItems = items
            return components
        }
    }

    // MARK: - Request Factory
    private func makeRequest(for endpoint: Endpoint, page: Int? = nil, query: String? = nil) throws -> URLRequest {
        let components = endpoint.makeComponents(baseURL: baseURL, page: page, query: query)
        guard let url = components.url else { throw FetchError.badResponse }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    // MARK: - Generic Fetch
    func fetch<T: Decodable>(_ type: T.Type, endpoint: Endpoint, page: Int? = nil, query: String? = nil)
            async throws -> T {
        let request = try makeRequest(for: endpoint, page: page, query: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchError.badResponse
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw FetchError.decodingError(error)
        }
    }

    init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_TOKEN") as? String else {
            fatalError("TMDB_TOKEN not found in Info.plist")
        }

        self.bearerToken = token
    }

    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        let response: MovieResponse = try await fetch(MovieResponse.self, endpoint: .discoverMovies, page: page)
        print("Fetched \(response.results.count) movies from TMDb")
        return response.results
    }

    func fetchPopularTV(page: Int) async throws -> [TVShow] {
        let response: TVResponse = try await fetch(TVResponse.self, endpoint: .discoverTV, page: page)
        print("Fetched \(response.results.count) TV shows from TMDb")
        return response.results
    }

    func searchMovies(query: String, page: Int = 1) async throws -> [Movie] {
        let response: MovieResponse = try await fetch(
            MovieResponse.self,
            endpoint: .searchMovies,
            page: page,
            query: query
        )
        print("Found \(response.results.count) movies for query: \(query)")
        return response.results
    }

    func searchTV(query: String, page: Int = 1) async throws -> [TVShow] {
        let response: TVResponse = try await fetch(
            TVResponse.self,
            endpoint: .searchTV,
            page: page,
            query: query
        )
        print("Found \(response.results.count) TV shows for query: \(query)")
        return response.results
    }
}
