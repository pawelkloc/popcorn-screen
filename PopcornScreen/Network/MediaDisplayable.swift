//
//  MediaDisplayable.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 23/10/2025.
//

import Foundation

public protocol MediaDisplayable: Identifiable {
    var id: Int { get }
    var titleText: String { get }
    var genreNames: String { get }
    var releaseDateText: String? { get }
    var runtimeText: String? { get }
    var overviewText: String { get }
    var posterURL: URL? { get }
    var language: String? { get }
    var productionCompaniesText: String? { get }
}

