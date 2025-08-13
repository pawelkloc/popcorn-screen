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
    
    
}
