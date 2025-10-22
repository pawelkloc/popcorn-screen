//
//  TMDBDecoder.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import Foundation

let TMDBDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
