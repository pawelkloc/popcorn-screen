//
//  File.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 23/10/2025.
//

import Foundation

extension Movie: MediaDisplayable {
    var titleText: String { title }
    var genreNames: String { "" }
    var releaseDateText: String? { releaseYear.isEmpty ? nil : releaseYear }
    var runtimeText: String? { nil }
    var overviewText: String { overview }
    var language: String? { languageDisplayName.isEmpty ? nil : languageDisplayName }
    var productionCompaniesText: String? {
        let names = productionCompanyNames
        return names.isEmpty ? nil : names
    }
}

