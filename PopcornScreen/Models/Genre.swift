//
//  Genre.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 26/08/2025.
//

import Foundation

struct Genre: Identifiable, Decodable {
    let id: Int
    let name: String
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}
