//
//  TMDBSortOption.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import Foundation

enum TMDBSortOption {
    case releaseDateAscending
    case releaseDateDescending
    case ratingAscending
    case ratingDescending
    case alphabeticalAscending
    case alphabeticalDescending
}

@inline(__always)
func sortQueryItem(for option: TMDBSortOption) -> URLQueryItem {
    switch option {
    case .releaseDateAscending:   return URLQueryItem(name: "sort_by", value: "release_date.asc")
    case .releaseDateDescending:  return URLQueryItem(name: "sort_by", value: "release_date.desc")
    case .ratingAscending:        return URLQueryItem(name: "sort_by", value: "vote_average.asc")
    case .ratingDescending:       return URLQueryItem(name: "sort_by", value: "vote_average.desc")
    case .alphabeticalAscending:  return URLQueryItem(name: "sort_by", value: "original_title.asc")
    case .alphabeticalDescending: return URLQueryItem(name: "sort_by", value: "original_title.desc")
    }
}
