//
//  TMDbService.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//
import Foundation

final class TMDbService {
    enum SortOption {
        case releaseDateAscending
        case releaseDateDescending
        case ratingAscending
        case ratingDescending
        case alphabeticalAscending
        case alphabeticalDescending
    }

    static let shared = TMDbService()

    private init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_TOKEN") as? String else {
            fatalError("TMDB_TOKEN not found in Info.plist")
        }

        self.bearerToken = token
    }

    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let bearerToken: String

    // MARK: - Error Handling
    enum FetchError: Error {
        case badResponse
        case missingToken
        case decodingError(Error)
    }

    // MARK: - API Endpoints
    enum Endpoint {
        case discoverMovies
        case discoverTV
        case searchMovies
        case searchTV
        case movieGenres
        case tvGenres

        var path: String {
            switch self {
            case .discoverMovies: return "/discover/movie"
            case .discoverTV:     return "/discover/tv"
            case .searchMovies:   return "/search/movie"
            case .searchTV:       return "/search/tv"
            case .movieGenres:    return "/genre/movie/list"
            case .tvGenres:       return "/genre/tv/list"
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
            case .movieGenres:
                return [URLQueryItem(name: "language", value: "en_US")]

            case .tvGenres:
                return [URLQueryItem(name: "language", value: "en_US")]
            }
        }

        func makeComponents(
            baseURL: URL,
            page: Int?,
            query: String?,
            sort: TMDbService.SortOption? = nil
        ) -> URLComponents {
            let url = baseURL.appendingPathComponent(path)
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            var items = defaultQueryItems
            if let page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let que = query, !que.isEmpty {
                items.append(URLQueryItem(name: "query", value: que))
            }
            if let sortOption = sort {
                if let sortItem = sortQueryItem(for: sortOption) {
                    items.append(sortItem)
                }
            }
            components.queryItems = items
            return components
        }
    }

    // MARK: - Request Building
    private func makeRequest(
        for endpoint: Endpoint,
        page: Int? = nil,
        query: String? = nil,
        sort: TMDbService.SortOption? = nil
    ) throws -> URLRequest {
        let components = endpoint.makeComponents(
            baseURL: baseURL,
            page: page,
            query: query,
            sort: sort
        )
        return try makeRequest(from: components)
    }

    private func makeRequest(from components: URLComponents) throws -> URLRequest {
        guard let url = components.url else { throw FetchError.badResponse }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    // MARK: - Generic Fetch
    func fetch<T: Decodable>(
        _ type: T.Type,
        endpoint: Endpoint,
        page: Int? = nil,
        query: String? = nil,
        sort: TMDbService.SortOption? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        var components = endpoint.makeComponents(
            baseURL: baseURL,
            page: page,
            query: query,
            sort: sort)

        if let queryItems = queryItems {
            components.queryItems = queryItems
        }

        let request = try makeRequest(from: components)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
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

    // MARK: - Specific Fetch Methods
    func fetchPopularMovies(page: Int, sort: TMDbService.SortOption? = nil)
    async throws -> [Movie] {
        let response: MoviesResponse = try await fetch(
            MoviesResponse.self,
            endpoint: .discoverMovies,
            page: page,
            sort: sort
        )
        print("Fetched \(response.results.count) movies from TMDb")
        return response.results
    }

    func fetchPopularTV(page: Int, sort: TMDbService.SortOption? = nil)
    async throws -> [TVShow] {
        let response: TVResponse = try await fetch(
            TVResponse.self,
            endpoint: .discoverTV,
            page: page,
            sort: sort)
        print("Fetched \(response.results.count) TV shows from TMDb")
        return response.results
    }

    // MARK: - Search Methods
    func searchMovies(query: String) async throws -> [Movie] {
        let response: MoviesResponse = try await fetch(
            MoviesResponse.self,
            endpoint: .searchMovies,
            page: 1,
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

    // MARK: - Sort method
    static func sortQueryItem(for option: TMDbService.SortOption) -> URLQueryItem? {
        switch option {
        case .releaseDateAscending:
            return URLQueryItem(name: "sort_by", value: "release_date.asc")
        case .releaseDateDescending:
            return URLQueryItem(name: "sort_by", value: "release_date.desc")
        case .ratingAscending:
            return URLQueryItem(name: "sort_by", value: "vote_average.asc")
        case .ratingDescending:
            return URLQueryItem(name: "sort_by", value: "vote_average.desc")
        case .alphabeticalAscending:
            return URLQueryItem(name: "sort_by", value: "original_title.asc")
        case .alphabeticalDescending:
            return URLQueryItem(name: "sort_by", value: "original_title.desc")
        }
    }

    // MARK: - Genre Fetching
    func fetchMovieGenres(language: String = "en_US") async throws -> [Genre] {
        let response: GenreResponse = try await fetch(
            GenreResponse.self,
            endpoint: .movieGenres
        )
        print("Fetched \(response.genres.count) genres from TMDb")
        return response.genres
    }

    func fetchTVGenres(language: String = "en_US") async throws -> [Genre] {
        let response: GenreResponse = try await fetch(
            GenreResponse.self,
            endpoint: .tvGenres
        )
        print("Fetched \(response.genres.count) TV genres from TMDb")
        return response.genres
    }

    // MARK: - By Genre Movies fetch
    func fetchMoviesByGenres(
        genreIDs: [Int],
        page: Int = 1,
        language: String = "en_US"
    ) async throws -> MoviesResponse {
        let genreString = genreIDs.map { String($0) }.joined(separator: ",")
        let queryItems = [
            URLQueryItem(name: "with_genres", value: genreString),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: String(page))
        ]

        return try await fetch(
            MoviesResponse.self,
            endpoint: .discoverMovies,
            queryItems: queryItems
        )
    }

    func fetchTVShowsByGenre(
        genreIDs: [Int],
        page: Int = 1,
        language: String = "en_US"
    ) async throws -> TVResponse {
        let genreString = genreIDs.map { String($0) }.joined(separator: ",")
        let queryItems = [
            URLQueryItem(name: "with_genres", value: genreString),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: String(page))
        ]

        return try await fetch(
            TVResponse.self,
            endpoint: .discoverTV,
            queryItems: queryItems
        )
    }
}
