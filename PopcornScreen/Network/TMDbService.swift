import Foundation

final class TMDbService {
    enum FetchError: Error { case badResponse, missingToken, decodingError(Error) }

    enum Endpoint {
        case discoverMovies, discoverTV, searchMovies, searchTV, movieGenres, tvGenres
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
        var defaultQueryItems: [URLQueryItem] {
            switch self {
            case .discoverMovies:
                return [
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "include_video", value: "false"),
                    URLQueryItem(name: "language", value: "en-US"),
                    URLQueryItem(name: "sort_by", value: "popularity.desc")
                ]
            case .discoverTV:
                return [
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "language", value: "en-US"),
                    URLQueryItem(name: "sort_by", value: "popularity.desc")
                ]
            case .searchMovies, .searchTV:
                return [
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "language", value: "en-US")
                ]
            case .movieGenres, .tvGenres:
                return [URLQueryItem(name: "language", value: "en-US")]
            }
        }
        func components(baseURL: URL, page: Int?, query: String?, sort: TMDBSortOption?) -> URLComponents {
            let url = baseURL.appendingPathComponent(path)
            var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            var items = defaultQueryItems
            if let page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let que = query, !que.isEmpty { items.append(URLQueryItem(name: "query", value: que)) }
            if let sort { items.append(sortQueryItem(for: sort)) }
            comp.queryItems = items
            return comp
        }
    }

    let baseURL = URL(string: "https://api.themoviedb.org/3")!
    let bearerToken: String
    let client: HTTPClient
    private let decoder: JSONDecoder

    convenience init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_TOKEN") as? String else {
            fatalError("TMDB_TOKEN not found in Info.plist")
        }
        self.init(token: token, client: URLSessionHTTPClient())
    }

    init(token: String, client: HTTPClient = URLSessionHTTPClient()) {
        self.bearerToken = token
        self.client = client
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func request(for endpoint: Endpoint, page: Int? = nil, query: String? = nil, sort: TMDBSortOption? = nil) throws -> URLRequest {
        let components = endpoint.components(baseURL: baseURL, page: page, query: query, sort: sort)
        guard let url = components.url else { throw FetchError.badResponse }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }

    func fetchDecodable<T: Decodable>(_ type: T.Type, request: URLRequest) async throws -> T {
        let (data, response) = try await client.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw FetchError.badResponse }
        do { return try decoder.decode(T.self, from: data) }
        catch { throw FetchError.decodingError(error) }
    }
}
