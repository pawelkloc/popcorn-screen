//
//  MediaDisplayable+TWShow.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 23/10/2025.
//

import Foundation

extension TVShow: MediaDisplayable {
    var titleText: String { name }
    var genreNames: String { "" }
    var releaseDateText: String? { firstAirYear }
    var runtimeText: String? { nil }
    var overviewText: String { overview }
    var language: String? { languageDisplayName.isEmpty ? nil : languageDisplayName }
    var productionCompaniesText: String? { nil }
}
