//
//  TVShow.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 21/08/2025.
//

import Foundation

struct TVShow: Identifiable, Decodable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let firstAirDate: String?

    //  TODO: Add coding keys and init from decoder if needed
}

struct TVResponse: Decodable {
    let results: [TVShow]
}
